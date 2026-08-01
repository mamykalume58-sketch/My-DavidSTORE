import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navyDark,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 24),
              Image.asset(
                'assets/images/logo.png',
                width: 180,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 20),
              const Text(
                'Le shopping intelligent\ncommence ici.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 24),
              Image.asset(
                'assets/images/register_illustration.png',
                width: double.infinity,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 24),
              _buildSocialButton(
                icon: Icons.g_mobiledata,
                label: 'Continuer avec Google',
                backgroundColor: AppColors.white,
                textColor: AppColors.textDark,
                onTap: () {},
              ),
              const SizedBox(height: 12),
              _buildSocialButton(
                icon: Icons.facebook,
                label: 'Continuer avec Facebook',
                backgroundColor: const Color(0xFF1877F2),
                textColor: AppColors.white,
                onTap: () {},
              ),
              const SizedBox(height: 16),
              Row(
                children: const [
                  Expanded(child: Divider(color: AppColors.whiteMuted)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text('OU', style: TextStyle(color: AppColors.whiteMuted)),
                  ),
                  Expanded(child: Divider(color: AppColors.whiteMuted)),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.email_outlined, color: AppColors.gold),
                  label: const Text(
                    'Continuer avec e-mail',
                    style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.w600),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.gold),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {},
                child: const Text(
                  'Continuer en tant qu\'invité',
                  style: TextStyle(color: AppColors.whiteMuted),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required String label,
    required Color backgroundColor,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, color: textColor),
        label: Text(
          label,
          style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      ),
    );
  }
}
