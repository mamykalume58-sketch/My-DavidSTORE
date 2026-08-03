import 'package:flutter/material.dart';

import 'config/routes.dart';
import 'config/theme.dart';

class DavidStoreApp extends StatelessWidget {
  const DavidStoreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DavidSTORE',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: '/',
      routes: AppRoutes.routes,
    );
  }
}
