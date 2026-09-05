import 'dart:io' show Platform;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:device_info_plus/device_info_plus.dart';

class DeviceService {
  final _firestore = FirebaseFirestore.instance;

  String? get _userId => FirebaseAuth.instance.currentUser?.uid;

  CollectionReference<Map<String, dynamic>> get _devicesRef =>
      _firestore.collection('users').doc(_userId).collection('devices');

  Future<String> _currentDeviceId(DeviceInfoPlugin plugin) async {
    if (Platform.isAndroid) {
      final info = await plugin.androidInfo;
      return info.id;
    } else if (Platform.isIOS) {
      final info = await plugin.iosInfo;
      return info.identifierForVendor ?? info.name;
    }
    return 'unknown';
  }

  Future<void> registerCurrentDevice() async {
    if (_userId == null) return;
    final plugin = DeviceInfoPlugin();
    String name;
    String platform;

    if (Platform.isAndroid) {
      final info = await plugin.androidInfo;
      name = '${info.manufacturer} ${info.model}';
      platform = 'Android';
    } else if (Platform.isIOS) {
      final info = await plugin.iosInfo;
      name = info.name;
      platform = 'iOS';
    } else {
      name = 'Appareil inconnu';
      platform = 'Autre';
    }

    final deviceId = await _currentDeviceId(plugin);
    await _devicesRef.doc(deviceId).set({
      'name': name,
      'platform': platform,
      'lastActive': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> watchDevices() {
    return _devicesRef.orderBy('lastActive', descending: true).snapshots();
  }

  Future<String> currentDeviceId() async {
    return _currentDeviceId(DeviceInfoPlugin());
  }

  Future<void> removeDevice(String deviceId) async {
    await _devicesRef.doc(deviceId).delete();
  }
}
