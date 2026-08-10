import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/product.dart';
import '../../services/cart_service.dart';
import '../../services/favorites_service.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  static const orange = Color(0xFFFF6B35);
  static const navy = Color(0xFF0A1030);

  final CartService _cartService = CartService();
  final FavoritesService _favoritesService = FavoritesService();

  int _quantity = 1;
  int _selectedColorIndex = 0;
  int _selectedSizeIndex = 0;
  int _selectedImageIndex = 0;
  bool _isAddingToCart = false;

  String? get _userId => FirebaseAuth.instance.currentUser?.uid;

  Color _colorFromHex(String hex) {
    final cleaned = hex.replaceAll('#', '');
    return Color(int.parse('FF$cleaned', radix: 16));
  }

  void _incrementQuantity() {
    setState(() => _quantity++);
  }

  void _decrementQuantity() {
    if (_quantity > 1) setState(() => _quantity--);
  }

  Future<void> _addToCart(Product product) async {
    final userId = _userId;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Connecte-toi pour ajouter au panier')),
      );
      return;
    }

    setState(() => _isAddingToCart = true);
    try {
      await _cartService.addToCart(
        userId: userId,
        product: product,
        color: product.colors[_selectedColorIndex],
        size: product.sizes[_selectedSizeIndex],
        quantity: _quantity,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Produit ajouté au panier')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur lors de l\'ajout au panier')),
      );
    } finally {
      if (mounted) setState(() => _isAddingToCart = false);
    }
  }

  Future<void> _buyNow(Product product) async {
    await _addToCart(product);
    if (!mounted) return;
    Navigator.pushNamed(context, '/cart');
  }

  Future<void> _toggleFavorite(Product product) async {
    final userId = _userId;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Connecte-toi pour ajouter aux favoris')),
      );
      return;
    }
    await _favoritesService.toggleFavorite(userId, product);
  }

  @override
  Widget build(BuildContext context) {
    final product = ModalRoute.of(context)!.settings.arguments as Product?;

    if (product == null) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: Text('Produit introuvable')),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 320,
                  width: double.infinity,
                  color: const Color(0xFFF5F5F7),
                  child: Center(
                    child: Text(product.emoji, style: const TextStyle(fontSize: 100)),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Row(
                    children: List.generate(4, (index) {
                      final isSelected = _selectedImageIndex == index;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedImageIndex = index),
                        child: Container(
                          margin: const EdgeInsets.only(right: 10),
                          width: 56,
                          height: 56,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F5F7),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isSelected ? orange : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          child: Text(product.emoji, style: const TextStyle(fontSize: 24)),
                        ),
                      );
                    }),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: navy),
                      ),

                      const SizedBox(height: 8),

                      Row(
                        children: [
                          Row(
                            children: List.generate(5, (index) {
                              return Icon(
                                index < product.rating.floor() ? Icons.star : Icons.star_half,
                                size: 16,
                                color: orange,
                              );
                            }),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${product.rating} (${product.reviewCount} avis)',
                            style: const TextStyle(fontSize: 13, color: Colors.black54),
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),

                      Text(
                        product.priceDisplay,
                        style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: orange),
                      ),

                      const SizedBox(height: 4),

                      const Text(
                        'En stock',
                        style: TextStyle(fontSize: 13, color: Colors.green, fontWeight: FontWeight.w600),
                      ),

                      const SizedBox(height: 20),

                      const Text(
                        'Couleur',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: navy),
                      ),

                      const SizedBox(height: 10),

                      Row(
                        children: List.generate(product.colors.length, (index) {
                          final isSelected = _selectedColorIndex == index;
                          return GestureDetector(
                            onTap: () => setState(() => _selectedColorIndex = index),
                            child: Container(
                              margin: const EdgeInsets.only(right: 12),
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                color: _colorFromHex(product.colors[index]),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected ? orange : const Color(0xFFE0E0E0),
                                  width: isSelected ? 3 : 1,
                                ),
                              ),
                            ),
                          );
                        }),
                      ),

                      const SizedBox(height: 20),

                      const Text(
                        'Taille',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: navy),
                      ),

                      const SizedBox(height: 10),

                      Row(
                        children: List.generate(product.sizes.length, (index) {
                          final isSelected = _selectedSizeIndex == index;
                          return GestureDetector(
                            onTap: () => setState(() => _selectedSizeIndex = index),
                            child: Container(
                              margin: const EdgeInsets.only(right: 10),
                              width: 44,
                              height: 36,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: isSelected ? orange : const Color(0xFFF5F5F7),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isSelected ? orange : const Color(0xFFE0E0E0),
                                ),
                              ),
                              child: Text(
                                product.sizes[index],
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected ? Colors.white : navy,
                                ),
                              ),
                            ),
                          );
                        }),
                      ),

                      const SizedBox(height: 20),

                      const Text(
                        'Quantité',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: navy),
                      ),

                      const SizedBox(height: 10),

                      Row(
                        children: [
                          _quantityButton(Icons.remove, _decrementQuantity),
                          Container(
                            width: 50,
                            alignment: Alignment.center,
                            child: Text(
                              '$_quantity',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: navy),
                            ),
                          ),
                          _quantityButton(Icons.add, _incrementQuantity),
                        ],
                      ),

                      if (product.description.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        const Text(
                          'Description',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: navy),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          product.description,
                          style: const TextStyle(fontSize: 14, color: Colors.black54, height: 1.5),
                        ),
                      ],

                      if (product.characteristics.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        const Text(
                          'Caractéristiques',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: navy),
                        ),
                        const SizedBox(height: 8),
                        ...product.characteristics.map(
                          (item) => Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Row(
                              children: [
                                const Icon(Icons.check_circle, size: 16, color: orange),
                                const SizedBox(width: 8),
                                Text(item, style: const TextStyle(fontSize: 13, color: Colors.black54)),
                              ],
                            ),
                          ),
                        ),
                      ],

                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ],
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _circleIconButton(Icons.arrow_back, () => Navigator.pop(context)),
                  Row(
                    children: [
                      _circleIconButton(Icons.share, () {}),
                      const SizedBox(width: 8),
                      _userId == null
                          ? _circleIconButton(
                              Icons.favorite_border,
                              () => _toggleFavorite(product),
                            )
                          : StreamBuilder<bool>(
                              stream: _favoritesService.isFavorite(_userId!, product.id),
                              builder: (context, snapshot) {
                                final isFav = snapshot.data ?? false;
                                return _circleIconButton(
                                  isFav ? Icons.favorite : Icons.favorite_border,
                                  () => _toggleFavorite(product),
                                  iconColor: isFav ? orange : navy,
                                );
                              },
                            ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 12, offset: const Offset(0, -4)),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _isAddingToCart ? null : () => _addToCart(product),
                        icon: const Icon(Icons.shopping_cart_outlined, color: orange),
                        label: const Text(
                          'Ajouter au panier',
                          style: TextStyle(color: orange, fontWeight: FontWeight.w600),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: const BorderSide(color: orange),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isAddingToCart ? null : () => _buyNow(product),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: orange,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: const Text(
                          'Acheter maintenant',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _quantityButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(color: const Color(0xFFF5F5F7), borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, size: 18, color: navy),
      ),
    );
  }

  Widget _circleIconButton(IconData icon, VoidCallback onTap, {Color iconColor = navy}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 6)],
        ),
        child: Icon(icon, size: 20, color: iconColor),
      ),
    );
  }
}
