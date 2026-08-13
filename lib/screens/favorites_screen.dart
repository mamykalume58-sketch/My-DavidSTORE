import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/app_theme.dart';
import '../models/product.dart';
import '../services/favorites_service.dart';
import '../utils/price_formatter.dart';
import '../widgets/custom_bottom_nav_bar.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  String? get _userId => FirebaseAuth.instance.currentUser?.uid;

  Future<void> _removeFavorite(String productId, Map<String, dynamic> item) async {
    final userId = _userId;
    if (userId == null) return;
    final product = Product(
      id: productId,
      name: item['name']?.toString() ?? '',
      price: (item['price'] as num?)?.toInt() ?? 0,
      emoji: item['emoji']?.toString() ?? '📦',
      category: '',
    );
    await FavoritesService().toggleFavorite(userId, product);
  }

  Widget _buildThumb(String source, String fallbackEmoji) {
    if (source.isEmpty) {
      return Text(fallbackEmoji, style: const TextStyle(fontSize: 28));
    }
    try {
      if (source.startsWith('data:image')) {
        final base64Str = source.split(',').last;
        return Image.memory(
          base64Decode(base64Str),
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Text(fallbackEmoji, style: const TextStyle(fontSize: 28)),
        );
      } else if (source.startsWith('http')) {
        return Image.network(
          source,
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Text(fallbackEmoji, style: const TextStyle(fontSize: 28)),
        );
      } else {
        return Image.memory(
          base64Decode(source),
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Text(fallbackEmoji, style: const TextStyle(fontSize: 28)),
        );
      }
    } catch (_) {
      return Text(fallbackEmoji, style: const TextStyle(fontSize: 28));
    }
  }

  @override
  Widget build(BuildContext context) {
    final userId = _userId;

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text('Favoris',
            style: TextStyle(
                color: AppColors.textDark,
                fontSize: 18,
                fontWeight: FontWeight.w700)),
      ),
      body: userId == null
          ? _buildEmptyState(context, message: 'Connecte-toi pour voir tes favoris')
          : StreamBuilder<List<Map<String, dynamic>>>(
              stream: FavoritesService().watchFavorites(userId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.orangeDark));
                }

                final favorites = snapshot.data ?? [];

                if (favorites.isEmpty) {
                  return _buildEmptyState(context);
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: favorites.length,
                  separatorBuilder: (_, __) =>
                      const Divider(height: 1, color: Color(0xFFF0F0F0)),
                  itemBuilder: (context, index) {
                    final item = favorites[index];
                    final productId = item['productId']?.toString() ?? item['docId'].toString();
                    final name = item['name']?.toString() ?? '';
                    final price = (item['price'] as num?)?.toInt() ?? 0;
                    final emoji = item['emoji']?.toString() ?? '📦';
                    final image = item['image']?.toString() ?? '';

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              width: 64,
                              height: 64,
                              alignment: Alignment.center,
                              color: const Color(0xFFF7F7F7),
                              child: _buildThumb(image, emoji),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(name,
                                    style: const TextStyle(
                                        fontSize: 14,
                                        color: AppColors.textDark,
                                        fontWeight: FontWeight.w500)),
                                const SizedBox(height: 6),
                                Text(formatPrice(price),
                                    style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.orangeDark)),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.favorite,
                                color: AppColors.orangeDark),
                            onPressed: () => _removeFavorite(productId, item),
                          ),
                        ],
                      ),
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
          const Icon(Icons.favorite_border,
              size: 60, color: AppColors.textGrey),
          const SizedBox(height: 16),
          Text(message,
              style: const TextStyle(color: AppColors.textGrey, fontSize: 15)),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/catalog'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.orangeDark,
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: const Text('Découvrir des produits',
                style: TextStyle(color: AppColors.white)),
          ),
        ],
      ),
    );
  }
}
