import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../theme/app_theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _deconnecter(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    if (context.mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final nom = user?.displayName?.isNotEmpty == true ? user!.displayName! : 'Utilisateur';
    final email = user?.email ?? '';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                children: [
                  const Text(
                    'Mon compte',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.navyDark),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: AppColors.whiteMuted,
                    child: Text(
                      nom.isNotEmpty ? nom[0].toUpperCase() : '?',
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.orangeDark),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(nom, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.navyDark)),
                        const SizedBox(height: 2),
                        Text(email, style: const TextStyle(fontSize: 13, color: AppColors.textGrey)),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.edit_outlined, color: AppColors.orangeDark),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  _menuItem(context, Icons.receipt_long_outlined, 'Mes commandes', () {
                    Navigator.pushNamed(context, '/tracking');
                  }),
                  _menuItem(context, Icons.favorite_border, 'Favoris', () {
                    Navigator.pushNamed(context, '/favorites');
                  }),
                  _menuItem(context, Icons.location_on_outlined, 'Adresses', () {}),
                  _menuItem(context, Icons.payment_outlined, 'Moyens de paiement', () {}),
                  _menuItem(context, Icons.settings_outlined, 'Paramètres', () {}),
                  _menuItem(context, Icons.help_outline, 'Aide et support', () {}),
                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 12),
                  _menuItem(
                    context,
                    Icons.logout,
                    'Déconnexion',
                    () => _deconnecter(context),
                    color: Colors.redAccent,
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),

            Container(
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: Colors.grey.shade200)),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _NavItem(
                        icon: Icons.home_outlined,
                        label: 'Accueil',
                        active: false,
                        onTap: () => Navigator.pushNamed(context, '/home'),
                      ),
                      _NavItem(
                        icon: Icons.grid_view_outlined,
                        label: 'Catégories',
                        active: false,
                        onTap: () => Navigator.pushNamed(context, '/catalog'),
                      ),
                      _NavItem(
                        icon: Icons.shopping_cart_outlined,
                        label: 'Panier',
                        active: false,
                        onTap: () => Navigator.pushNamed(context, '/cart'),
                      ),
                      _NavItem(icon: Icons.person, label: 'Profil', active: true, onTap: () {}),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _menuItem(BuildContext context, IconData icon, String label, VoidCallback onTap, {Color? color}) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: color ?? AppColors.navyDark),
      title: Text(
        label,
        style: TextStyle(fontSize: 14, color: color ?? AppColors.textDark, fontWeight: FontWeight.w500),
      ),
      trailing: Icon(Icons.chevron_right, color: Colors.grey.shade400),
      onTap: onTap,
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.orangeDark : AppColors.textGrey;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(color: color, fontSize: 11)),
        ],
      ),
    );
  }
}
