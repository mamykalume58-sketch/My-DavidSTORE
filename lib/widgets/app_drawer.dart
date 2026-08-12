import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Color(0xFFF8FAFC)),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Text(
                  'DAVIDSTORE',
                  style: TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.w900, fontSize: 20, letterSpacing: 0.5),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.smart_toy_outlined, color: Colors.orange),
              title: const Text('Parler à Nicole'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/support-chat');
              },
            ),
            ListTile(
              leading: const Icon(Icons.chat, color: Colors.green),
              title: const Text('Support WhatsApp'),
              onTap: () async {
                Navigator.pop(context);
                final uri = Uri.parse('https://wa.me/243852849473');
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
