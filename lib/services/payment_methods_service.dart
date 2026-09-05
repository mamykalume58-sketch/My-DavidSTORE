import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/payment_method.dart';

class PaymentMethodsService {
  final _firestore = FirebaseFirestore.instance;

  String? get _userId => FirebaseAuth.instance.currentUser?.uid;

  CollectionReference<Map<String, dynamic>>? get _ref {
    final userId = _userId;
    if (userId == null) return null;
    return _firestore.collection('users').doc(userId).collection('paymentMethods');
  }

  Stream<List<PaymentMethod>> watchPaymentMethods() {
    final ref = _ref;
    if (ref == null) return const Stream.empty();
    return ref.orderBy('createdAt', descending: false).snapshots().map(
          (snap) => snap.docs.map((d) => PaymentMethod.fromDoc(d)).toList(),
        );
  }

  Future<PaymentMethod?> getDefaultPaymentMethod() async {
    final ref = _ref;
    if (ref == null) return null;
    final snap = await ref.where('isDefault', isEqualTo: true).limit(1).get();
    if (snap.docs.isEmpty) return null;
    return PaymentMethod.fromDoc(snap.docs.first);
  }

  Future<void> addPaymentMethod({
    required String provider,
    required String phoneNumber,
  }) async {
    final ref = _ref;
    if (ref == null) return;

    final existing = await ref.get();
    final isFirst = existing.docs.isEmpty;

    await ref.add({
      'provider': provider,
      'phoneNumber': phoneNumber,
      'isDefault': isFirst,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> setAsDefault(String methodId) async {
    final ref = _ref;
    if (ref == null) return;

    final batch = _firestore.batch();
    final all = await ref.get();
    for (final doc in all.docs) {
      batch.update(doc.reference, {'isDefault': doc.id == methodId});
    }
    await batch.commit();
  }

  Future<void> deletePaymentMethod(String methodId) async {
    final ref = _ref;
    if (ref == null) return;
    await ref.doc(methodId).delete();
  }
}
