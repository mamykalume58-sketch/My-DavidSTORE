import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _acceptTerms = false;

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
              Image.asset('assets/images/logo.png', width: 130),
              const SizedBox(height: 12),
              const Text(
                'Le shopping intelligent commence ici.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.white, fontSize: 15),
              ),
              const SizedBox(height: 12),
              Container(width: 40, height: 2, color: AppColors.orangeDark),
              const SizedBox(height: 28),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Créer un compte',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Rejoignez DavidSTORE et profitez d\'une\nexpérience d\'achat unique.',
                  style: TextStyle(color: AppColors.whiteMuted, fontSize: 14),
                ),
              ),
              const SizedBox(height: 24),
              _buildField(icon: Icons.person_outline, hint: 'Nom complet'),
              const SizedBox(height: 14),
              _buildField(icon: Icons.email_outlined, hint: 'Adresse e-mail'),
              const SizedBox(height: 14),
              _buildField(
                icon: Icons.lock_outline,
                hint: 'Mot de passe',
                obscure: _obscurePassword,
                toggleObscure: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              ),
              const SizedBox(height: 14),
              _buildField(
                icon: Icons.lock_outline,
                hint: 'Confirmer le mot de passe',
                obscure: _obscureConfirmPassword,
                toggleObscure: () => setState(
                    () => _obscureConfirmPassword = !_obscureConfirmPassword),
              ),
              const SizedBox(height: 18),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Checkbox(
                    value: _acceptTerms,
                    onChanged: (value) =>
                        setState(() => _acceptTerms = value ?? false),
                    activeColor: AppColors.orangeDark,
                    side: const BorderSide(color: AppColors.whiteMuted),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text.rich(
                        TextSpan(
                          style: const TextStyle(
                              color: AppColors.white, fontSize: 13),
                          children: [
                            const TextSpan(text: 'J\'accepte les '),
                            TextSpan(
                              text: 'Conditions d\'utilisation',
                              style: const TextStyle(color: AppColors.orangeDark),
                            ),
                            const TextSpan(text: ' et la '),
                            TextSpan(
                              text: 'Politique de confidentialité',
                              style: const TextStyle(color: AppColors.orangeDark),
                            ),
                            const TextSpan(text: ' de DavidSTORE.'),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.orangeDark,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'S\'inscrire',
                        style: TextStyle(
                            color: AppColors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward, color: AppColors.white, size: 18),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: const [
                  Expanded(child: Divider(color: AppColors.whiteMuted)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text('OU S\'INSCRIRE AVEC',
                        style: TextStyle(color: AppColors.whiteMuted, fontSize: 12)),
                  ),
                  Expanded(child: Divider(color: AppColors.whiteMuted)),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildSocialButton(
                      child: Image.asset('assets/images/google_logo.png',
                          width: 20, height: 20),
                      label: 'Google',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildSocialButton(
                      child: const Icon(Icons.facebook,
                          color: Color(0xFF1877F2), size: 22),
                      label: 'Facebook',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildSocialButton(
                      child: const Icon(Icons.apple, color: AppColors.white, size: 22),
                      label: 'Apple',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Vous avez déjà un compte ? ',
                      style: TextStyle(color: AppColors.whiteMuted, fontSize: 14)),
                  GestureDetector(
                    onTap: () {},
                    child: const Text(
                      'Se connecter',
                      style: TextStyle(
                          color: AppColors.orangeDark,
                          fontSize: 14,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required IconData icon,
    required String hint,
    bool obscure = false,
    VoidCallback? toggleObscure,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.whiteMuted),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        obscureText: obscure,
        style: const TextStyle(color: AppColors.white),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: AppColors.whiteMuted, size: 20),
          suffixIcon: toggleObscure != null
              ? IconButton(
                  icon: Icon(
                    obscure ? Icons.visibility_off : Icons.visibility,
                    color: AppColors.whiteMuted,
                    size: 20,
                  ),
                  onPressed: toggleObscure,
                )
              : null,
          hintText: hint,
          hintStyle: const TextStyle(color: AppColors.whiteMuted),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildSocialButton({required Widget child, required String label}) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.whiteMuted),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          child,
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: AppColors.white, fontSize: 12)),
        ],
      ),
    );
  }
}
