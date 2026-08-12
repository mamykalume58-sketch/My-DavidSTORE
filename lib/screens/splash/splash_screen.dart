import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../services/session_service.dart';

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
    await Future.delayed(const Duration(seconds: 3));

    final hasSeenOnboarding =
        await SessionService.hasSeenOnboarding();

    final isLoggedIn = FirebaseAuth.instance.currentUser != null;

    if (!mounted) return;

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
      backgroundColor: const Color(0xFF0A1030),

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [

            Image.asset(
              'assets/images/splash_logo.png',
              width: 280,
              height: 280,
              fit: BoxFit.contain,
            ),

            const SizedBox(height: 90),

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
