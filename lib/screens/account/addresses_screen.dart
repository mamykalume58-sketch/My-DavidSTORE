import 'package:flutter/material.dart';

class AddressesScreen extends StatelessWidget {
  const AddressesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final addresses = [
      {'label': 'Maison', 'address': 'Avenue Nguma, Q/Matonge', 'city': 'Kinshasa, RDC', 'default': true},
      {'label': 'Bureau', 'address': 'Immeuble SOFICOM, 5e étage, Gombe', 'city': 'Kinshasa, RDC', 'default': false},
      {'label': 'Autre adresse', 'address': '', 'city': 'Lubumbashi, RDC', 'default': false},
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text('Adresses de livraison', style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 17)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ...addresses.map((addr) => Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.grey.shade200)),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      addr['default'] == true ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                      color: addr['default'] == true ? theme.primaryColor : Colors.grey,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(addr['label'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F172A))),
                              if (addr['default'] == true) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(color: theme.primaryColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                                  child: Text('Par défaut', style: TextStyle(fontSize: 10, color: theme.primaryColor, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 4),
                          if ((addr['address'] as String).isNotEmpty) Text(addr['address'] as String, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                          Text(addr['city'] as String, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                        ],
                      ),
                    ),
                    IconButton(icon: const Icon(Icons.edit_outlined, size: 18, color: Colors.grey), onPressed: () {}),
                  ],
                ),
              )),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add),
              label: const Text('Ajouter une nouvelle adresse'),
              style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            ),
          ),
        ],
      ),
    );
  }
}
