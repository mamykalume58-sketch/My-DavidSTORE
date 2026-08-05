import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const List<Map<String, String>> _categories = [
    {'label': 'Téléphones', 'icon': '📱'},
    {'label': 'Mode', 'icon': '👕'},
    {'label': 'Électronique', 'icon': '🔌'},
    {'label': 'Maison', 'icon': '🏠'},
  ];

  static const List<Map<String, String>> _bestSellers = [
    {'name': 'Smartphone A50', 'price': '410 000 FC', 'emoji': '📱'},
    {'name': 'Montre connectée', 'price': '150 000 FC', 'emoji': '⌚'},
    {'name': 'Casque sans fil S5', 'price': '80 000 FC', 'emoji': '🎧'},
  ];

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
                  RichText(
                    text: const TextSpan(
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      children: [
                        TextSpan(text: 'David', style: TextStyle(color: AppColors.navyDark)),
                        TextSpan(text: 'STORE', style: TextStyle(color: AppColors.orangeDark)),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pushNamed(context, '/cart'),
                        icon: const Icon(Icons.shopping_cart_outlined, color: AppColors.navyDark),
                      ),
                      Positioned(
                        right: 6,
                        top: 6,
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: const BoxDecoration(
                            color: AppColors.orangeDark,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                          child: const Text(
                            '3',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.whiteMuted,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Rechercher un produit...',
                    hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                    prefixIcon: const Icon(Icons.search, color: AppColors.textGrey),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.orangeDark, Color(0xFFFF8A5C)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Offres spéciales',
                            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            "Jusqu'à -50% sur une sélection",
                            style: TextStyle(color: Colors.white, fontSize: 14),
                          ),
                          const SizedBox(height: 14),
                          ElevatedButton(
                            onPressed: () => Navigator.pushNamed(context, '/catalog'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: AppColors.orangeDark,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text('Découvrir', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Catégories',
                          style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.navyDark),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pushNamed(context, '/catalog'),
                          child: const Text('Voir tout', style: TextStyle(color: AppColors.orangeDark)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: _categories.map((cat) {
                        return GestureDetector(
                          onTap: () => Navigator.pushNamed(context, '/catalog'),
                          child: Column(
                            children: [
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: AppColors.whiteMuted,
                                  shape: BoxShape.circle,
                                ),
                                alignment: Alignment.center,
                                child: Text(cat['icon']!, style: const TextStyle(fontSize: 26)),
                              ),
                              const SizedBox(height: 6),
                              Text(cat['label']!, style: const TextStyle(fontSize: 12, color: AppColors.textDark)),
                            ],
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 24),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Meilleures ventes',
                          style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.navyDark),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pushNamed(context, '/catalog'),
                          child: const Text('Voir tout', style: TextStyle(color: AppColors.orangeDark)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.85,
                      children: _bestSellers.map((product) {
                        return GestureDetector(
                          onTap: () {},
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.whiteMuted,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Center(
                                    child: Text(product['emoji']!, style: const TextStyle(fontSize: 40)),
                                  ),
                                ),
                                Text(
                                  product['name']!,
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textDark),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  product['price']!,
                                  style: const TextStyle(fontSize: 13, color: AppColors.orangeDark, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: Colors.grey.shade200)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(icon: Icons.home, label: 'Accueil', active: true, onTap: () {}),
                _NavItem(
                  icon: Icons.grid_view_outlined,
                  label: 'Catégories',
                  active: false,
                  onTap: () => Navigator.pushNamed(context, '/catalog'),
                ),
                _NavItem(
                  icon: Icons.shopping_cart_outlined,
                  label: 'Panier',
                  active: false,
                  onTap: () => Navigator.pushNamed(context, '/cart'),
                ),
                _NavItem(
                  icon: Icons.person_outline,
                  label: 'Profil',
                  active: false,
                  onTap: () => Navigator.pushNamed(context, '/profile'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.orangeDark : AppColors.textGrey;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(color: color, fontSize: 11)),
        ],
      ),
    );
  }
}
