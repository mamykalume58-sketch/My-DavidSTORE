import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';

class FavoritesService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _favRef(String userId) {
    return _db.collection('users').doc(userId).collection('favorites');
  }

  Stream<List<Map<String, dynamic>>> watchFavorites(String userId) {
    return _favRef(userId).snapshots().map(
      (snapshot) => snapshot.docs.map((doc) => {'docId': doc.id, ...doc.data()}).toList(),
    );
  }

  Stream<bool> isFavorite(String userId, String productId) {
    return _favRef(userId).doc(productId).snapshots().map((doc) => doc.exists);
  }

  Future<void> toggleFavorite(String userId, Product product) async {
    final docRef = _favRef(userId).doc(product.id);
    final existing = await docRef.get();

    if (existing.exists) {
      await docRef.delete();
    } else {
      await docRef.set({
        'productId': product.id,
        'name': product.name,
        'price': product.price,
        'emoji': product.emoji,
        'addedAt': FieldValue.serverTimestamp(),
      });
    }
  }
}
