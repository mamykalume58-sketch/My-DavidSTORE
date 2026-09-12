import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class EmailSentScreen extends StatelessWidget {
  final String email;
  final String requestId;

  const EmailSentScreen({
    super.key,
    required this.email,
    required this.requestId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: AppColors.navyDark),
                onPressed: () => Navigator.pop(context),
              ),

              const Spacer(),

              Center(
                child: Container(
                  width: 110,
                  height: 110,
                  decoration: const BoxDecoration(
                    color: Color(0xFFDDF6E8),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check_rounded, size: 56, color: Color(0xFF1EA85D)),
                ),
              ),

              const SizedBox(height: 28),

              const Center(
                child: Text(
                  'E-mail envoyé',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.navyDark,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              Center(
                child: Text(
                  'Si un compte correspond à cette adresse, un code de vérification vient d\'être envoyé.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600, height: 1.4),
                ),
              ),

              const SizedBox(height: 28),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.mail_outline, color: AppColors.orangeDark),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Vérifiez votre boîte de réception et vos spams.',
                        style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.orangeDark,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      '/verify-pin',
                      arguments: {'email': email, 'requestId': requestId},
                    );
                  },
                  child: const Text(
                    'Continuer',
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              Center(
                child: TextButton(
                  onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
                  child: Text(
                    'Retour à la connexion',
                    style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                  ),
                ),
              ),

              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
