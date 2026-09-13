import 'package:cloud_firestore/cloud_firestore.dart';

class OrderItem {
  final String productId;
  final String name;
  final int price;
  final int quantity;
  final String color;
  final String image;

  const OrderItem({
    required this.productId,
    required this.name,
    required this.price,
    required this.quantity,
    this.color = '',
    this.image = '',
  });

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      productId: map['productId']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      price: (map['price'] as num?)?.toInt() ?? 0,
      quantity: (map['quantity'] as num?)?.toInt() ?? 1,
      color: map['color']?.toString() ?? '',
      image: map['image']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'name': name,
      'price': price,
      'quantity': quantity,
      'color': color,
      'image': image,
    };
  }
}

class DeliveryPerson {
  final String name;
  final String photoUrl;
  final double rating;
  final String phone;

  const DeliveryPerson({
    this.name = '',
    this.photoUrl = '',
    this.rating = 0,
    this.phone = '',
  });

  bool get isAssigned => name.isNotEmpty;

  factory DeliveryPerson.fromMap(Map<String, dynamic>? map) {
    if (map == null) return const DeliveryPerson();
    return DeliveryPerson(
      name: map['name']?.toString() ?? '',
      photoUrl: map['photoUrl']?.toString() ?? '',
      rating: (map['rating'] as num?)?.toDouble() ?? 0,
      phone: map['phone']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'photoUrl': photoUrl,
      'rating': rating,
      'phone': phone,
    };
  }
}

class OrderModel {
  final String id;
  final String orderNumber;
  final String userId;
  final String status;
  final List<OrderItem> items;
  final Map<String, dynamic> deliveryAddress;
  final Map<String, dynamic> deliveryMethod;
  final int sousTotal;
  final int fraisLivraison;
  final int total;
  final String paymentMethod;
  final String paymentReference;
  final String paymentStatus;
  final DeliveryPerson deliveryPerson;
  final String? driverId;
  final DateTime? createdAt;

  const OrderModel({
    required this.id,
    required this.orderNumber,
    required this.userId,
    this.status = 'pending',
    this.items = const [],
    this.deliveryAddress = const {},
    this.deliveryMethod = const {},
    this.sousTotal = 0,
    this.fraisLivraison = 0,
    this.total = 0,
    this.paymentMethod = '',
    this.paymentReference = '',
    this.paymentStatus = '',
    this.deliveryPerson = const DeliveryPerson(),
    this.driverId,
    this.createdAt,
  });

  factory OrderModel.fromMap(Map<String, dynamic> map) {
    return OrderModel(
      id: map['id']?.toString() ?? '',
      orderNumber: map['orderNumber']?.toString() ?? '',
      userId: map['userId']?.toString() ?? '',
      status: map['status']?.toString() ?? 'pending',
      items: (map['items'] as List?)
              ?.map((e) => OrderItem.fromMap(e as Map<String, dynamic>))
              .toList() ??
          const [],
      deliveryAddress: (map['deliveryAddress'] as Map?)?.cast<String, dynamic>() ?? const {},
      deliveryMethod: (map['deliveryMethod'] as Map?)?.cast<String, dynamic>() ?? const {},
      sousTotal: (map['sousTotal'] as num?)?.toInt() ?? 0,
      fraisLivraison: (map['fraisLivraison'] as num?)?.toInt() ?? 0,
      total: (map['total'] as num?)?.toInt() ?? 0,
      paymentMethod: map['paymentMethod']?.toString() ?? '',
      paymentReference: map['paymentReference']?.toString() ?? '',
      paymentStatus: map['paymentStatus']?.toString() ?? '',
      deliveryPerson: DeliveryPerson.fromMap(map['deliveryPerson'] as Map<String, dynamic>?),
      driverId: map['driverId']?.toString(),
      createdAt: (map['createdAt'] is Timestamp)
          ? (map['createdAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'orderNumber': orderNumber,
      'userId': userId,
      'status': status,
      'items': items.map((e) => e.toMap()).toList(),
      'deliveryAddress': deliveryAddress,
      'deliveryMethod': deliveryMethod,
      'sousTotal': sousTotal,
      'fraisLivraison': fraisLivraison,
      'total': total,
      'paymentMethod': paymentMethod,
      'paymentReference': paymentReference,
      'paymentStatus': paymentStatus,
      'deliveryPerson': deliveryPerson.toMap(),
      'driverId': driverId,
    };
  }
}
