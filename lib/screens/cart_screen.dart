import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'delivery_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final List<Map<String, dynamic>> _items = [
    {
      'name': 'Smartphone Samsung\nGalaxy A14 64GB',
      'price': 250000,
      'qty': 1,
    },
    {
      'name': 'Casque Bluetooth\nSony WH-CH520',
      'price': 25000,
      'qty': 1,
    },
    {
      'name': 'Enceinte JBL\nCharge 5',
      'price': 60000,
      'qty': 1,
    },
  ];

  int get _sousTotal =>
      _items.fold(0, (sum, item) => sum + item['price'] * item['qty'] as int);

  String _formatPrice(int price) {
    return '${price.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}.000 FC';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text('Mon panier (${_items.length})',
            style: const TextStyle(
                color: AppColors.textDark,
                fontSize: 18,
                fontWeight: FontWeight.w700)),
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text('Modifier',
                style: TextStyle(color: AppColors.orangeDark)),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _items.length,
              separatorBuilder: (_, __) =>
                  const Divider(height: 1, color: Color(0xFFF0F0F0)),
              itemBuilder: (context, index) {
                final item = _items[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF7F7F7),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.image_outlined,
                            color: AppColors.textGrey),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item['name'],
                                style: const TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textDark,
                                    fontWeight: FontWeight.w500)),
                            const SizedBox(height: 6),
                            Text(
                              '${(item['price'] as int) ~/ 1000}.000 FC',
                              style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.orangeDark),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                _qtyButton(
                                  icon: Icons.remove,
                                  onTap: () {
                                    setState(() {
                                      if (item['qty'] > 1) item['qty']--;
                                    });
                                  },
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12),
                                  child: Text('${item['qty']}',
                                      style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textDark)),
                                ),
                                _qtyButton(
                                  icon: Icons.add,
                                  onTap: () {
                                    setState(() => item['qty']++);
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline,
                            color: AppColors.textGrey),
                        onPressed: () {
                          setState(() => _items.removeAt(index));
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: AppColors.white,
              border: Border(
                  top: BorderSide(color: Color(0xFFF0F0F0))),
            ),
            child: Column(
              children: [
                _summaryRow('Sous-total',
                    '${_sousTotal ~/ 1000}.000 FC'),
                const SizedBox(height: 8),
                _summaryRow('Livraison', 'Gratuite',
                    valueColor: Colors.green),
                const Divider(height: 24),
                _summaryRow('Total', '${_sousTotal ~/ 1000}.000 FC',
                    isBold: true),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const DeliveryScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.orangeDark,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Passer la commande',
                      style: TextStyle(
                          color: AppColors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _qtyButton(
      {required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFEEEEEE)),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, size: 16, color: AppColors.textDark),
      ),
    );
  }

  Widget _summaryRow(String label, String value,
      {bool isBold = false, Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(
                fontSize: isBold ? 16 : 14,
                fontWeight:
                    isBold ? FontWeight.w700 : FontWeight.normal,
                color: AppColors.textDark)),
        Text(value,
            style: TextStyle(
                fontSize: isBold ? 16 : 14,
                fontWeight:
                    isBold ? FontWeight.w700 : FontWeight.normal,
                color: valueColor ?? AppColors.textDark)),
      ],
    );
  }
}
