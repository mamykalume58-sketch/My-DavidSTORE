import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../services/session_service.dart';
import '../../main.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();
    _checkSessionAndRedirect();
  }

  Future<void> _checkSessionAndRedirect() async {
    await Future.delayed(const Duration(seconds: 5));

    final hasSeenOnboarding =
        await SessionService.hasSeenOnboarding();

    final isLoggedIn = FirebaseAuth.instance.currentUser != null;

    if (!mounted) return;

    if (pendingDeepLinkUri != null) {
      pendingDeepLinkUri = null;
      return;
    }

    if (!hasSeenOnboarding) {
      Navigator.pushReplacementNamed(
        context,
        '/onboarding',
      );
    } else if (isLoggedIn) {
      Navigator.pushReplacementNamed(
        context,
        '/home',
      );
    } else {
      Navigator.pushReplacementNamed(
        context,
        '/login',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF3D4FE0),

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [

            Image.asset(
              'assets/images/splash_bag.png',
              width: 220,
              fit: BoxFit.contain,
            ),

            Transform.translate(
              offset: const Offset(0, -45),
              child: Image.asset(
                'assets/images/splash_text.png',
                width: 260,
                fit: BoxFit.contain,
              ),
            ),

            const SizedBox(height: 70),

            const SizedBox(
              width: 32,
              height: 32,

              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: Color(0xFFFF6B35),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
