import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'cart_screen.dart';

class ProductScreen extends StatefulWidget {
  final String name;
  final int price;
  final int oldPrice;
  final String discount;

  const ProductScreen({
    super.key,
    required this.name,
    required this.price,
    required this.oldPrice,
    required this.discount,
  });

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  int _qty = 1;
  int _selectedColor = 0;

  final List<Color> _colors = [
    Colors.black,
    Colors.grey,
    const Color(0xFFFFB6C1),
    AppColors.navyDark,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Détail du produit',
            style: TextStyle(
                color: AppColors.textDark,
                fontSize: 18,
                fontWeight: FontWeight.w700)),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border,
                color: AppColors.textDark),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image produit
            Stack(
              children: [
                Container(
                  height: 280,
                  width: double.infinity,
                  color: const Color(0xFFF7F7F7),
                  child: const Icon(Icons.image_outlined,
                      size: 80, color: AppColors.textGrey),
                ),
                Positioned(
                  bottom: 12,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(4, (i) {
                      return Container(
                        width: i == 0 ? 20 : 8,
                        height: 8,
                        margin:
                            const EdgeInsets.symmetric(horizontal: 3),
                        decoration: BoxDecoration(
                          color: i == 0
                              ? AppColors.orangeDark
                              : const Color(0xFFDDDDDD),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nom
                  Text(widget.name,
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textDark)),
                  const SizedBox(height: 12),

                  // Prix + stock
                  Row(
                    children: [
                      Text(
                        '${widget.price ~/ 1000}.000 FC',
                        style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: AppColors.orangeDark),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.orangeDark.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(widget.discount,
                            style: const TextStyle(
                                color: AppColors.orangeDark,
                                fontSize: 12,
                                fontWeight: FontWeight.w700)),
                      ),
                      const Spacer(),
                      const Text('En stock',
                          style: TextStyle(
                              color: Colors.green,
                              fontSize: 13,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${widget.oldPrice ~/ 1000}.000 FC',
                    style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textGrey,
                        decoration: TextDecoration.lineThrough),
                  ),
                  const SizedBox(height: 20),

                  // Couleur
                  const Text('Couleur',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark)),
                  const SizedBox(height: 10),
                  Row(
                    children: _colors.asMap().entries.map((entry) {
                      final i = entry.key;
                      final color = entry.value;
                      return GestureDetector(
                        onTap: () =>
                            setState(() => _selectedColor = i),
                        child: Container(
                          width: 36,
                          height: 36,
                          margin: const EdgeInsets.only(right: 10),
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: _selectedColor == i
                                  ? AppColors.orangeDark
                                  : Colors.transparent,
                              width: 2,
                            ),
                            boxShadow: _selectedColor == i
                                ? [
                                    BoxShadow(
                                      color: AppColors.orangeDark
                                          .withOpacity(0.3),
                                      blurRadius: 6,
                                    )
                                  ]
                                : [],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  // Quantité
                  const Text('Quantité',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _qtyButton(
                        icon: Icons.remove,
                        onTap: () {
                          if (_qty > 1)
                            setState(() => _qty--);
                        },
                      ),
                      Padding(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 20),
                        child: Text('$_qty',
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textDark)),
                      ),
                      _qtyButton(
                        icon: Icons.add,
                        onTap: () => setState(() => _qty++),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // Bouton Ajouter au panier
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.shopping_cart_outlined,
                          color: AppColors.white),
                      label: const Text('Ajouter au panier',
                          style: TextStyle(
                              color: AppColors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.navyDark,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Bouton Acheter maintenant
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const CartScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.orangeDark,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Acheter maintenant',
                          style: TextStyle(
                              color: AppColors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _qtyButton(
      {required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFEEEEEE)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 18, color: AppColors.textDark),
      ),
    );
  }
}
