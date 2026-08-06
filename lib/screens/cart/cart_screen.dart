import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class CartItem {
  final String name;
  final String price;
  int quantity;

  CartItem({required this.name, required this.price, this.quantity = 1});
}

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final List<CartItem> _items = [
    CartItem(name: 'iPhone 14 Pro', price: '1 250 000 FC'),
    CartItem(name: 'Casque sans fil Premium', price: '80 000 FC'),
    CartItem(name: 'Sac à dos', price: '45 000 FC'),
  ];

  final _promoController = TextEditingController();

  int _parsePrice(String price) {
    return int.parse(price.replaceAll(RegExp(r'[^0-9]'), ''));
  }

  String _formatPrice(int value) {
    final str = value.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) buffer.write(' ');
      buffer.write(str[i]);
    }
    return '${buffer.toString()} FC';
  }

  int get _sousTotal {
    return _items.fold(0, (sum, item) => sum + _parsePrice(item.price) * item.quantity);
  }

  void _increment(CartItem item) {
    setState(() => item.quantity++);
  }

  void _decrement(CartItem item) {
    setState(() {
      if (item.quantity > 1) item.quantity--;
    });
  }

  void _removeItem(CartItem item) {
    setState(() => _items.remove(item));
  }

  @override
  void dispose() {
    _promoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                    'Mon panier (${_items.length})',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.navyDark),
                  ),
                ],
              ),
            ),

            Expanded(
              child: _items.isEmpty
                  ? const Center(
                      child: Text('Votre panier est vide', style: TextStyle(color: AppColors.textGrey)),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      itemCount: _items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final item = _items[index];
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
                                child: const Icon(Icons.shopping_bag_outlined, color: AppColors.orangeDark),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.name,
                                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textDark),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      item.price,
                                      style: const TextStyle(fontSize: 13, color: AppColors.orangeDark, fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        _qtyButton(Icons.remove, () => _decrement(item)),
                                        Container(
                                          width: 32,
                                          alignment: Alignment.center,
                                          child: Text('${item.quantity}', style: const TextStyle(fontWeight: FontWeight.bold)),
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

            if (_items.isNotEmpty)
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
                          Text(_formatPrice(_sousTotal), style: const TextStyle(fontWeight: FontWeight.w600)),
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
                            _formatPrice(_sousTotal),
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.orangeDark),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => Navigator.pushNamed(context, '/checkout'),
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
