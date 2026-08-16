import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/cart_service.dart';
import '../../services/address_service.dart';
import '../../widgets/address_form_sheet.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  int _selectedDelivery = 0;
  bool _isSubmitting = false;
  bool _isLoadingAddress = true;
  String? _errorMessage;

  final CartService _cartService = CartService();
  final AddressService _addressService = AddressService();

  Map<String, dynamic>? _selectedAddress;

  final List<Map<String, dynamic>> _deliveryOptions = [
    {'label': 'Livraison standard (3-5 jours)', 'price': 0},
    {'label': 'Livraison express (1-2 jours)', 'price': 5000},
  ];

  int get _fraisLivraison => _deliveryOptions[_selectedDelivery]['price'] as int;

  @override
  void initState() {
    super.initState();
    _loadDefaultAddress();
  }

  Future<void> _loadDefaultAddress() async {
    try {
      final defaultAddress = await _addressService.getDefaultAddress();
      if (mounted) {
        setState(() {
          _selectedAddress = defaultAddress;
          _isLoadingAddress = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingAddress = false);
      }
    }
  }

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
          'province': _selectedAddress?['province'],
          'commune': _selectedAddress?['commune'],
          'quartier': _selectedAddress?['quartier'],
          'avenue': _selectedAddress?['avenue'],
          'establishmentNumber': _selectedAddress?['establishmentNumber'],
          'reference': _selectedAddress?['reference'],
          'latitude': _selectedAddress?['latitude'],
          'longitude': _selectedAddress?['longitude'],
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

  Future<void> _openAddressForm({Map<String, dynamic>? existing}) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return SizedBox(
          height: MediaQuery.of(sheetContext).size.height * 0.95,
          child: AddressFormSheet(
            existing: existing,
            onSaved: (addressId) async {
              final saved = await _addressService.getAddress(addressId);
              if (mounted) {
                setState(() => _selectedAddress = saved);
              }
              if (sheetContext.mounted) {
                Navigator.pop(sheetContext);
              }
            },
          ),
        );
      },
    );
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
                                child: _isLoadingAddress
                                    ? const Center(
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(vertical: 8),
                                          child: SizedBox(
                                            height: 18,
                                            width: 18,
                                            child: CircularProgressIndicator(strokeWidth: 2),
                                          ),
                                        ),
                                      )
                                    : Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Icon(Icons.location_on_outlined,
                                              color: AppColors.orangeDark),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: _selectedAddress == null
                                                ? const Text(
                                                    'Aucune adresse sélectionnée',
                                                    style: TextStyle(
                                                        fontSize: 13, color: AppColors.textGrey),
                                                  )
                                                : Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        (_selectedAddress?['name'] as String?)
                                                                ?.isNotEmpty ==
                                                                true
                                                            ? _selectedAddress!['name'] as String
                                                            : 'Adresse de livraison',
                                                        style: const TextStyle(
                                                            fontWeight: FontWeight.bold,
                                                            color: AppColors.textDark),
                                                      ),
                                                      const SizedBox(height: 4),
                                                      Text(
                                                        [
                                                          _selectedAddress?['address'],
                                                          _selectedAddress?['commune'],
                                                          _selectedAddress?['city'],
                                                        ]
                                                            .where((e) =>
                                                                e != null &&
                                                                e.toString().isNotEmpty)
                                                            .join(', '),
                                                        style: const TextStyle(
                                                            fontSize: 13,
                                                            color: AppColors.textGrey),
                                                      ),
                                                      if ((_selectedAddress?['phone'] as String?)
                                                              ?.isNotEmpty ==
                                                          true) ...[
                                                        const SizedBox(height: 4),
                                                        Text(
                                                          _selectedAddress!['phone'] as String,
                                                          style: const TextStyle(
                                                              fontSize: 13,
                                                              color: AppColors.textGrey),
                                                        ),
                                                      ],
                                                    ],
                                                  ),
                                          ),
                                          TextButton(
                                            onPressed: () =>
                                                _openAddressForm(existing: _selectedAddress),
                                            child: Text(
                                              _selectedAddress == null ? 'Ajouter' : 'Changer',
                                              style: const TextStyle(
                                                  color: AppColors.orangeDark, fontSize: 13),
                                            ),
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

