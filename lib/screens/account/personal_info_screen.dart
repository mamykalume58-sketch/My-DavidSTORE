import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../../services/user_profile_service.dart';

class PersonalInfoScreen extends StatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  final _profileService = UserProfileService();

  Future<void> _editPhone(String current) async {
    final controller = TextEditingController(text: current == 'Non renseigné' ? '' : current);
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Numéro de téléphone'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(hintText: '+243 81 234 5678'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
    if (result != null && result.isNotEmpty) {
      await _profileService.updateUserProfile(phone: result);
    }
  }

  Future<void> _editBirthDate(DateTime? current) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: current ?? DateTime(2000, 1, 1),
      firstDate: DateTime(1930),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      await _profileService.updateUserProfile(birthDate: picked);
    }
  }

  Future<void> _editGender(String? current) async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Genre'),
        children: ['Homme', 'Femme', 'Autre']
            .map((g) => SimpleDialogOption(
                  onPressed: () => Navigator.pop(context, g),
                  child: Text(g),
                ))
            .toList(),
      ),
    );
    if (result != null) {
      await _profileService.updateUserProfile(gender: result);
    }
  }

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
        title: const Text('Informations personnelles',
            style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 17)),
      ),
      body: StreamBuilder<Map<String, dynamic>?>(
        stream: _profileService.watchUserProfile(),
        builder: (context, snapshot) {
          final data = snapshot.data ?? {};
          final phone = data['phone'] as String? ?? 'Non renseigné';
          final birthTs = data['birthDate'] as Timestamp?;
          final birthDate = birthTs?.toDate();
          final birthLabel = birthDate != null ? DateFormat('dd/MM/yyyy').format(birthDate) : 'Non renseignée';
          final gender = data['gender'] as String? ?? 'Non renseigné';

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: theme.primaryColor, borderRadius: BorderRadius.circular(16)),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 26,
                      backgroundColor: Colors.white,
                      child: Text(initiale,
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: theme.primaryColor)),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(nom, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                          if (email.isNotEmpty)
                            Text(email, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _buildInfoTile(context, Icons.person_outline, 'Nom complet', nom, null),
              _buildInfoTile(context, Icons.email_outlined, 'Adresse e-mail', email, null),
              _buildInfoTile(context, Icons.phone_outlined, 'Numéro de téléphone', phone, () => _editPhone(phone)),
              _buildInfoTile(context, Icons.cake_outlined, 'Date de naissance', birthLabel, () => _editBirthDate(birthDate)),
              _buildInfoTile(context, Icons.person_2_outlined, 'Genre', gender, () => _editGender(data['gender'] as String?)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildInfoTile(BuildContext context, IconData icon, String label, String value, VoidCallback? onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF475569)),
        title: Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
        subtitle: Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
        trailing: onTap != null ? const Icon(Icons.chevron_right, size: 20, color: Colors.grey) : null,
        onTap: onTap,
      ),
    );
  }
}
