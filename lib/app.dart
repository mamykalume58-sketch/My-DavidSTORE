import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'screens/splash/splash_screen.dart';

import 'config/routes.dart';
import 'config/theme.dart';
import 'screens/category_screen.dart';
import 'screens/tracking/order_tracking_screen.dart';
import 'screens/auth/email_sent_screen.dart';
import 'screens/auth/verify_pin_screen.dart';
import 'screens/auth/new_password_screen.dart';
import 'screens/auth/password_reset_success_screen.dart';

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

        if (settings.name == '/email-sent') {
          final args = settings.arguments as Map?;
          return MaterialPageRoute(
            builder: (_) => EmailSentScreen(
              email: args?['email']?.toString() ?? '',
              requestId: args?['requestId']?.toString() ?? '',
            ),
          );
        }

        if (settings.name == '/verify-pin') {
          final args = settings.arguments as Map?;
          return MaterialPageRoute(
            builder: (_) => VerifyPinScreen(
              email: args?['email']?.toString() ?? '',
              requestId: args?['requestId']?.toString() ?? '',
            ),
          );
        }

        if (settings.name == '/new-password') {
          final args = settings.arguments as Map?;
          return MaterialPageRoute(
            builder: (_) => NewPasswordScreen(
              requestId: args?['requestId']?.toString() ?? '',
              resetToken: args?['resetToken']?.toString() ?? '',
            ),
          );
        }

        if (settings.name == '/password-reset-success') {
          return MaterialPageRoute(
            builder: (_) => const PasswordResetSuccessScreen(),
          );
        }

        return null;
      },
    );
  }
}
