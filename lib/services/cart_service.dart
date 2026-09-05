import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';

class CartService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _cartRef(String userId) {
    return _db.collection('users').doc(userId).collection('cart');
  }

  Stream<List<Map<String, dynamic>>> watchCart(String userId) {
    return _cartRef(userId).snapshots().map(
      (snapshot) => snapshot.docs.map((doc) => {'docId': doc.id, ...doc.data()}).toList(),
    );
  }

  Future<void> addToCart({
    required String userId,
    required Product product,
    required String color,
    required String size,
    int quantity = 1,
  }) async {
    final itemKey = '${product.id}_${color}_$size';
    final docRef = _cartRef(userId).doc(itemKey);
    final existing = await docRef.get();

    if (existing.exists) {
      final currentQty = (existing.data()?['quantity'] as num?)?.toInt() ?? 0;
      await docRef.update({'quantity': currentQty + quantity});
    } else {
      await docRef.set({
        'productId': product.id,
        'name': product.name,
        'price': product.price,
        'emoji': product.emoji,
        'image': product.images.isNotEmpty ? product.images.first : '',
        'color': color,
        'size': size,
        'quantity': quantity,
        'addedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<void> updateQuantity(String userId, String docId, int quantity) async {
    if (quantity <= 0) {
      await removeItem(userId, docId);
      return;
    }
    await _cartRef(userId).doc(docId).update({'quantity': quantity});
  }

  Future<void> removeItem(String userId, String docId) async {
    await _cartRef(userId).doc(docId).delete();
  }

  Future<void> clearCart(String userId) async {
    final items = await _cartRef(userId).get();
    for (final doc in items.docs) {
      await doc.reference.delete();
    }
  }
}
