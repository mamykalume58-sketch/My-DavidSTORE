import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../theme/app_theme.dart';
import '../../services/cart_service.dart';
import '../../utils/price_formatter.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final CartService _cartService = CartService();
  final _promoController = TextEditingController();

  String? get _userId => FirebaseAuth.instance.currentUser?.uid;

  int _sousTotal(List<Map<String, dynamic>> items) {
    return items.fold<int>(0, (sum, item) {
      final price = (item['price'] as num?)?.toInt() ?? 0;
      final quantity = (item['quantity'] as num?)?.toInt() ?? 1;
      return sum + price * quantity;
    });
  }

  Future<void> _increment(Map<String, dynamic> item) async {
    final userId = _userId;
    if (userId == null) return;
    final quantity = (item['quantity'] as num?)?.toInt() ?? 1;
    await _cartService.updateQuantity(userId, item['docId'], quantity + 1);
  }

  Future<void> _decrement(Map<String, dynamic> item) async {
    final userId = _userId;
    if (userId == null) return;
    final quantity = (item['quantity'] as num?)?.toInt() ?? 1;
    await _cartService.updateQuantity(userId, item['docId'], quantity - 1);
  }

  Future<void> _removeItem(Map<String, dynamic> item) async {
    final userId = _userId;
    if (userId == null) return;
    await _cartService.removeItem(userId, item['docId']);
  }

  @override
  void dispose() {
    _promoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userId = _userId;

    if (userId == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back, color: AppColors.navyDark),
                    ),
                    const Text(
                      'Mon panier',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.navyDark),
                    ),
                  ],
                ),
              ),
              const Expanded(
                child: Center(
                  child: Text('Connecte-toi pour voir ton panier', style: TextStyle(color: AppColors.textGrey)),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _cartService.watchCart(userId),
      builder: (context, snapshot) {
        final items = snapshot.data ?? [];
        final isLoading = snapshot.connectionState == ConnectionState.waiting;
        final sousTotal = _sousTotal(items);

        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back, color: AppColors.navyDark),
                      ),
                      Text(
                        'Mon panier (${items.length})',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.navyDark),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: isLoading
                      ? const Center(child: CircularProgressIndicator(color: AppColors.orangeDark))
                      : items.isEmpty
                          ? const Center(
                              child: Text('Votre panier est vide', style: TextStyle(color: AppColors.textGrey)),
                            )
                          : ListView.separated(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                              itemCount: items.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                final item = items[index];
                                final quantity = (item['quantity'] as num?)?.toInt() ?? 1;
                                final price = (item['price'] as num?)?.toInt() ?? 0;
                                final emoji = item['emoji']?.toString() ?? '📦';
                                final name = item['name']?.toString() ?? '';
                                final color = item['color']?.toString();
                                final size = item['size']?.toString();

                                return Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppColors.whiteMuted,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(color: Colors.grey.shade200),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 56,
                                        height: 56,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        alignment: Alignment.center,
                                        child: Text(emoji, style: const TextStyle(fontSize: 26)),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              name,
                                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textDark),
                                            ),
                                            if (size != null || color != null) ...[
                                              const SizedBox(height: 2),
                                              Text(
                                                [if (size != null) 'Taille $size', if (color != null) 'Couleur'].join(' · '),
                                                style: const TextStyle(fontSize: 11, color: AppColors.textGrey),
                                              ),
                                            ],
                                            const SizedBox(height: 4),
                                            Text(
                                              formatPrice(price),
                                              style: const TextStyle(fontSize: 13, color: AppColors.orangeDark, fontWeight: FontWeight.bold),
                                            ),
                                            const SizedBox(height: 8),
                                            Row(
                                              children: [
                                                _qtyButton(Icons.remove, () => _decrement(item)),
                                                Container(
                                                  width: 32,
                                                  alignment: Alignment.center,
                                                  child: Text('$quantity', style: const TextStyle(fontWeight: FontWeight.bold)),
                                                ),
                                                _qtyButton(Icons.add, () => _increment(item)),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () => _removeItem(item),
                                        icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                ),

                if (items.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 12, offset: const Offset(0, -4)),
                      ],
                    ),
                    child: SafeArea(
                      top: false,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text('Vous avez un code promo ?', style: TextStyle(fontSize: 13, color: AppColors.textGrey)),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: AppColors.whiteMuted,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: Colors.grey.shade300),
                                  ),
                                  child: TextField(
                                    controller: _promoController,
                                    decoration: const InputDecoration(
                                      hintText: 'Entrer le code',
                                      hintStyle: TextStyle(fontSize: 13, color: Colors.grey),
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              OutlinedButton(
                                onPressed: () {},
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: AppColors.orangeDark),
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                                child: const Text('Appliquer', style: TextStyle(color: AppColors.orangeDark)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Sous-total', style: TextStyle(color: AppColors.textGrey)),
                              Text(formatPrice(sousTotal), style: const TextStyle(fontWeight: FontWeight.w600)),
                            ],
                          ),
                          const SizedBox(height: 6),
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Livraison', style: TextStyle(color: AppColors.textGrey)),
                              Text('Gratuite', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.green)),
                            ],
                          ),
                          const Divider(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Total', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.navyDark)),
                              Text(
                                formatPrice(sousTotal),
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.orangeDark),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => Navigator.pushNamed(
                              context,
                              '/checkout',
                              arguments: {'amount': sousTotal, 'userId': userId},
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.orangeDark,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                            child: const Text(
                              'Passer la commande',
                              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _qtyButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6)),
        child: Icon(icon, size: 16, color: AppColors.navyDark),
      ),
    );
  }
}
