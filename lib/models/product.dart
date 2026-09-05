import '../utils/price_formatter.dart';

class Product {
  final String id;
  final String name;
  final int price;
  final int? promoPrice;
  final String emoji;
  final String category;
  final List<String> colors;
  final List<String> sizes;
  final String description;
  final List<String> characteristics;
  final double rating;
  final int reviewCount;
  final int stock;
  final bool active;
  final List<String> images;
  final int createdAt;

  const Product({
    required this.id,
    required this.name,
    required this.price,
    this.promoPrice,
    required this.emoji,
    required this.category,
    this.colors = const ['#0A1030', '#FF6B35', '#FFFFFF', '#9E9E9E'],
    this.sizes = const ['S', 'M', 'L', 'XL'],
    this.description = '',
    this.characteristics = const [],
    this.rating = 4.5,
    this.reviewCount = 0,
    this.stock = 0,
    this.active = true,
    this.images = const [],
    this.createdAt = 0,
  });

  String get priceDisplay => formatPrice(promoPrice ?? price);
  bool get hasPromo => promoPrice != null && promoPrice! < price;
  bool get inStock => stock > 0;

  factory Product.fromMap(Map<String, dynamic> map) {
    final rawPrice = map['price'];
    final int priceValue =
        rawPrice is int ? rawPrice : parsePrice(rawPrice.toString());

    final rawPromo = map['promoPrice'];
    final int? promoValue = rawPromo == null
        ? null
        : (rawPromo is int ? rawPromo : parsePrice(rawPromo.toString()));

    return Product(
      id: map['id']?.toString() ?? map['name'].toString(),
      name: map['name']?.toString() ?? '',
      price: priceValue,
      promoPrice: promoValue,
      emoji: map['emoji']?.toString() ?? '📦',
      category: map['category']?.toString() ?? '',
      colors: (map['colors'] as List?)?.cast<String>() ??
          const ['#0A1030', '#FF6B35', '#FFFFFF', '#9E9E9E'],
      sizes: (map['sizes'] as List?)?.cast<String>() ?? const ['S', 'M', 'L', 'XL'],
      description: map['description']?.toString() ?? '',
      characteristics: (map['characteristics'] as List?)?.cast<String>() ?? const [],
      rating: (map['rating'] as num?)?.toDouble() ?? 4.5,
      reviewCount: (map['reviewCount'] as num?)?.toInt() ?? 0,
      stock: (map['stock'] as num?)?.toInt() ?? 0,
      active: map['active'] as bool? ?? true,
      images: (map['images'] as List?)?.cast<String>() ?? const [],
      createdAt: (map['createdAt'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'promoPrice': promoPrice,
      'emoji': emoji,
      'category': category,
      'colors': colors,
      'sizes': sizes,
      'description': description,
      'characteristics': characteristics,
      'rating': rating,
      'reviewCount': reviewCount,
      'stock': stock,
      'active': active,
      'images': images,
      'createdAt': createdAt,
    };
  }
}
