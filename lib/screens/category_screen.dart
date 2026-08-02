import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'product_screen.dart';

class CategoryScreen extends StatelessWidget {
  final String categoryName;
  const CategoryScreen({super.key, required this.categoryName});

  @override
  Widget build(BuildContext context) {
    final products = [
      ('Smartphone Samsung\nGalaxy A14 64GB', 250000, 300000, '-17%'),
      ('iPhone 13 128GB', 850000, 1000000, '-15%'),
      ('Casque Bluetooth\nSony WH-CH520', 25000, 30000, '-17%'),
      ('Enceinte JBL Charge 5', 60000, 70000, '-14%'),
      ('Ordinateur Portable\nHP 15s', 600000, 700000, '-14%'),
    ];

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(categoryName,
            style: const TextStyle(
                color: AppColors.textDark,
                fontSize: 18,
                fontWeight: FontWeight.w700)),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: AppColors.textDark),
            onPressed: () {},
          ),
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart_outlined,
                    color: AppColors.textDark),
                onPressed: () {},
              ),
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(
                    color: AppColors.orangeDark,
                    shape: BoxShape.circle,
                  ),
                  child: const Text('0',
                      style: TextStyle(
                          color: AppColors.white, fontSize: 9)),
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Row(
              children: [
                Text('${products.length} articles',
                    style: const TextStyle(
                        color: AppColors.textGrey, fontSize: 13)),
                const Spacer(),
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.filter_list,
                      color: AppColors.orangeDark, size: 18),
                  label: const Text('Filtrer',
                      style: TextStyle(
                          color: AppColors.orangeDark, fontSize: 13)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.orangeDark),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 4),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: products.length,
              separatorBuilder: (_, __) =>
                  const Divider(height: 1, color: Color(0xFFF0F0F0)),
              itemBuilder: (context, index) {
                final item = products[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProductScreen(
                          name: item.$1,
                          price: item.$2,
                          oldPrice: item.$3,
                          discount: item.$4,
                        ),
                      ),
                    );
                  },
                  child: Padding(
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
                              Text(item.$1,
                                  style: const TextStyle(
                                      fontSize: 14,
                                      color: AppColors.textDark,
                                      fontWeight: FontWeight.w500)),
                              const SizedBox(height: 6),
                              Text('${item.$2 ~/ 1000}.000 FC',
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.orangeDark)),
                            ],
                          ),
                        ),
                        if (item.$4.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(item.$4,
                                style: const TextStyle(
                                    color: AppColors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700)),
                          ),
                        const SizedBox(width: 8),
                        const Icon(Icons.favorite_border,
                            color: AppColors.textGrey, size: 20),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
