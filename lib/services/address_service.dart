import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddressService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String? get _userId => FirebaseAuth.instance.currentUser?.uid;

  CollectionReference<Map<String, dynamic>> get _addresses {
    final userId = _userId;

    if (userId == null) {
      throw StateError('Utilisateur non connecté');
    }

    return _db.collection('users').doc(userId).collection('addresses');
  }

  Stream<List<Map<String, dynamic>>> watchAddresses() {
    if (_userId == null) {
      return const Stream.empty();
    }

    return _addresses
        .orderBy('isDefault', descending: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map((doc) {
            return {
              'id': doc.id,
              ...doc.data(),
            };
          }).toList(),
        );
  }

  Future<String> addAddress({
    required String label,
    required String name,
    required String phone,
    required String address,
    required String city,
    double? latitude,
    double? longitude,
    bool isDefault = false,
    String? province,
    String? commune,
    String? quartier,
    String? avenue,
    String? establishmentNumber,
    String? reference,
  }) async {
    if (_userId == null) {
      throw StateError('Utilisateur non connecté');
    }

    final data = <String, dynamic>{
      'label': label,
      'name': name,
      'phone': phone,
      'address': address,
      'city': city,
      'latitude': latitude,
      'longitude': longitude,
      'isDefault': isDefault,
      'province': province,
      'commune': commune,
      'quartier': quartier,
      'avenue': avenue,
      'establishmentNumber': establishmentNumber,
      'reference': reference,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (isDefault) {
      await _removeDefaultAddress();
    }

    final doc = await _addresses.add(data);

    return doc.id;
  }

  Future<void> updateAddress({
    required String addressId,
    required String label,
    required String name,
    required String phone,
    required String address,
    required String city,
    double? latitude,
    double? longitude,
    bool isDefault = false,
    String? province,
    String? commune,
    String? quartier,
    String? avenue,
    String? establishmentNumber,
    String? reference,
  }) async {
    if (_userId == null) {
      throw StateError('Utilisateur non connecté');
    }

    if (isDefault) {
      await _removeDefaultAddress(exceptId: addressId);
    }

    await _addresses.doc(addressId).update({
      'label': label,
      'name': name,
      'phone': phone,
      'address': address,
      'city': city,
      'latitude': latitude,
      'longitude': longitude,
      'isDefault': isDefault,
      'province': province,
      'commune': commune,
      'quartier': quartier,
      'avenue': avenue,
      'establishmentNumber': establishmentNumber,
      'reference': reference,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteAddress(String addressId) async {
    if (_userId == null) {
      throw StateError('Utilisateur non connecté');
    }

    await _addresses.doc(addressId).delete();
  }

  Future<void> setDefaultAddress(String addressId) async {
    if (_userId == null) {
      throw StateError('Utilisateur non connecté');
    }

    await _removeDefaultAddress(exceptId: addressId);

    await _addresses.doc(addressId).update({
      'isDefault': true,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<Map<String, dynamic>?> getDefaultAddress() async {
    if (_userId == null) {
      return null;
    }

    final snapshot = await _addresses
        .where('isDefault', isEqualTo: true)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) {
      return null;
    }

    return {
      'id': snapshot.docs.first.id,
      ...snapshot.docs.first.data(),
    };
  }

  Future<Map<String, dynamic>?> getAddress(String addressId) async {
    if (_userId == null) {
      return null;
    }

    final doc = await _addresses.doc(addressId).get();

    if (!doc.exists) {
      return null;
    }

    return {
      'id': doc.id,
      ...doc.data()!,
    };
  }

  Future<void> _removeDefaultAddress({
    String? exceptId,
  }) async {
    final snapshot = await _addresses
        .where('isDefault', isEqualTo: true)
        .get();

    if (snapshot.docs.isEmpty) {
      return;
    }

    final batch = _db.batch();

    for (final doc in snapshot.docs) {
      if (doc.id == exceptId) {
        continue;
      }

      batch.update(doc.reference, {
        'isDefault': false,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }

    await batch.commit();
  }
}

