import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'screens/splash/splash_screen.dart';

import 'config/routes.dart';
import 'config/theme.dart';
import 'screens/category_screen.dart';
import 'screens/tracking/order_tracking_screen.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class DavidStoreApp extends StatelessWidget {
  const DavidStoreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'DavidSTORE',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
      routes: AppRoutes.routes,
      onGenerateRoute: (settings) {
        if (settings.name == '/category') {
          final categoryName = settings.arguments?.toString() ?? '';

          return MaterialPageRoute(
            builder: (_) => CategoryScreen(categoryName: categoryName),
          );
        }

        if (settings.name == '/order-detail') {
          final args = settings.arguments;
          String? orderId;
          if (args is Map) {
            orderId = args['orderId']?.toString();
          } else if (args != null) {
            orderId = args.toString();
          }

          return MaterialPageRoute(
            builder: (_) => OrderTrackingScreen(orderId: orderId),
          );
        }

        return null;
      },
    );
  }
}

class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasData) {
          return AppRoutes.routes['/']!(context);
        }

        return AppRoutes.routes['/login']!(context);
      },
    );
  }
}
