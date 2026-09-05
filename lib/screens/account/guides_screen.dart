import 'package:flutter/material.dart';

class GuidesScreen extends StatelessWidget {
  const GuidesScreen({super.key});

  static const List<Map<String, dynamic>> _guides = [
    {
      'icon': Icons.shopping_cart_outlined,
      'title': 'Comment passer une commande',
      'description': 'Parcours le catalogue, ajoute des articles au panier et valide ta commande en quelques étapes.',
    },
    {
      'icon': Icons.local_shipping_outlined,
      'title': 'Comment suivre ma livraison',
      'description': "Consulte l'onglet Suivi pour connaître l'état d'avancement de chaque commande en temps réel.",
    },
    {
      'icon': Icons.confirmation_number_outlined,
      'title': 'Comment utiliser un coupon',
      'description': 'Choisis un coupon disponible dans Mes coupons, il sera appliqué automatiquement au paiement.',
    },
    {
      'icon': Icons.credit_card_outlined,
      'title': 'Comment ajouter un moyen de paiement',
      'description': 'Ajoute Airtel Money, M-Pesa, Orange Money ou une carte depuis Mes moyens de paiement.',
    },
    {
      'icon': Icons.person_outline,
      'title': 'Comment modifier mon profil',
      'description': 'Mets à jour tes informations personnelles depuis Informations personnelles dans ton compte.',
    },
    {
      'icon': Icons.notifications_outlined,
      'title': 'Comment gérer mes notifications',
      'description': 'Active ou désactive les alertes de commandes et de promotions depuis Notifications.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text('Guides et tutoriels', style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 17)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: _guides.map((guide) {
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(guide['icon'] as IconData, color: const Color(0xFFEA6A2E)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(guide['title'] as String, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
                      const SizedBox(height: 4),
                      Text(guide['description'] as String, style: const TextStyle(fontSize: 13, color: Color(0xFF64748B))),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
