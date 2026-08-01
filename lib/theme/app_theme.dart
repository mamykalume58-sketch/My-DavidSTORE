import 'package:flutter/material.dart';

class AppColors {
  static const Color navyDark = Color(0xFF0A1030);
  static const Color navyMid = Color(0xFF141B45);
  static const Color orange = Color(0xFFFF6B35);
  static const Color orangeDark = Color(0xFFE8491D);
  static const Color gold = Color(0xFFE8A93A);
  static const Color white = Color(0xFFFFFFFF);
  static const Color whiteMuted = Color(0xB3FFFFFF);
  static const Color textDark = Color(0xFF222222);
  static const Color textGrey = Color(0xFF666666);
}

class AppTextStyles {
  static const TextStyle onboardingTitle = TextStyle(
    fontSize: 34,
    fontWeight: FontWeight.w800,
    color: AppColors.white,
    height: 1.1,
  );

  static const TextStyle onboardingSubtitle = TextStyle(
    fontSize: 16,
    color: AppColors.white,
    height: 1.4,
  );

  static const TextStyle cardTitle = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: AppColors.textDark,
  );

  static const TextStyle cardBody = TextStyle(
    fontSize: 14,
    color: AppColors.textGrey,
    height: 1.4,
  );
}
