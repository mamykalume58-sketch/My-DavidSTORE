import 'package:flutter/material.dart';

import 'config/routes.dart';
import 'config/theme.dart';
import 'screens/category_screen.dart';

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
      onGenerateRoute: (settings) {
        if (settings.name == '/category') {
          final categoryName = settings.arguments?.toString() ?? '';
          return MaterialPageRoute(
            builder: (_) => CategoryScreen(categoryName: categoryName),
          );
        }
        return null;
      },
    );
  }
}
