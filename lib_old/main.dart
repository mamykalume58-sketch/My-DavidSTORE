import 'package:flutter/material.dart';

import 'screens/splash_screen.dart';
import 'screens/empty_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const DavidStoreApp());
}

class DavidStoreApp extends StatelessWidget {
  const DavidStoreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DavidSTORE',
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        useMaterial3: true,
      ),

      routes: {
        '/empty': (context) => const EmptyScreen(),
      },

      home: const SplashScreen(),
    );
  }
}
