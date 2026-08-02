import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'category_screen.dart';
import 'favorites_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const _AccueilPage(),
    const CategoryScreen(categoryName: 'Toutes'),
    const FavoritesScreen(),
    const _PanierPage(),
    const _ComptePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: AppColors.orangeDark,
        unselectedItemColor: AppColors.textGrey,
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.white,
        onTap: (index) {
          setState(() => _currentIndex = index);
        },
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined), label: 'Accueil'),
          BottomNavigationBarItem(
              icon: Icon(Icons.grid_view_outlined), label: 'Catégories'),
          BottomNavigationBarItem(
              icon: Icon(Icons.favorite_border), label: 'Favoris'),
          BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart_outlined), label: 'Panier'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_outline), label: 'Compte'),
        ],
      ),
    );
  }
}

// ── PAGE ACCUEIL ──────────────────────────────────────────
class _AccueilPage extends StatelessWidget {
  const _AccueilPage();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          _buildHeader(),
          _buildSearchBar(),
          _buildBanner(),
          _buildQuickInfoRow(),
          _buildSectionTitle('Catégories', showAll: true),
          _buildCategories(context),
          _buildSectionTitle('Réductions du jour', showAll: true),
          _buildDiscounts(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: Row(
        children: [
          const Icon(Icons.menu, color: AppColors.textDark),
          const SizedBox(width: 12),
          const Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: 'DAVID',
                  style: TextStyle(
                      color: AppColors.navyDark,
                      fontSize: 18,
                      fontWeight: FontWeight.w800),
                ),
                TextSpan(
                  text: 'STORE',
                  style: TextStyle(
                      color: AppColors.orangeDark,
                      fontSize: 18,
                      fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),
          const Spacer(),
          const Icon(Icons.notifications_none, color: AppColors.textDark),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF2F2F2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const TextField(
          decoration: InputDecoration(
            hintText: 'Rechercher un produit, une marque...',
            hintStyle: TextStyle(color: AppColors.textGrey, fontSize: 14),
            prefixIcon: Icon(Icons.search, color: AppColors.textGrey),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ),
    );
  }

  Widget _buildBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(20),
      height: 160,
      decoration: BoxDecoration(
        color: AppColors.navyDark,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Text('Le shopping',
              style: TextStyle(
                  color: AppColors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700)),
          Text('intelligent',
              style: TextStyle(
                  color: AppColors.orangeDark,
                  fontSize: 20,
                  fontWeight: FontWeight.w800)),
          Text('commence ici.',
              style: TextStyle(
                  color: AppColors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700)),
          SizedBox(height: 8),
          Text('Découvrez DavidSTORE...',
              style: TextStyle(color: AppColors.whiteMuted, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildQuickInfoRow() {
    final items = [
      (Icons.local_shipping_outlined, 'Livraison rapide'),
      (Icons.verified_outlined, 'Produits de qualité'),
      (Icons.lock_outline, 'Paiement sécurisé'),
      (Icons.support_agent_outlined, 'Service client 24/7'),
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: items.map((item) {
          return Column(
            children: [
              Icon(item.$1, color: AppColors.orangeDark, size: 22),
              const SizedBox(height: 6),
              SizedBox(
                width: 65,
                child: Text(item.$2,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 10, color: AppColors.textGrey)),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSectionTitle(String title, {bool showAll = false}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark)),
          const Spacer(),
          if (showAll)
            const Text('Voir tout',
                style: TextStyle(fontSize: 13, color: AppColors.orangeDark)),
        ],
      ),
    );
  }

  Widget _buildCategories(BuildContext context) {
    final categories = [
      (Icons.devices_other, 'Électronique'),
      (Icons.checkroom, 'Mode'),
      (Icons.chair, 'Maison'),
      (Icons.face_retouching_natural, 'Beauté'),
      (Icons.apps, 'Autres'),
    ];
    return SizedBox(
      height: 90,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: categories.map((cat) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CategoryScreen(categoryName: cat.$2),
                  ),
                );
              },
              child: Column(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF1EB),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(cat.$1, color: AppColors.orangeDark),
                  ),
                  const SizedBox(height: 6),
                  Text(cat.$2,
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.textDark)),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDiscounts() {
    final discounts = [
      ('Casque Bluetooth\nSony WH-CH520', '25.000 FC', '30.000 FC', '-17%'),
      ('Montre Connectée', '45.000 FC', '60.000 FC', '-16%'),
      ('Sac à dos', '18.000 FC', '22.000 FC', '-20%'),
    ];
    return SizedBox(
      height: 190,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: discounts.map((item) {
          return Container(
            width: 130,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFEEEEEE)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    Container(
                      height: 90,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF7F7F7),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12),
                        ),
                      ),
                      child: const Center(
                        child: Icon(Icons.image_outlined,
                            color: AppColors.textGrey, size: 32),
                      ),
                    ),
                    Positioned(
                      top: 6,
                      left: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(item.$4,
                            style: const TextStyle(
                                color: AppColors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.$1,
                          style: const TextStyle(
                              fontSize: 11, color: AppColors.textDark),
                          maxLines: 2),
                      const SizedBox(height: 4),
                      Text(item.$2,
                          style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.orangeDark)),
                      Text(item.$3,
                          style: const TextStyle(
                              fontSize: 10,
                              color: AppColors.textGrey,
                              decoration: TextDecoration.lineThrough)),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ── PAGE PANIER ───────────────────────────────────────────
class _PanierPage extends StatelessWidget {
  const _PanierPage();

  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: Center(
        child: Text('Panier - Bientôt disponible',
            style: TextStyle(color: AppColors.textGrey)),
      ),
    );
  }
}

// ── PAGE COMPTE ───────────────────────────────────────────
class _ComptePage extends StatelessWidget {
  const _ComptePage();

  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: Center(
        child: Text('Compte - Bientôt disponible',
            style: TextStyle(color: AppColors.textGrey)),
      ),
    );
  }
}
