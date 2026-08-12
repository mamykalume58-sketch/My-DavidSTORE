import 'package:flutter/material.dart';

import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/onboarding/onboarding_screen.dart';
import '../screens/cart/cart_screen.dart';
import '../screens/catalog/catalog_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/tracking/order_tracking_screen.dart';
import '../screens/favorites_screen.dart';
import '../screens/product/product_screen.dart';
import '../screens/checkout/checkout_screen.dart';
import '../screens/payment_screen.dart';
import '../screens/delivery_screen.dart';
import '../screens/confirmation_screen.dart';
import '../screens/account_screen.dart';
import '../screens/support/support_chat_screen.dart';
class AppRoutes {
  static Map<String, WidgetBuilder> routes = {
    '/': (context) => const SplashScreen(),
    '/onboarding': (context) => const OnboardingScreen(),
    '/login': (context) => const LoginScreen(),
    '/register': (context) => const RegisterScreen(),
    '/home': (context) => const HomeScreen(),
    '/catalog': (context) => const CatalogScreen(),
    '/cart': (context) => const CartScreen(),
    '/profile': (context) => const ProfileScreen(),
    '/tracking': (context) => const OrderTrackingScreen(),
    '/favorites': (context) => const FavoritesScreen(),
    '/product': (context) => const ProductScreen(),
    '/checkout': (context) => const CheckoutScreen(),
    '/payment': (context) => const PaymentScreen(),
    '/delivery': (context) => const DeliveryScreen(),
    '/confirmation': (context) => const ConfirmationScreen(),
    '/account': (context) => const AccountScreen(),
    '/support-chat': (context) => const SupportChatScreen(),
  };
}
