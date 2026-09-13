import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/product.dart';

class MiniProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;
  final VoidCallback onAddToCart;

  const MiniProductCard({
    super.key,
    required this.product,
    required this.onTap,
    required this.onAddToCart,
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
              Text(fallbackEmoji, style: const TextStyle(fontSize: 32)),
        );
      } else if (source.startsWith('http')) {
        return Image.network(
          source,
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) =>
              Text(fallbackEmoji, style: const TextStyle(fontSize: 32)),
        );
      } else {
        return Image.memory(
          base64Decode(source),
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) =>
              Text(fallbackEmoji, style: const TextStyle(fontSize: 32)),
        );
      }
    } catch (_) {
      return Text(fallbackEmoji, style: const TextStyle(fontSize: 32));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 130,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
              child: Container(
                height: 90,
                width: double.infinity,
                color: Colors.grey.shade100,
                alignment: Alignment.center,
                child: product.images.isNotEmpty
                    ? _buildProductImage(product.images.first, product.emoji)
                    : Text(product.emoji, style: const TextStyle(fontSize: 32)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          product.priceDisplay,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: theme.primaryColor),
                        ),
                      ),
                      InkWell(
                        onTap: product.inStock ? onAddToCart : null,
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: product.inStock ? theme.primaryColor : Colors.grey.shade300,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.add, size: 14, color: Colors.white),
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
