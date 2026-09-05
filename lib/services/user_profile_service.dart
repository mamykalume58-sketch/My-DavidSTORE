import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserProfileService {
  final _db = FirebaseFirestore.instance;

  String? get _userId => FirebaseAuth.instance.currentUser?.uid;

  DocumentReference<Map<String, dynamic>> get _doc =>
      _db.collection('users').doc(_userId);

  Stream<Map<String, dynamic>?> watchUserProfile() {
    if (_userId == null) return const Stream.empty();
    return _doc.snapshots().map((snap) => snap.data());
  }

  Future<void> updateUserProfile({
    String? phone,
    DateTime? birthDate,
    String? gender,
    String? photoUrl,
  }) async {
    if (_userId == null) return;
    final data = <String, dynamic>{};
    if (phone != null) data['phone'] = phone;
    if (birthDate != null) data['birthDate'] = Timestamp.fromDate(birthDate);
    if (gender != null) data['gender'] = gender;
    if (photoUrl != null) data['photoUrl'] = photoUrl;
    await _doc.set(data, SetOptions(merge: true));
  }
}
