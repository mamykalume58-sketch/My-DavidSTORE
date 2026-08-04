import 'package:flutter/material.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _Product {
  final String name;
  final String price;
  final double rating;
  final int reviews;
  final String category;
  final IconData icon;

  const _Product({
    required this.name,
    required this.price,
    required this.rating,
    required this.reviews,
    required this.category,
    required this.icon,
  });
}

class _CatalogScreenState extends State<CatalogScreen> {
  static const orange = Color(0xFFFF6B35);
  static const navy = Color(0xFF0A1030);

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'Tous';
  String _sortBy = 'Pertinence';

  final List<String> _categories = const [
    'Tous',
    'Électronique',
    'Mode',
    'Maison',
    'Beauté',
    'Sport',
  ];

  final List<_Product> _products = const [
    _Product(
      name: 'Smartphone Samsung A14',
      price: '450 000 FC',
      rating: 4.5,
      reviews: 120,
      category: 'Électronique',
      icon: Icons.smartphone,
    ),
    _Product(
      name: 'Casque Bluetooth JBL',
      price: '150 000 FC',
      rating: 4.7,
      reviews: 88,
      category: 'Électronique',
      icon: Icons.headphones,
    ),
    _Product(
      name: 'Montre connectée',
      price: '150 000 FC',
      rating: 4.4,
      reviews: 65,
      category: 'Électronique',
      icon: Icons.watch,
    ),
    _Product(
      name: 'Laptop HP 250 G9',
      price: '1 350 000 FC',
      rating: 4.6,
      reviews: 64,
      category: 'Électronique',
      icon: Icons.laptop_mac,
    ),
    _Product(
      name: 'Imprimante Canon MG2540S',
      price: '250 000 FC',
      rating: 4.4,
      reviews: 45,
      category: 'Maison',
      icon: Icons.print,
    ),
    _Product(
      name: 'Chaussures Sport',
      price: '95 000 FC',
      rating: 4.3,
      reviews: 52,
      category: 'Sport',
      icon: Icons.sports_soccer,
    ),
    _Product(
      name: 'Robe élégante',
      price: '65 000 FC',
      rating: 4.2,
      reviews: 34,
      category: 'Mode',
      icon: Icons.checkroom,
    ),
    _Product(
      name: 'Crème hydratante',
      price: '25 000 FC',
      rating: 4.6,
      reviews: 90,
      category: 'Beauté',
      icon: Icons.spa,
    ),
  ];

  List<_Product> get _filteredProducts {
    var list = _products.where((p) {
      final matchCategory =
          _selectedCategory == 'Tous' || p.category == _selectedCategory;
      final matchSearch =
          p.name.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchCategory && matchSearch;
    }).toList();

    switch (_sortBy) {
      case 'Prix croissant':
        list.sort((a, b) => _priceValue(a.price).compareTo(_priceValue(b.price)));
        break;
      case 'Prix décroissant':
        list.sort((a, b) => _priceValue(b.price).compareTo(_priceValue(a.price)));
        break;
      case 'Meilleures notes':
        list.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      default:
        break;
    }

    return list;
  }

  double _priceValue(String price) {
    return double.tryParse(
          price.replaceAll(RegExp(r'[^0-9]'), ''),
        ) ??
        0;
  }

  void _showSortSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final options = [
          'Pertinence',
          'Prix croissant',
          'Prix décroissant',
          'Meilleures notes',
        ];
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: options.map((option) {
              return ListTile(
                title: Text(option),
                trailing: _sortBy == option
                    ? const Icon(Icons.check, color: orange)
                    : null,
                onTap: () {
                  setState(() {
                    _sortBy = option;
                  });
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: navy,
        title: const Text(
          'Catalogue',
          style: TextStyle(color: navy, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: () => Navigator.pushNamed(context, '/cart'),
            icon: const Icon(Icons.shopping_cart_outlined, color: navy),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Rechercher un produit...',
                hintStyle: const TextStyle(color: Colors.black38),
                prefixIcon: const Icon(Icons.search, color: Colors.black38),
                filled: true,
                fillColor: const Color(0xFFF5F5F7),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          const SizedBox(height: 14),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.filter_list, size: 18, color: navy),
                    label: const Text('Filtrer', style: TextStyle(color: navy)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFE0E0E0)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _showSortSheet,
                    icon: const Icon(Icons.sort, size: 18, color: navy),
                    label: const Text('Trier', style: TextStyle(color: navy)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFE0E0E0)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          SizedBox(
            height: 40,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = _selectedCategory == category;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedCategory = category;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isSelected ? orange : const Color(0xFFF5F5F7),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      category,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black54,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 12),

          Expanded(
            child: _filteredProducts.isEmpty
                ? const Center(
                    child: Text(
                      'Aucun produit trouvé',
                      style: TextStyle(color: Colors.black38),
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    itemCount: _filteredProducts.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 14,
                      crossAxisSpacing: 14,
                      childAspectRatio: 0.72,
                    ),
                    itemBuilder: (context, index) {
                      final product = _filteredProducts[index];
                      return GestureDetector(
                        onTap: () => Navigator.pushNamed(context, '/product'),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF9F9FB),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Center(
                                  child: Icon(
                                    product.icon,
                                    size: 56,
                                    color: navy,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                product.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: navy,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.star, size: 14, color: orange),
                                  const SizedBox(width: 2),
                                  Text(
                                    '${product.rating} (${product.reviews})',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                product.price,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: orange,
                                ),
                              ),
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
