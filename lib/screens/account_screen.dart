import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../theme/app_theme.dart';
import 'auth/register_screen.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  Future<void> _signOut(BuildContext context) async {
    await GoogleSignIn.instance.signOut();
    await FirebaseAuth.instance.signOut();
    if (!context.mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const RegisterScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final displayName = user?.displayName ?? 'Utilisateur DavidSTORE';
    final email = user?.email ?? 'Non connecté';
    final photoUrl = user?.photoURL;
    final initial =
        displayName.isNotEmpty ? displayName[0].toUpperCase() : 'D';

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text('Mon compte',
            style: TextStyle(
                color: AppColors.textDark,
                fontSize: 18,
                fontWeight: FontWeight.w700)),
      ),
      body: ListView(
        children: [
          // Profil
          Container(
            color: AppColors.white,
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: const BoxDecoration(
                    color: AppColors.orangeDark,
                    shape: BoxShape.circle,
                  ),
                  child: photoUrl != null
                      ? ClipOval(
                          child: Image.network(
                            photoUrl,
                            width: 64,
                            height: 64,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Center(
                              child: Text(initial,
                                  style: const TextStyle(
                                      color: AppColors.white,
                                      fontSize: 26,
                                      fontWeight: FontWeight.w800)),
                            ),
                          ),
                        )
                      : Center(
                          child: Text(initial,
                              style: const TextStyle(
                                  color: AppColors.white,
                                  fontSize: 26,
                                  fontWeight: FontWeight.w800)),
                        ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(displayName,
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark)),
                    const SizedBox(height: 4),
                    Text(email,
                        style: const TextStyle(
                            fontSize: 13, color: AppColors.textGrey)),
                  ],
                ),
                const Spacer(),
                const Icon(Icons.edit_outlined,
                    color: AppColors.orangeDark),
              ],
            ),
          ),
          const SizedBox(height: 12),

          _buildSection([
            _buildTile(
              context: context,
              icon: Icons.shopping_bag_outlined,
              label: 'Mes commandes',
              onTap: () {},
            ),
            _buildTile(
              context: context,
              icon: Icons.location_on_outlined,
              label: 'Mes adresses',
              onTap: () {},
            ),
            _buildTile(
              context: context,
              icon: Icons.favorite_border,
              label: 'Mes favoris',
              onTap: () {},
            ),
          ]),
          const SizedBox(height: 12),

          _buildSection([
            _buildTile(
              context: context,
              icon: Icons.notifications_outlined,
              label: 'Notifications',
              onTap: () {},
            ),
            _buildTile(
              context: context,
              icon: Icons.lock_outline,
              label: 'Sécurité & mot de passe',
              onTap: () {},
            ),
            _buildTile(
              context: context,
              icon: Icons.language_outlined,
              label: 'Langue',
              trailing: const Text('Français',
                  style: TextStyle(
                      color: AppColors.textGrey, fontSize: 13)),
              onTap: () {},
            ),
          ]),
          const SizedBox(height: 12),

          // Déconnexion
          Container(
            color: AppColors.white,
            child: ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Se déconnecter',
                  style: TextStyle(
                      color: Colors.red, fontWeight: FontWeight.w600)),
              onTap: () => _signOut(context),
            ),
          ),
          const SizedBox(height: 24),

          const Center(
            child: Text('DavidSTORE v1.0.0',
                style: TextStyle(color: AppColors.textGrey, fontSize: 12)),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSection(List<Widget> tiles) {
    return Container(
      color: AppColors.white,
      child: Column(children: tiles),
    );
  }

  Widget _buildTile({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    return Column(
      children: [
        ListTile(
          leading: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF1EB),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.orangeDark, size: 20),
          ),
          title: Text(label,
              style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textDark,
                  fontWeight: FontWeight.w500)),
          trailing: trailing ??
              const Icon(Icons.chevron_right, color: AppColors.textGrey),
          onTap: onTap,
        ),
        const Divider(height: 1, indent: 68, color: Color(0xFFF0F0F0)),
      ],
    );
  }
}
