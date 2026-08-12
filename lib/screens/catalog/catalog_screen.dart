import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../models/product.dart';
import '../../services/cart_service.dart';
import '../../services/favorites_service.dart';
import '../../widgets/catalog_product_card.dart';
import '../../widgets/catalog_sort_modal.dart';
import '../../widgets/custom_bottom_nav_bar.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  final TextEditingController _searchController = TextEditingController();
  final CartService _cartService = CartService();
  final FavoritesService _favoritesService = FavoritesService();

  String _selectedCategory = 'Tous';
  String _searchQuery = '';
  SortOption _currentSort = SortOption.newest;
  bool _isInit = false;

  String? get _userId => FirebaseAuth.instance.currentUser?.uid;

  final List<String> _categories = ['Tous', 'Téléphones', 'Mode', 'Électronique', 'Maison'];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInit) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is String && _categories.contains(args)) {
        _selectedCategory = args;
      } else if (args is Map) {
        if (args['category'] != null && _categories.contains(args['category'])) {
          _selectedCategory = args['category'];
        }
        if (args['search'] != null) {
          _searchQuery = args['search'];
          _searchController.text = _searchQuery;
        }
      }
      _isInit = true;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openSortModal() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => CatalogSortModal(
        currentSort: _currentSort,
        onSortSelected: (option) => setState(() => _currentSort = option),
      ),
    );
  }

  void _addToCart(Product product) {
    final userId = _userId;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Connecte-toi pour ajouter au panier.')));
      return;
    }
    _cartService.addToCart(
      userId: userId,
      product: product,
      color: product.colors.isNotEmpty ? product.colors.first : '',
      size: product.sizes.isNotEmpty ? product.sizes.first : '',
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${product.name} ajouté au panier'), duration: const Duration(seconds: 2)),
    );
  }

  void _toggleFavorite(Product product) {
    final userId = _userId;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Connecte-toi pour ajouter aux favoris.')));
      return;
    }
    _favoritesService.toggleFavorite(userId, product);
  }

  List<Product> _filterAndSortProducts(List<Product> products) {
    final filtered = products.where((product) {
      final matchesCategory = _selectedCategory == 'Tous' || product.category == _selectedCategory;
      final matchesSearch = _searchQuery.isEmpty ||
          product.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          product.category.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch && product.active;
    }).toList();

    filtered.sort((a, b) {
      switch (_currentSort) {
        case SortOption.priceAsc:
          return a.price.compareTo(b.price);
        case SortOption.priceDesc:
          return b.price.compareTo(a.price);
        case SortOption.nameAsc:
          return a.name.toLowerCase().compareTo(b.name.toLowerCase());
        case SortOption.newest:
          return b.createdAt.compareTo(a.createdAt);
      }
    });

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    final userId = _userId;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        title: const Text('Catalogue DAVIDSTORE', style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 18)),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_bag_outlined, color: Color(0xFF475569)),
            onPressed: () => Navigator.pushNamed(context, '/cart'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(12)),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (val) => setState(() => _searchQuery = val.trim()),
                        decoration: InputDecoration(
                          hintText: 'Rechercher un article...',
                          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                          prefixIcon: Icon(Icons.search, color: Colors.grey.shade500, size: 20),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear, size: 18),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() => _searchQuery = '');
                                  },
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  InkWell(
                    onTap: _openSortModal,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      height: 44,
                      width: 44,
                      decoration: BoxDecoration(color: primaryColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                      child: Icon(Icons.tune_rounded, color: primaryColor, size: 22),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              color: Colors.white,
              height: 46,
              padding: const EdgeInsets.only(bottom: 8),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final cat = _categories[index];
                  final isSelected = cat == _selectedCategory;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(cat),
                      selected: isSelected,
                      selectedColor: primaryColor,
                      backgroundColor: const Color(0xFFF1F5F9),
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : const Color(0xFF475569),
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        fontSize: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(color: isSelected ? primaryColor : Colors.transparent),
                      ),
                      onSelected: (selected) {
                        if (selected) setState(() => _selectedCategory = cat);
                      },
                    ),
                  );
                },
              ),
            ),
            const Divider(height: 1, color: Color(0xFFE2E8F0)),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('products').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Erreur de chargement : ${snapshot.error}'));
                  }

                  final docs = snapshot.data?.docs ?? [];
                  final rawProducts = docs.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    data['id'] = doc.id;
                    return Product.fromMap(data);
                  }).toList();

                  final filteredProducts = _filterAndSortProducts(rawProducts);

                  if (filteredProducts.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off_rounded, size: 60, color: Colors.grey.shade300),
                          const SizedBox(height: 12),
                          const Text('Aucun produit trouvé', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
                          const SizedBox(height: 4),
                          Text('Essayez de modifier votre recherche ou filtre.', style: TextStyle(fontSize: 12, color: Colors.grey.shade400)),
                        ],
                      ),
                    );
                  }

                  return GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.68, crossAxisSpacing: 12, mainAxisSpacing: 12),
                    itemCount: filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = filteredProducts[index];
                      return userId == null
                          ? CatalogProductCard(
                              product: product,
                              isFavorite: false,
                              onTap: () => Navigator.pushNamed(context, '/product', arguments: product),
                              onToggleFavorite: () => _toggleFavorite(product),
                              onAddToCart: () => _addToCart(product),
                            )
                          : StreamBuilder<bool>(
                              stream: _favoritesService.isFavorite(userId, product.id),
                              builder: (context, favSnapshot) {
                                return CatalogProductCard(
                                  product: product,
                                  isFavorite: favSnapshot.data ?? false,
                                  onTap: () => Navigator.pushNamed(context, '/product', arguments: product),
                                  onToggleFavorite: () => _toggleFavorite(product),
                                  onAddToCart: () => _addToCart(product),
                                );
                              },
                            );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 1),
    );
  }
}
