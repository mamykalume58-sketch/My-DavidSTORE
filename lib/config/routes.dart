import 'package:flutter/material.dart';

import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/onboarding/onboarding_screen.dart';
import '../screens/cart/cart_screen.dart';
import '../screens/catalog/catalog_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/splash/splash_screen.dart';

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
  };
}}
