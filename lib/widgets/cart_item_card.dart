import 'package:flutter/material.dart';
import '../utils/price_formatter.dart';
import 'dart:convert';

class CartItemCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final Function(int) onQuantityChanged;
  final VoidCallback onDelete;

  const CartItemCard({
    super.key,
    required this.item,
    required this.onQuantityChanged,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final String name = item['name'] ?? 'Produit';
    final int price = (item['price'] is double) ? (item['price'] as double).toInt() : (item['price'] ?? 0);
    final int quantity = item['quantity'] ?? 1;
    final String? size = item['size'];
    final String? color = item['color'];
    final String emoji = item['emoji'] ?? '🛍️';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(12)),
            alignment: Alignment.center,
            clipBehavior: Clip.antiAlias,
            child: (item['image'] != null && (item['image'] as String).isNotEmpty)
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.memory(
                      base64Decode((item['image'] as String).contains(',')
                          ? (item['image'] as String).split(',').last
                          : item['image'] as String),
                      width: 72,
                      height: 72,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          Text(emoji, style: const TextStyle(fontSize: 28)),
                    ),
                  )
                : Text(emoji, style: const TextStyle(fontSize: 28)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                      ),
                    ),
                    InkWell(
                      onTap: onDelete,
                      borderRadius: BorderRadius.circular(20),
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Icon(Icons.delete_outline_rounded, size: 18, color: Colors.red.shade400),
                      ),
                    ),
                  ],
                ),
                if ((size != null && size.isNotEmpty) || (color != null && color.isNotEmpty)) ...[
                  const SizedBox(height: 2),
                  Text(
                    [
                      if (size != null && size.isNotEmpty) 'Taille: $size',
                      if (color != null && color.isNotEmpty) 'Couleur: $color',
                    ].join(' • '),
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                  ),
                ],
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      formatPrice(price),
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Theme.of(context).primaryColor),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        children: [
                          _buildQtyButton(
                            icon: Icons.remove,
                            onTap: () {
                              if (quantity > 1) {
                                onQuantityChanged(quantity - 1);
                              } else {
                                onDelete();
                              }
                            },
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Text('$quantity', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                          ),
                          _buildQtyButton(icon: Icons.add, onTap: () => onQuantityChanged(quantity + 1)),
                        ],
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
  }

  Widget _buildQtyButton({required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(padding: const EdgeInsets.all(6.0), child: Icon(icon, size: 14, color: const Color(0xFF334155))),
    );
  }
}
