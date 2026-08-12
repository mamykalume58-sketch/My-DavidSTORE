import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text("À propos", style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 17)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: theme.primaryColor, borderRadius: BorderRadius.circular(16)),
                  child: const Icon(Icons.storefront_rounded, color: Colors.white, size: 40),
                ),
                const SizedBox(height: 12),
                const Text('DAVIDSTORE', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
                const SizedBox(height: 4),
                const Text('Version 1.0.0', style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: const Text(
              "DAVIDSTORE est votre boutique en ligne de confiance, proposant une large sélection de produits avec paiement via Airtel Money, M-Pesa et Orange Money, et une livraison rapide.",
              style: TextStyle(fontSize: 13, color: Color(0xFF64748B), height: 1.5),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.description_outlined, color: Color(0xFF64748B)),
                  title: const Text('Politique de confidentialité', style: TextStyle(fontSize: 14)),
                  trailing: const Icon(Icons.chevron_right, size: 20),
                  onTap: () => Navigator.pushNamed(context, '/account/privacy-policy'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.gavel_outlined, color: Color(0xFF64748B)),
                  title: const Text("Conditions d'utilisation", style: TextStyle(fontSize: 14)),
                  trailing: const Icon(Icons.chevron_right, size: 20),
                  onTap: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
