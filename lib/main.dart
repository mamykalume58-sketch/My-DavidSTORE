import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:app_links/app_links.dart';
import 'firebase_options.dart';
import 'app.dart';

void _handleNotificationTap(RemoteMessage message) {
  final type = message.data['type'];
  if (type == 'new_product') {
    navigatorKey.currentState?.pushNamed('/catalog');
  } else if (type == 'payment_completed') {
    final orderId = message.data['orderId'];
    navigatorKey.currentState?.pushNamed('/order-detail', arguments: {'orderId': orderId});
  }
}

Uri? pendingDeepLinkUri;

void _handleDeepLink(Uri uri) {
  final segments = uri.pathSegments;
  if (segments.length >= 2 && segments[0] == 'orders') {
    pendingDeepLinkUri = uri;
    final orderId = segments[1];
    navigatorKey.currentState?.pushNamed('/order-detail', arguments: {'orderId': orderId});
  }
}

final FlutterLocalNotificationsPlugin _localNotifications =
    FlutterLocalNotificationsPlugin();

const AndroidNotificationChannel _channel = AndroidNotificationChannel(
  'davidstore_default_channel',
  'Notifications DavidSTORE',
  description: 'Notifications de paiement et de nouveautes',
  importance: Importance.high,
);

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await _localNotifications.initialize(
    settings: const InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    ),
  );
  await _localNotifications
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(_channel);

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    final notification = message.notification;
    if (notification != null) {
      _localNotifications.show(
        id: notification.hashCode,
        title: notification.title,
        body: notification.body,
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            _channel.id,
            _channel.name,
            channelDescription: _channel.description,
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
      );
    }
  });

  FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

  final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
  if (initialMessage != null) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _handleNotificationTap(initialMessage);
    });
  }

  final appLinks = AppLinks();
  appLinks.uriLinkStream.listen(_handleDeepLink);
  final initialUri = await appLinks.getInitialLink();
  if (initialUri != null) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _handleDeepLink(initialUri);
    });
  }

  runApp(const DavidStoreApp());
}
