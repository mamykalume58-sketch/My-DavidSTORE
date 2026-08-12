import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/cart_service.dart';
import '../../widgets/cart_item_card.dart';
import '../../widgets/cart_summary.dart';

class CartScreen extends StatelessWidget {
  final CartService _cartService = CartService();

  CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final String? userId = FirebaseAuth.instance.currentUser?.uid;
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF0F172A), size: 18),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: const Text('Mon Panier', style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 18)),
        actions: [
          if (userId != null)
            IconButton(
              icon: const Icon(Icons.delete_sweep_outlined, color: Colors.redAccent),
              tooltip: 'Vider le panier',
              onPressed: () => _confirmClearCart(context, userId),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: userId == null
          ? _buildUnauthenticatedState(context)
          : StreamBuilder<List<Map<String, dynamic>>>(
              stream: _cartService.watchCart(userId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Erreur de chargement : ${snapshot.error}'));
                }

                final cartItems = snapshot.data ?? [];

                if (cartItems.isEmpty) {
                  return _buildEmptyState(context);
                }

                final int subtotal = cartItems.fold<int>(0, (sum, item) {
                  final int price = (item['price'] is double) ? (item['price'] as double).toInt() : (item['price'] ?? 0);
                  final int qty = item['quantity'] ?? 1;
                  return sum + (price * qty);
                });

                return Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: cartItems.length,
                        itemBuilder: (context, index) {
                          final item = cartItems[index];
                          final String docId = item['docId'] ?? '';

                          return CartItemCard(
                            item: item,
                            onQuantityChanged: (newQty) => _cartService.updateQuantity(userId, docId, newQty),
                            onDelete: () => _cartService.removeItem(userId, docId),
                          );
                        },
                      ),
                    ),
                    CartSummary(
                      subtotal: subtotal,
                      deliveryFee: 3000,
                      onCheckout: () => Navigator.pushNamed(context, '/checkout'),
                    ),
                  ],
                );
              },
            ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: primaryColor.withValues(alpha: 0.08), shape: BoxShape.circle),
              child: Icon(Icons.shopping_bag_outlined, size: 64, color: primaryColor),
            ),
            const SizedBox(height: 20),
            const Text('Votre panier est vide', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
            const SizedBox(height: 8),
            Text(
              'Découvrez nos meilleures collections et ajoutez des articles à votre panier.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/catalog'),
                style: ElevatedButton.styleFrom(backgroundColor: primaryColor, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                child: const Text('Continuer mes achats', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUnauthenticatedState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_outline_rounded, size: 56, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('Veuillez vous connecter pour voir votre panier', textAlign: TextAlign.center, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/profile'),
              child: const Text('Se connecter'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmClearCart(BuildContext context, String userId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Vider le panier'),
        content: const Text('Voulez-vous vraiment supprimer tous les articles ?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
          TextButton(
            onPressed: () {
              _cartService.clearCart(userId);
              Navigator.pop(ctx);
            },
            child: const Text('Vider', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
