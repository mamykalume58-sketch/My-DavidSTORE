import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PersonalInfoScreen extends StatelessWidget {
  const PersonalInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final nom = user?.displayName?.isNotEmpty == true ? user!.displayName! : 'Utilisateur';
    final email = user?.email ?? '';
    final theme = Theme.of(context);
    final initiale = nom.isNotEmpty ? nom[0].toUpperCase() : 'U';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text('Informations personnelles', style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 17)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: theme.primaryColor, borderRadius: BorderRadius.circular(16)),
            child: Row(
              children: [
                CircleAvatar(radius: 26, backgroundColor: Colors.white, child: Text(initiale, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: theme.primaryColor))),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(nom, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                      if (email.isNotEmpty) Text(email, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.white),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoTile(context, Icons.person_outline, 'Nom complet', nom),
          _buildInfoTile(context, Icons.email_outlined, 'Adresse e-mail', email),
          _buildInfoTile(context, Icons.phone_outlined, 'Numéro de téléphone', user?.phoneNumber ?? 'Non renseigné'),
          _buildInfoTile(context, Icons.cake_outlined, 'Date de naissance', 'Non renseignée'),
          _buildInfoTile(context, Icons.person_2_outlined, 'Genre', 'Non renseigné'),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Fonctionnalité bientôt disponible.')));
              },
              style: ElevatedButton.styleFrom(backgroundColor: theme.primaryColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: const Text('Modifier mes informations', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile(BuildContext context, IconData icon, String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF475569)),
        title: Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
        subtitle: Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
        trailing: const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
      ),
    );
  }
}
