import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/product.dart';
import '../utils/price_formatter.dart';

class CatalogProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;
  final VoidCallback onAddToCart;
  final VoidCallback onToggleFavorite;
  final bool isFavorite;

  const CatalogProductCard({
    super.key,
    required this.product,
    required this.onTap,
    required this.onAddToCart,
    required this.onToggleFavorite,
    this.isFavorite = false,
  });

  Widget _buildProductImage(String source, String fallbackEmoji) {
    try {
      if (source.startsWith('data:image')) {
        final base64Str = source.split(',').last;
        return Image.memory(
          base64Decode(base64Str),
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Text(fallbackEmoji, style: const TextStyle(fontSize: 36)),
        );
      } else if (source.startsWith('http')) {
        return Image.network(
          source,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Text(fallbackEmoji, style: const TextStyle(fontSize: 36)),
        );
      } else {
        return Image.memory(
          base64Decode(source),
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Text(fallbackEmoji, style: const TextStyle(fontSize: 36)),
        );
      }
    } catch (_) {
      return Text(fallbackEmoji, style: const TextStyle(fontSize: 36));
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200, width: 1),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 3)),
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
                      color: const Color(0xFFF1F5F9),
                      alignment: Alignment.center,
                      child: product.images.isNotEmpty
                          ? _buildProductImage(product.images.first, product.emoji)
                          : Text(product.emoji, style: const TextStyle(fontSize: 36)),
                    ),
                  ),
                  if (product.hasPromo)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(color: Colors.red.shade600, borderRadius: BorderRadius.circular(6)),
                        child: const Text('PROMO', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  if (!product.inStock)
                    Positioned(
                      top: product.hasPromo ? 30 : 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(color: Colors.grey.shade700, borderRadius: BorderRadius.circular(6)),
                        child: const Text('RUPTURE', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: InkWell(
                      onTap: onToggleFavorite,
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.9), shape: BoxShape.circle),
                        child: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          size: 16,
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
                    style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: Colors.grey.shade500, letterSpacing: 0.5),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(product.priceDisplay, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: primaryColor)),
                          if (product.hasPromo)
                            Text(
                              formatPriceStrike(product.price),
                              style: const TextStyle(fontSize: 9, decoration: TextDecoration.lineThrough, color: Colors.grey),
                            ),
                        ],
                      ),
                      InkWell(
                        onTap: product.inStock ? onAddToCart : null,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: product.inStock ? primaryColor : Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.add_shopping_cart_rounded, size: 16, color: Colors.white),
                        ),
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
