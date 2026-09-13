import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

const String _fallbackAboutContent =
    "DAVIDSTORE est votre boutique en ligne de confiance, proposant une large sélection de produits avec paiement via Airtel Money, M-Pesa et Orange Money, et une livraison rapide.";

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
                FutureBuilder<PackageInfo>(
                  future: PackageInfo.fromPlatform(),
                  builder: (context, snapshot) {
                    final label = snapshot.hasData
                        ? 'Version ${snapshot.data!.version} (${snapshot.data!.buildNumber})'
                        : 'Version...';
                    return Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)));
                  },
                ),
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
            child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance.collection('contentPages').doc('about').snapshots(),
              builder: (context, snapshot) {
                final content = snapshot.data?.data()?['content'] as String? ?? _fallbackAboutContent;
                return Text(
                  content,
                  style: const TextStyle(fontSize: 13, color: Color(0xFF64748B), height: 1.5),
                );
              },
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
                  leading: const Icon(Icons.campaign_outlined, color: Color(0xFF64748B)),
                  title: const Text('Quoi de neuf ?', style: TextStyle(fontSize: 14)),
                  trailing: const Icon(Icons.chevron_right, size: 20),
                  onTap: () {},
                ),
                const Divider(height: 1),
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
                  onTap: () => Navigator.pushNamed(context, '/account/privacy-policy'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.balance_outlined, color: Color(0xFF64748B)),
                  title: const Text('Mentions légales', style: TextStyle(fontSize: 14)),
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
