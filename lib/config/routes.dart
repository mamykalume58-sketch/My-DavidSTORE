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
import '../screens/account/personal_info_screen.dart';
import '../screens/account/addresses_screen.dart';
import '../screens/account/payment_methods_screen.dart';
import '../screens/account/coupons_screen.dart';
import '../screens/account/notifications_screen.dart';
import '../screens/account/security_screen.dart';
import '../screens/account/language_screen.dart';
import '../screens/account/theme_screen.dart';
import '../screens/account/help_screen.dart';
import '../screens/account/contact_screen.dart';
import '../screens/account/about_screen.dart';
import '../screens/account/privacy_policy_screen.dart';
import '../screens/account/logout_screen.dart';
import '../screens/account/change_password_screen.dart';
import '../screens/account/connected_devices_screen.dart';
import '../screens/account/active_sessions_screen.dart';
import '../screens/support/support_chat_screen.dart';

class AppRoutes {
  static Map<String, WidgetBuilder> routes = {
    '/': (context) => const SplashScreen(),
    '/onboarding': (context) => const OnboardingScreen(),
    '/login': (context) => const LoginScreen(),
    '/register': (context) => const RegisterScreen(),
    '/home': (context) => const HomeScreen(),
    '/catalog': (context) => const CatalogScreen(),
    '/cart': (context) => CartScreen(),
    '/profile': (context) => const ProfileScreen(),
    '/tracking': (context) => const OrderTrackingScreen(),
    '/favorites': (context) => const FavoritesScreen(),
    '/product': (context) => const ProductScreen(),
    '/checkout': (context) => const CheckoutScreen(),
    '/payment': (context) => const PaymentScreen(),
    '/delivery': (context) => const DeliveryScreen(),
    '/confirmation': (context) => const ConfirmationScreen(),
    '/account': (context) => const AccountScreen(),
    '/account/personal-info': (context) => const PersonalInfoScreen(),
    '/account/addresses': (context) => const AddressesScreen(),
    '/account/payment-methods': (context) => const PaymentMethodsScreen(),
    '/account/coupons': (context) => const CouponsScreen(),
    '/account/notifications': (context) => const AccountNotificationsScreen(),
    '/account/security': (context) => const SecurityScreen(),
    '/account/language': (context) => const LanguageScreen(),
    '/account/theme': (context) => const ThemeSettingsScreen(),
    '/account/help': (context) => const HelpScreen(),
    '/account/contact': (context) => const ContactScreen(),
    '/account/about': (context) => const AboutScreen(),
    '/account/privacy-policy': (context) => const PrivacyPolicyScreen(),
    '/account/logout': (context) => const LogoutScreen(),
    '/account/change-password': (context) => const ChangePasswordScreen(),
    '/account/connected-devices': (context) => const ConnectedDevicesScreen(),
    '/account/active-sessions': (context) => const ActiveSessionsScreen(),
    '/support-chat': (context) => const SupportChatScreen(),
  };
}
