import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/cart_service.dart';
import '../../services/address_service.dart';
import 'package:geolocator/geolocator.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  int _selectedDelivery = 0;
  bool _isSubmitting = false;
  String? _errorMessage;

  final CartService _cartService = CartService();
  final AddressService _addressService = AddressService();

  Map<String, dynamic>? _selectedAddress;
  bool _isLocating = false;

  final List<Map<String, dynamic>> _deliveryOptions = [
    {'label': 'Livraison standard (3-5 jours)', 'price': 0},
    {'label': 'Livraison express (1-2 jours)', 'price': 5000},
  ];

  int get _fraisLivraison => _deliveryOptions[_selectedDelivery]['price'] as int;

  String _formatPrice(int value) {
    final str = value.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) buffer.write(' ');
      buffer.write(str[i]);
    }
    return '${buffer.toString()} FC';
  }

  int _sousTotalFrom(List<Map<String, dynamic>> items) {
    int total = 0;
    for (final item in items) {
      final price = (item['price'] as num?)?.toInt() ?? 0;
      final qty = (item['quantity'] as num?)?.toInt() ?? 1;
      total += price * qty;
    }
    return total;
  }

  Future<void> _confirmerCommande(List<Map<String, dynamic>> cartItems, int sousTotal) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      setState(() => _errorMessage = 'Tu dois être connecté pour commander.');
      return;
    }
    if (cartItems.isEmpty) {
      setState(() => _errorMessage = 'Ton panier est vide.');
      return;
    }
    if (_selectedAddress == null) {
      setState(() => _errorMessage = 'Choisis ou ajoute une adresse de livraison.');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final db = FirebaseFirestore.instance;
      final orderRef = db.collection('orders').doc();
      final total = sousTotal + _fraisLivraison;

      await orderRef.set({
        'userId': userId,
        'orderNumber':
            'DS-${DateTime.now().year}-${orderRef.id.substring(0, 6).toUpperCase()}',
        'status': 'pending',
        'items': cartItems
            .map((item) => {
                  'productId': item['productId'],
                  'name': item['name'],
                  'price': item['price'],
                  'quantity': item['quantity'],
                  'color': item['color'],
                  'image': item['image'] ?? '',
                })
            .toList(),
        'deliveryAddress': {
          'label': _selectedAddress?['label'] ?? '',
          'name': _selectedAddress?['name'] ?? (FirebaseAuth.instance.currentUser?.displayName ?? ''),
          'address': _selectedAddress?['address'] ?? '',
          'city': _selectedAddress?['city'] ?? '',
          'phone': _selectedAddress?['phone'] ?? (FirebaseAuth.instance.currentUser?.phoneNumber ?? ''),
        },
        'deliveryMethod': {
          'label': _deliveryOptions[_selectedDelivery]['label'],
          'price': _fraisLivraison,
        },
        'sousTotal': sousTotal,
        'fraisLivraison': _fraisLivraison,
        'total': total,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      Navigator.pushNamed(
        context,
        '/payment',
        arguments: {
          'orderId': orderRef.id,
          'amount': total.toDouble(),
          'userId': userId,
        },
      );
    } catch (e) {
      setState(() => _errorMessage = 'Impossible de créer la commande. Réessaie.');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }


  Future<void> _addOrEditAddress({Map<String, dynamic>? existing}) async {
    final label = TextEditingController(
      text: existing?['label']?.toString() ?? '',
    );
    final name = TextEditingController(
      text: existing?['name']?.toString() ?? '',
    );
    final phone = TextEditingController(
      text: existing?['phone']?.toString() ?? '',
    );
    final address = TextEditingController(
      text: existing?['address']?.toString() ?? '',
    );
    final city = TextEditingController(
      text: existing?['city']?.toString() ?? '',
    );

    await showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          existing == null ? 'Ajouter une adresse' : 'Modifier l’adresse',
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _isLocating ? null : _useMyLocation,
                  icon: const Icon(Icons.my_location),
                  label: Text(
                    _isLocating
                        ? 'Localisation...'
                        : 'Utiliser ma position',
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: label,
                decoration: const InputDecoration(labelText: 'Libellé'),
              ),
              TextField(
                controller: name,
                decoration: const InputDecoration(labelText: 'Nom complet'),
              ),
              TextField(
                controller: phone,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: 'Téléphone'),
              ),
              TextField(
                controller: address,
                decoration: const InputDecoration(labelText: 'Adresse'),
              ),
              TextField(
                controller: city,
                decoration: const InputDecoration(labelText: 'Ville'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (name.text.trim().isEmpty ||
                  phone.text.trim().isEmpty ||
                  address.text.trim().isEmpty ||
                  city.text.trim().isEmpty) {
                return;
              }

              try {
                if (existing == null) {
                  final id = await _addressService.addAddress(
                    label: label.text.trim(),
                    name: name.text.trim(),
                    phone: phone.text.trim(),
                    address: address.text.trim(),
                    city: city.text.trim(),
                    isDefault: true,
                  );

                  final saved = await _addressService.getAddress(id);

                  if (mounted) {
                    setState(() => _selectedAddress = saved);
                  }
                } else {
                  await _addressService.updateAddress(
                    addressId: existing['id'].toString(),
                    label: label.text.trim(),
                    name: name.text.trim(),
                    phone: phone.text.trim(),
                    address: address.text.trim(),
                    city: city.text.trim(),
                    latitude: (existing['latitude'] as num?)?.toDouble(),
                    longitude: (existing['longitude'] as num?)?.toDouble(),
                    isDefault: existing['isDefault'] == true,
                  );

                  final saved = await _addressService.getAddress(
                    existing['id'].toString(),
                  );

                  if (mounted) {
                    setState(() => _selectedAddress = saved);
                  }
                }

                if (dialogContext.mounted) {
                  Navigator.pop(dialogContext);
                }
              } catch (e) {
                debugPrint('Erreur adresse: $e');
              }
            },
            child: Text(existing == null ? 'Ajouter' : 'Enregistrer'),
          ),
        ],
      ),
    );

    label.dispose();
    name.dispose();
    phone.dispose();
    address.dispose();
    city.dispose();
  }


  Future<void> _useMyLocation() async {
    setState(() => _isLocating = true);

    try {
      final enabled = await Geolocator.isLocationServiceEnabled();

      if (!enabled) {
        throw Exception('Active la localisation du téléphone.');
      }

      var permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        throw Exception('Permission GPS refusée.');
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      if (!mounted) return;

      setState(() {
        _selectedAddress = {
          'label': 'Ma position',
          'name': FirebaseAuth.instance.currentUser?.displayName ?? '',
          'phone': FirebaseAuth.instance.currentUser?.phoneNumber ?? '',
          'address': 'Position GPS',
          'city': '',
          'latitude': position.latitude,
          'longitude': position.longitude,
        };
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage =
              e.toString().replaceFirst('Exception: ', '');
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isLocating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: userId == null
            ? const Center(child: Text('Connecte-toi pour continuer.'))
            : StreamBuilder<List<Map<String, dynamic>>>(
                stream: _cartService.watchCart(userId),
                builder: (context, snapshot) {
                  final cartItems = snapshot.data ?? [];
                  final sousTotal = _sousTotalFrom(cartItems);
                  final total = sousTotal + _fraisLivraison;

                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(Icons.arrow_back, color: AppColors.navyDark),
                            ),
                            const Text(
                              'Informations de livraison',
                              style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.navyDark),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 8),
                              const Text(
                                'Adresse de livraison',
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.navyDark),
                              ),
                              const SizedBox(height: 10),
                              Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: AppColors.whiteMuted,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: Colors.grey.shade200),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(Icons.location_on_outlined,
                                        color: AppColors.orangeDark),
                                    const SizedBox(width: 10),
                                    const Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('Gaël Mpanga',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: AppColors.textDark)),
                                          SizedBox(height: 4),
                                          Text(
                                            'C/ de Lubumbashi Q/ Mampala à la Gécamine, Lubumbashi',
                                            style: TextStyle(
                                                fontSize: 13, color: AppColors.textGrey),
                                          ),
                                          SizedBox(height: 4),
                                          Text('+243 97 000 00 00',
                                              style: TextStyle(
                                                  fontSize: 13, color: AppColors.textGrey)),
                                        ],
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () => _addOrEditAddress(existing: _selectedAddress),
                                      child: const Text('Changer',
                                          style: TextStyle(
                                              color: AppColors.orangeDark, fontSize: 13)),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),
                              const Text(
                                'Méthode de livraison',
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.navyDark),
                              ),
                              const SizedBox(height: 10),
                              ...List.generate(_deliveryOptions.length, (index) {
                                final option = _deliveryOptions[index];
                                final isSelected = _selectedDelivery == index;
                                final price = option['price'] as int;
                                return GestureDetector(
                                  onTap: () => setState(() => _selectedDelivery = index),
                                  child: Container(
                                    margin: const EdgeInsets.only(bottom: 10),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 12),
                                    decoration: BoxDecoration(
                                      color: AppColors.whiteMuted,
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                        color: isSelected
                                            ? AppColors.orangeDark
                                            : Colors.grey.shade200,
                                        width: isSelected ? 1.5 : 1,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          isSelected
                                              ? Icons.radio_button_checked
                                              : Icons.radio_button_off,
                                          color:
                                              isSelected ? AppColors.orangeDark : Colors.grey,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Text(option['label'] as String,
                                              style: const TextStyle(
                                                  fontSize: 13, color: AppColors.textDark)),
                                        ),
                                        Text(
                                          price == 0 ? 'Gratuite' : _formatPrice(price),
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            color: price == 0
                                                ? Colors.green
                                                : AppColors.navyDark,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }),
                              const SizedBox(height: 20),
                              const Text(
                                'Résumé de commande',
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.navyDark),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Sous-total',
                                      style: TextStyle(color: AppColors.textGrey)),
                                  Text(_formatPrice(sousTotal),
                                      style: const TextStyle(fontWeight: FontWeight.w600)),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Livraison',
                                      style: TextStyle(color: AppColors.textGrey)),
                                  Text(
                                    _fraisLivraison == 0
                                        ? 'Gratuite'
                                        : _formatPrice(_fraisLivraison),
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: _fraisLivraison == 0
                                          ? Colors.green
                                          : AppColors.navyDark,
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(height: 24),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Total',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.navyDark)),
                                  Text(
                                    _formatPrice(total),
                                    style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.orangeDark),
                                  ),
                                ],
                              ),
                              if (_errorMessage != null) ...[
                                const SizedBox(height: 12),
                                Text(_errorMessage!,
                                    style: const TextStyle(color: Colors.red, fontSize: 12)),
                              ],
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                        child: ElevatedButton(
                          onPressed: _isSubmitting
                              ? null
                              : () => _confirmerCommande(cartItems, sousTotal),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.orangeDark,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                            minimumSize: const Size(double.infinity, 0),
                          ),
                          child: _isSubmitting
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2),
                                )
                              : const Text(
                                  'Choisir le mode de paiement',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                        ),
                      ),
                    ],
                  );
                },
              ),
      ),
    );
  }
}
