import 'package:flutter/material.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  static const List<Map<String, dynamic>> _categories = [
    {
      'icon': Icons.help_outline,
      'title': 'FAQ',
      'subtitle': 'Questions fréquentes',
      'route': '/account/faq',
    },
    {
      'icon': Icons.menu_book_outlined,
      'title': 'Guides et tutoriels',
      'subtitle': "Apprends à utiliser l'application",
      'route': '/account/guides',
    },
    {
      'icon': Icons.local_shipping_outlined,
      'title': 'Livraison',
      'subtitle': 'Tout sur la livraison',
      'route': '/account/shipping-info',
    },
    {
      'icon': Icons.payment_outlined,
      'title': 'Paiement',
      'subtitle': 'Moyens et sécurité',
      'route': '/account/payment-info',
    },
    {
      'icon': Icons.assignment_return_outlined,
      'title': 'Retour et remboursement',
      'subtitle': 'Politique de retour',
      'route': '/account/returns-info',
    },
    {
      'icon': Icons.support_agent_outlined,
      'title': 'Nous contacter',
      'subtitle': 'Par email, téléphone ou chat',
      'route': '/account/contact',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text("Centre d'aide", style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 17)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: _categories.map((cat) {
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: ListTile(
              leading: Icon(cat['icon'] as IconData, color: const Color(0xFFEA6A2E)),
              title: Text(cat['title'] as String, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
              subtitle: Text(cat['subtitle'] as String, style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
              trailing: const Icon(Icons.chevron_right, color: Color(0xFF94A3B8)),
              onTap: () => Navigator.pushNamed(context, cat['route'] as String),
            ),
          );
        }).toList(),
      ),
    );
  }
}
