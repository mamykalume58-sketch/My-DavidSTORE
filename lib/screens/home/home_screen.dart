import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/product.dart';
import '../../services/cart_service.dart';
import '../../services/favorites_service.dart';
import '../../widgets/product_card.dart';
import '../../widgets/category_chip.dart';
import '../../widgets/promo_banner.dart';
import '../../widgets/custom_bottom_nav_bar.dart';
import '../../widgets/app_drawer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedCategory = 'Tous';
  final CartService _cartService = CartService();
  final FavoritesService _favoritesService = FavoritesService();

  String? get _userId => FirebaseAuth.instance.currentUser?.uid;

  static const List<Map<String, String>> _categories = [
    {'label': 'Tous', 'icon': '🛍️'},
    {'label': 'Téléphones', 'icon': '📱'},
    {'label': 'Mode', 'icon': '👕'},
    {'label': 'Électronique', 'icon': '🔌'},
    {'label': 'Maison', 'icon': '🏠'},
  ];

  void _addToCart(Product product) {
    final userId = _userId;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Connecte-toi pour ajouter au panier.')),
      );
      return;
    }
    _cartService.addToCart(
      userId: userId,
      product: product,
      color: product.colors.isNotEmpty ? product.colors.first : '',
      size: product.sizes.isNotEmpty ? product.sizes.first : '',
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.name} ajouté au panier !'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _toggleFavorite(Product product) {
    final userId = _userId;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Connecte-toi pour ajouter aux favoris.')),
      );
      return;
    }
    _favoritesService.toggleFavorite(userId, product);
  }

  void _showSupportOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              ListTile(
                leading: const Icon(Icons.smart_toy_outlined, color: Colors.orange),
                title: const Text('Parler à Nicole'),
                subtitle: const Text('Assistante virtuelle DavidSTORE'),
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.pushNamed(context, '/support-chat');
                },
              ),
              ListTile(
                leading: const Icon(Icons.chat, color: Colors.green),
                title: const Text('Support WhatsApp'),
                subtitle: const Text('Parler à un humain'),
                onTap: () async {
                  Navigator.pop(ctx);
                  final uri = Uri.parse('https://wa.me/243852849473');
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  }
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userId = _userId;

    Query productsQuery = FirebaseFirestore.instance.collection('products');
    if (_selectedCategory != 'Tous') {
      productsQuery = productsQuery.where('category', isEqualTo: _selectedCategory);
    }

    return Scaffold(
      drawer: const AppDrawer(),
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Color(0xFF475569)),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(color: theme.primaryColor, borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.storefront, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 8),
            const Text('DAVIDSTORE',
                style: TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: 0.5)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.support_agent, color: Color(0xFF475569)),
            onPressed: () => _showSupportOptions(context),
          ),
          IconButton(
            icon: const Icon(Icons.shopping_bag_outlined, color: Color(0xFF475569)),
            onPressed: () => Navigator.pushNamed(context, '/cart'),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.search, color: Colors.grey.shade400, size: 20),
                      const SizedBox(width: 10),
                      Text('Rechercher un produit...', style: TextStyle(color: Colors.grey.shade400, fontSize: 13)),
                    ],
                  ),
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: PromoBanner(onTap: () => Navigator.pushNamed(context, '/catalog')),
            ),

            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Catégories', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                        GestureDetector(
                          onTap: () => Navigator.pushNamed(context, '/catalog'),
                          child: Text('Voir tout', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: theme.primaryColor)),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 42,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _categories.length,
                      itemBuilder: (context, index) {
                        final cat = _categories[index];
                        final isSelected = cat['label'] == _selectedCategory;
                        return CategoryChip(
                          label: cat['label']!,
                          emoji: cat['icon']!,
                          isSelected: isSelected,
                          onTap: () => setState(() => _selectedCategory = cat['label']!),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
                child: Text('Produits', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
              ),
            ),

            StreamBuilder<QuerySnapshot>(
              stream: productsQuery.snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SliverToBoxAdapter(
                    child: Padding(padding: EdgeInsets.symmetric(vertical: 40), child: Center(child: CircularProgressIndicator())),
                  );
                }
                if (snapshot.hasError) {
                  return const SliverToBoxAdapter(
                    child: Padding(padding: EdgeInsets.symmetric(vertical: 40), child: Center(child: Text('Erreur de chargement.'))),
                  );
                }

                final docs = snapshot.data?.docs ?? [];
                final products = docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  data['id'] = doc.id;
                  return Product.fromMap(data);
                }).where((p) => p.active).toList();

                if (products.isEmpty) {
                  return const SliverToBoxAdapter(
                    child: Padding(padding: EdgeInsets.symmetric(vertical: 40), child: Center(child: Text('Aucun produit pour le moment.'))),
                  );
                }

                return SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.68,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final product = products[index];
                        return userId == null
                            ? ProductCard(
                                product: product,
                                isFavorite: false,
                                onTap: () => Navigator.pushNamed(context, '/product', arguments: product),
                                onFavoriteToggle: () => _toggleFavorite(product),
                                onAddToCart: () => _addToCart(product),
                              )
                            : StreamBuilder<bool>(
                                stream: _favoritesService.isFavorite(userId, product.id),
                                builder: (context, favSnapshot) {
                                  return ProductCard(
                                    product: product,
                                    isFavorite: favSnapshot.data ?? false,
                                    onTap: () => Navigator.pushNamed(context, '/product', arguments: product),
                                    onFavoriteToggle: () => _toggleFavorite(product),
                                    onAddToCart: () => _addToCart(product),
                                  );
                                },
                              );
                      },
                      childCount: products.length,
                    ),
                  ),
                );
              },
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 0),
    );
  }
}
