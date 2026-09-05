import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
  final _firestore = FirebaseFirestore.instance;
  final _messaging = FirebaseMessaging.instance;

  String? get _userId => FirebaseAuth.instance.currentUser?.uid;

  Future<void> registerFcmToken() async {
    if (_userId == null) return;

    try {
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.denied) {
        return;
      }

      final token = await _messaging.getToken();
      if (token == null) return;

      await _firestore.collection('users').doc(_userId).set({
        'fcmToken': token,
        'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      // Ne bloque jamais la connexion si la notif échoue
    }
  }
}
