import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/product.dart';
import '../utils/price_formatter.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;
  final VoidCallback onAddToCart;
  final VoidCallback onFavoriteToggle;
  final bool isFavorite;

  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
    required this.onAddToCart,
    required this.onFavoriteToggle,
    this.isFavorite = false,
  });

  Widget _buildProductImage(String source, String fallbackEmoji) {
    try {
      if (source.startsWith('data:image')) {
        final base64Str = source.split(',').last;
        return Image.memory(
          base64Decode(base64Str),
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) =>
              Text(fallbackEmoji, style: const TextStyle(fontSize: 40)),
        );
      } else if (source.startsWith('http')) {
        return Image.network(
          source,
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) =>
              Text(fallbackEmoji, style: const TextStyle(fontSize: 40)),
        );
      } else {
        return Image.memory(
          base64Decode(source),
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) =>
              Text(fallbackEmoji, style: const TextStyle(fontSize: 40)),
        );
      }
    } catch (_) {
      return Text(fallbackEmoji, style: const TextStyle(fontSize: 40));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    child: Container(
                      width: double.infinity,
                      color: Colors.grey.shade100,
                      alignment: Alignment.center,
                      child: product.images.isNotEmpty
                          ? _buildProductImage(product.images.first, product.emoji)
                          : Text(product.emoji, style: const TextStyle(fontSize: 40)),
                    ),
                  ),
                  if (!product.inStock)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'RUPTURE',
                          style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: InkWell(
                      onTap: onFavoriteToggle,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                        child: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          size: 18,
                          color: isFavorite ? Colors.red : Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.category.toUpperCase(),
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.grey.shade500, letterSpacing: 0.5),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.priceDisplay,
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: theme.primaryColor),
                          ),
                          if (product.hasPromo)
                            Text(
                              formatPriceStrike(product.price),
                              style: const TextStyle(fontSize: 10, decoration: TextDecoration.lineThrough, color: Colors.grey),
                            ),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          InkWell(
                            onTap: onTap,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                border: Border.all(color: theme.primaryColor),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text('Voir', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: theme.primaryColor)),
                            ),
                          ),
                          const SizedBox(width: 6),
                          InkWell(
                            onTap: product.inStock ? onAddToCart : null,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: product.inStock ? theme.primaryColor : Colors.grey.shade300,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.add_shopping_cart, size: 16, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
