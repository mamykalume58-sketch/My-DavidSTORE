import 'package:cloud_firestore/cloud_firestore.dart';

class CouponService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<Map<String, dynamic>>> watchAvailableCoupons() {
    return _db
        .collection('coupons')
        .where('active', isEqualTo: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => {'id': d.id, ...d.data()}).toList());
  }

  Stream<List<Map<String, dynamic>>> watchUsedCoupons(String userId) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('usedCoupons')
        .orderBy('usedAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => {'id': d.id, ...d.data()}).toList());
  }

  Future<void> markCouponAsUsed(String userId, Map<String, dynamic> coupon) async {
    await _db.collection('users').doc(userId).collection('usedCoupons').add({
      'couponId': coupon['id'],
      'code': coupon['code'],
      'type': coupon['type'],
      'value': coupon['value'],
      'usedAt': FieldValue.serverTimestamp(),
    });
  }
}
