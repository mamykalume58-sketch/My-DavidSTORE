import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactScreen extends StatelessWidget {
  const ContactScreen({super.key});

  Future<void> _launch(Uri uri) async {
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
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
        title: const Text('Nous contacter', style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 17)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: ListTile(
              leading: Icon(Icons.chat_bubble_outline, color: theme.primaryColor),
              title: const Text('Nicole — Assistante DAVIDSTORE', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              subtitle: const Text('Réponse immédiate', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
              trailing: const Icon(Icons.chevron_right, size: 20),
              onTap: () => Navigator.pushNamed(context, '/support-chat'),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: ListTile(
              leading: const Icon(Icons.phone_outlined, color: Color(0xFF25D366)),
              title: const Text('WhatsApp', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              subtitle: const Text('+243 81 234 5678', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
              trailing: const Icon(Icons.chevron_right, size: 20),
              onTap: () => _launch(Uri.parse('https://wa.me/243812345678')),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: ListTile(
              leading: const Icon(Icons.email_outlined, color: Color(0xFF0F172A)),
              title: const Text('Email', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              subtitle: const Text('davstore4@gmail.com', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
              trailing: const Icon(Icons.chevron_right, size: 20),
              onTap: () => _launch(Uri(scheme: 'mailto', path: 'davstore4@gmail.com')),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: ListTile(
              leading: const Icon(Icons.call_outlined, color: Color(0xFF0F172A)),
              title: const Text('Téléphone', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              subtitle: const Text('+243 81 234 5678', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
              trailing: const Icon(Icons.chevron_right, size: 20),
              onTap: () => _launch(Uri(scheme: 'tel', path: '+243812345678')),
            ),
          ),
        ],
      ),
    );
  }
}
