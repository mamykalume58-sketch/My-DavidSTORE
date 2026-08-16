import 'package:flutter/material.dart';
import '../../services/address_service.dart';
import '../../widgets/address_form_sheet.dart';

/// Écran "Adresses de livraison" (Compte).
/// Étape 4d : ajout suppression + définir par défaut.
class AddressesScreen extends StatefulWidget {
  const AddressesScreen({super.key});

  @override
  State<AddressesScreen> createState() => _AddressesScreenState();
}

class _AddressesScreenState extends State<AddressesScreen> {
  final AddressService _addressService = AddressService();
  late final Stream<List<Map<String, dynamic>>> _addressesStream;

  @override
  void initState() {
    super.initState();
    _addressesStream = _addressService.watchAddresses();
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
            onSaved: (addressId) {
              Navigator.pop(sheetContext);
            },
          ),
        );
      },
    );
  }

  Future<void> _setDefault(String addressId) async {
    try {
      await _addressService.setDefaultAddress(addressId);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Impossible de définir cette adresse par défaut.')),
        );
      }
    }
  }

  Future<void> _confirmAndDelete(String addressId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Supprimer cette adresse ?'),
        content: const Text('Cette action est irréversible.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _addressService.deleteAddress(addressId);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Impossible de supprimer cette adresse.')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          'Adresses de livraison',
          style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 17),
        ),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _addressesStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final addresses = snapshot.data ?? [];

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (addresses.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Column(
                    children: [
                      Icon(Icons.location_off_outlined, size: 48, color: Colors.grey.shade400),
                      const SizedBox(height: 12),
                      const Text(
                        'Aucune adresse enregistrée',
                        style: TextStyle(color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                )
              else
                ...addresses.map((addr) {
                  final addressId = addr['id'] as String;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          addr['isDefault'] == true
                              ? Icons.radio_button_checked
                              : Icons.radio_button_unchecked,
                          color: addr['isDefault'] == true ? theme.primaryColor : Colors.grey,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    (addr['label'] as String?)?.isNotEmpty == true
                                        ? addr['label'] as String
                                        : 'Adresse',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: Color(0xFF0F172A),
                                    ),
                                  ),
                                  if (addr['isDefault'] == true) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: theme.primaryColor.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        'Par défaut',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: theme.primaryColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 4),
                              if ((addr['address'] as String?)?.isNotEmpty == true)
                                Text(
                                  addr['address'] as String,
                                  style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                                ),
                              if ((addr['commune'] as String?)?.isNotEmpty == true ||
                                  (addr['city'] as String?)?.isNotEmpty == true)
                                Text(
                                  [
                                    addr['commune'],
                                    addr['city'],
                                    addr['province'],
                                  ].where((e) => e != null && e.toString().isNotEmpty).join(', '),
                                  style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                                ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, size: 18, color: Colors.grey),
                          onPressed: () => _openAddressForm(existing: addr),
                        ),
                        PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert, size: 18, color: Colors.grey),
                          onSelected: (value) {
                            if (value == 'default') {
                              _setDefault(addressId);
                            } else if (value == 'delete') {
                              _confirmAndDelete(addressId);
                            }
                          },
                          itemBuilder: (context) => [
                            if (addr['isDefault'] != true)
                              const PopupMenuItem(
                                value: 'default',
                                child: Text('Définir par défaut'),
                              ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Text('Supprimer', style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: () => _openAddressForm(),
                  icon: const Icon(Icons.add),
                  label: const Text('Ajouter une nouvelle adresse'),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

