import 'package:flutter/material.dart';

class SecurityScreen extends StatelessWidget {
  const SecurityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text('Sécurité', style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 17)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildTile(context, Icons.lock_outline, 'Mot de passe', 'Modifier votre mot de passe', '/account/change-password'),
          _buildTile(context, Icons.verified_user_outlined, 'Authentification à deux facteurs', 'Protégez votre compte', null, badge: 'Activée'),
          _buildTile(context, Icons.devices_outlined, 'Appareils connectés', 'Gérez vos appareils', '/account/connected-devices'),
          _buildTile(context, Icons.history_outlined, 'Sessions actives', 'Voir et fermer vos sessions', '/account/active-sessions'),
        ],
      ),
    );
  }

  Widget _buildTile(BuildContext context, IconData icon, String title, String subtitle, String? route, {String? badge}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF475569)),
        title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
        trailing: badge != null
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(10)),
                child: Text(badge, style: const TextStyle(fontSize: 10, color: Colors.green, fontWeight: FontWeight.bold)),
              )
            : const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
        onTap: route != null ? () => Navigator.pushNamed(context, route) : null,
      ),
    );
  }
}
