import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/app_theme.dart';
import '../models/product.dart';
import '../services/cart_service.dart';
import '../services/favorites_service.dart';
import '../widgets/catalog_sort_modal.dart';
import '../widgets/custom_bottom_nav_bar.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final CartService _cartService = CartService();
  final FavoritesService _favoritesService = FavoritesService();
  SortOption _currentSort = SortOption.newest;

  String? get _userId => FirebaseAuth.instance.currentUser?.uid;

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

  List<Product> _sortProducts(List<Product> products) {
    final sorted = List<Product>.from(products);
    sorted.sort((a, b) {
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
    return sorted;
  }

  Future<List<Product>> _fetchProducts(List<String> productIds) async {
    final docs = await Future.wait(
      productIds.map((id) => FirebaseFirestore.instance.collection('products').doc(id).get()),
    );
    return docs.where((doc) => doc.exists).map((doc) {
      final data = doc.data()!;
      data['id'] = doc.id;
      return Product.fromMap(data);
    }).toList();
  }

  void _addToCart(Product product) {
    final userId = _userId;
    if (userId == null) return;
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

  Widget _buildImage(String source, String fallbackEmoji) {
    if (source.isEmpty) {
      return Text(fallbackEmoji, style: const TextStyle(fontSize: 32));
    }
    try {
      if (source.startsWith('data:image')) {
        final base64Str = source.split(',').last;
        return Image.memory(base64Decode(base64Str), width: double.infinity, height: double.infinity, fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Text(fallbackEmoji, style: const TextStyle(fontSize: 32)));
      } else if (source.startsWith('http')) {
        return Image.network(source, width: double.infinity, height: double.infinity, fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Text(fallbackEmoji, style: const TextStyle(fontSize: 32)));
      } else {
        return Image.memory(base64Decode(source), width: double.infinity, height: double.infinity, fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Text(fallbackEmoji, style: const TextStyle(fontSize: 32)));
      }
    } catch (_) {
      return Text(fallbackEmoji, style: const TextStyle(fontSize: 32));
    }
  }

  @override
  Widget build(BuildContext context) {
    final userId = _userId;
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAFC),
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 16,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Mes favoris', style: TextStyle(color: AppColors.textDark, fontSize: 22, fontWeight: FontWeight.w800)),
            SizedBox(height: 2),
            Text('Vos produits préférés enregistrés', style: TextStyle(color: Color(0xFF64748B), fontSize: 12, fontWeight: FontWeight.normal)),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: OutlinedButton.icon(
              onPressed: _openSortModal,
              icon: Icon(Icons.tune_rounded, size: 16, color: primaryColor),
              label: Text('Trier', style: TextStyle(color: primaryColor, fontWeight: FontWeight.w600, fontSize: 13)),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: primaryColor),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              ),
            ),
          ),
        ],
      ),
      body: userId == null
          ? _buildEmptyState(context, message: 'Connecte-toi pour voir tes favoris')
          : StreamBuilder<List<Map<String, dynamic>>>(
              stream: _favoritesService.watchFavorites(userId),
              builder: (context, favSnapshot) {
                if (favSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.orangeDark));
                }

                final favorites = favSnapshot.data ?? [];

                if (favorites.isEmpty) {
                  return _buildEmptyState(context);
                }

                final productIds = favorites.map((f) => f['productId']?.toString() ?? f['docId'].toString()).toList();

                return FutureBuilder<List<Product>>(
                  future: _fetchProducts(productIds),
                  builder: (context, prodSnapshot) {
                    if (prodSnapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator(color: AppColors.orangeDark));
                    }

                    final products = _sortProducts(prodSnapshot.data ?? []);

                    if (products.isEmpty) {
                      return _buildEmptyState(context);
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final product = products[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  width: 90,
                                  height: 90,
                                  alignment: Alignment.center,
                                  color: const Color(0xFFF1F5F9),
                                  child: product.images.isNotEmpty
                                      ? _buildImage(product.images.first, product.emoji)
                                      : Text(product.emoji, style: const TextStyle(fontSize: 32)),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Text(product.name,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                                        ),
                                        InkWell(
                                          onTap: () => _favoritesService.removeFavorite(userId, product.id),
                                          child: Container(
                                            padding: const EdgeInsets.all(6),
                                            decoration: BoxDecoration(color: Colors.red.shade50, shape: BoxShape.circle),
                                            child: const Icon(Icons.favorite, size: 16, color: Colors.red),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Text(product.category, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                                    const SizedBox(height: 6),
                                    Text(product.priceDisplay,
                                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: primaryColor)),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(Icons.star, size: 14, color: Color(0xFFF59E0B)),
                                        const SizedBox(width: 4),
                                        Text('${product.rating} (${product.reviewCount})', style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        InkWell(
                                          onTap: () => Navigator.pushNamed(context, '/product', arguments: product),
                                          child: Container(
                                            padding: const EdgeInsets.all(9),
                                            decoration: BoxDecoration(
                                              border: Border.all(color: primaryColor),
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            child: Icon(Icons.shopping_cart_outlined, size: 16, color: primaryColor),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: InkWell(
                                            onTap: product.inStock ? () => _addToCart(product) : null,
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(vertical: 10),
                                              alignment: Alignment.center,
                                              decoration: BoxDecoration(
                                                color: product.inStock ? primaryColor : Colors.grey.shade300,
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                              child: const Text('Ajouter au panier',
                                                  style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 2),
    );
  }

  Widget _buildEmptyState(BuildContext context, {String message = 'Aucun favori pour le moment'}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.favorite_border, size: 60, color: AppColors.textGrey),
          const SizedBox(height: 16),
          Text(message, style: const TextStyle(color: AppColors.textGrey, fontSize: 15)),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/catalog'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.orangeDark,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
            child: const Text('Découvrir des produits', style: TextStyle(color: AppColors.white)),
          ),
        ],
      ),
    );
  }
}
