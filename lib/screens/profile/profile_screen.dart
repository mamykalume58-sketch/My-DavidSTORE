import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../widgets/custom_bottom_nav_bar.dart';
import '../../services/favorites_service.dart';
import '../../services/address_service.dart';
import '../../services/coupon_service.dart';
import '../../services/coupon_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final nom = user?.displayName?.isNotEmpty == true ? user!.displayName! : 'Utilisateur';
    final email = user?.email ?? '';
    final phone = user?.phoneNumber ?? '';
    final userId = user?.uid;
    final theme = Theme.of(context);
    final initiale = nom.isNotEmpty ? nom[0].toUpperCase() : 'U';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        title: const Text('Mon compte', style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 18)),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/account/personal-info'),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.primaryColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: Colors.white,
                      child: Text(initiale, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: theme.primaryColor)),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(nom, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                          if (phone.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Text(phone, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                            ),
                          if (email.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Text(email, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                            ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: Colors.white),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildOrdersStat(userId, theme, context),
                  ),
                  _buildDivider(),
                  Expanded(
                    child: _buildFavoritesStat(userId, theme, context),
                  ),
                  _buildDivider(),
                  Expanded(
                    child: _buildAddressesStat(theme, context),
                  ),
                  _buildDivider(),
                  Expanded(
                    child: _buildCouponsStat(theme, context),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _buildSectionTitle('Mon compte'),
            _buildMenuItem(context, Icons.person_outline, 'Informations personnelles', '/account/personal-info'),
            _buildMenuItem(context, Icons.location_on_outlined, 'Adresses de livraison', '/account/addresses'),
            _buildMenuItem(context, Icons.credit_card_outlined, 'Moyens de paiement', '/account/payment-methods'),
            _buildMenuItem(context, Icons.local_offer_outlined, 'Mes coupons', '/account/coupons'),
            _buildMenuItem(context, Icons.notifications_outlined, 'Notifications', '/account/notifications'),
            _buildMenuItem(context, Icons.lock_outline, 'Sécurité', '/account/security'),
            _buildMenuItem(context, Icons.language_outlined, 'Langue', '/account/language'),
            _buildMenuItem(context, Icons.palette_outlined, 'Thème', '/account/theme'),
            const SizedBox(height: 16),
            _buildSectionTitle('Support & à propos'),
            _buildMenuItem(context, Icons.help_outline, 'Centre d\'aide', '/account/help'),
            _buildMenuItem(context, Icons.chat_bubble_outline, 'Nous contacter', '/account/contact'),
            _buildMenuItem(context, Icons.info_outline, 'À propos de l\'application', '/account/about'),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/account/logout'),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: const Text('Se déconnecter', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 14)),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 4),
    );
  }

  Widget _buildDivider() {
    return Container(width: 1, height: 40, color: Colors.grey.shade200);
  }

  Widget _buildStat(IconData icon, Color color, String value, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
        ],
      ),
    );
  }

  Widget _buildOrdersStat(String? userId, ThemeData theme, BuildContext context) {
    if (userId == null) {
      return _buildStat(Icons.shopping_bag_outlined, theme.primaryColor, '0', 'Commandes', () => Navigator.pushNamed(context, '/tracking'));
    }
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('orders').where('userId', isEqualTo: userId).snapshots(),
      builder: (context, snapshot) {
        final count = snapshot.data?.docs.length ?? 0;
        return _buildStat(Icons.shopping_bag_outlined, theme.primaryColor, '$count', 'Commandes', () => Navigator.pushNamed(context, '/tracking'));
      },
    );
  }

  Widget _buildFavoritesStat(String? userId, ThemeData theme, BuildContext context) {
    if (userId == null) {
      return _buildStat(Icons.favorite_border, Colors.red, '0', 'Favoris', () => Navigator.pushNamed(context, '/favorites'));
    }
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: FavoritesService().watchFavorites(userId),
      builder: (context, snapshot) {
        final count = snapshot.data?.length ?? 0;
        return _buildStat(Icons.favorite_border, Colors.red, '$count', 'Favoris', () => Navigator.pushNamed(context, '/favorites'));
      },
    );
  }

  Widget _buildAddressesStat(ThemeData theme, BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: AddressService().watchAddresses(),
      builder: (context, snapshot) {
        final count = snapshot.data?.length ?? 0;
        return _buildStat(Icons.location_on_outlined, theme.primaryColor, '$count', 'Adresses', () => Navigator.pushNamed(context, '/account/addresses'));
      },
    );
  }

  Widget _buildCouponsStat(ThemeData theme, BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: CouponService().watchAvailableCoupons(),
      builder: (context, snapshot) {
        final count = snapshot.data?.length ?? 0;
        return _buildStat(Icons.local_activity_outlined, Colors.orange, '$count', 'Coupons', () => Navigator.pushNamed(context, '/account/coupons'));
      },
    );
  }

  Widget _buildCouponsStat(ThemeData theme, BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: CouponService().watchAvailableCoupons(),
      builder: (context, snapshot) {
        final count = snapshot.data?.length ?? 0;
        return _buildStat(Icons.local_activity_outlined, Colors.orange, '$count', 'Coupons', () => Navigator.pushNamed(context, '/account/coupons'));
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
    );
  }

  Widget _buildMenuItem(BuildContext context, IconData icon, String title, String route) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF475569)),
        title: Text(title, style: const TextStyle(fontSize: 14, color: Color(0xFF0F172A))),
        trailing: const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
        onTap: () => Navigator.pushNamed(context, route),
      ),
    );
  }
}
