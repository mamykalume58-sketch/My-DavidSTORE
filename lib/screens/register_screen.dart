import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _acceptTerms = false;
  bool _isGoogleLoading = false;
  bool _googleInitialized = false;

  Future<void> _ensureGoogleInitialized() async {
    if (_googleInitialized) return;
    await GoogleSignIn.instance.initialize(
      serverClientId:
          '27947559228-36j1vtt3pinki041dtpfar6oiptlfhlm.apps.googleusercontent.com',
    );
    _googleInitialized = true;
  }

  void _goToHome() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _isGoogleLoading = true);
    try {
      await _ensureGoogleInitialized();

      final googleUser = await GoogleSignIn.instance.authenticate();

      final idToken = googleUser.authentication.idToken;

      final authorization = await googleUser.authorizationClient
          .authorizationForScopes(['email', 'profile']);

      final credential = GoogleAuthProvider.credential(
        idToken: idToken,
        accessToken: authorization?.accessToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);

      if (!mounted) return;
      _goToHome();
    } catch (e) {
      setState(() => _isGoogleLoading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur de connexion Google : $e')),
      );
      return;
    }
    if (mounted) setState(() => _isGoogleLoading = false);
  }

  void _handleSocialLogin(String provider) {
    if (provider == 'Google') {
      _signInWithGoogle();
      return;
    }
    // Facebook et Apple restent en simulation pour l'instant
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Continuer avec $provider',
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _goToHome();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.orangeDark,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text('Se connecter',
                        style: TextStyle(color: AppColors.white)),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _goToHome();
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.orangeDark),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text('Créer un compte',
                        style: TextStyle(color: AppColors.orangeDark)),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 24),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Créer un compte',
                  style: TextStyle(
                    color: AppColors.textDark,
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
                  style: TextStyle(color: AppColors.textGrey, fontSize: 14),
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
                    side: const BorderSide(color: AppColors.textGrey),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text.rich(
                        TextSpan(
                          style: const TextStyle(
                              color: AppColors.textDark, fontSize: 13),
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
                  onPressed: _goToHome,
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
                  Expanded(child: Divider(color: AppColors.textGrey)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text('OU S\'INSCRIRE AVEC',
                        style: TextStyle(color: AppColors.textGrey, fontSize: 12)),
                  ),
                  Expanded(child: Divider(color: AppColors.textGrey)),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildSocialButton(
                      child: _isGoogleLoading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Image.asset('assets/images/google_logo.png',
                              width: 20, height: 20),
                      label: 'Google',
                      onTap: _isGoogleLoading
                          ? () {}
                          : () => _handleSocialLogin('Google'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildSocialButton(
                      child: const Icon(Icons.facebook,
                          color: Color(0xFF1877F2), size: 22),
                      label: 'Facebook',
                      onTap: () => _handleSocialLogin('Facebook'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildSocialButton(
                      child: const Icon(Icons.apple, color: AppColors.textDark, size: 22),
                      label: 'Apple',
                      onTap: () => _handleSocialLogin('Apple'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Vous avez déjà un compte ? ',
                      style: TextStyle(color: AppColors.textGrey, fontSize: 14)),
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
        border: Border.all(color: AppColors.textGrey),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        obscureText: obscure,
        style: const TextStyle(color: AppColors.textDark),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: AppColors.textGrey, size: 20),
          suffixIcon: toggleObscure != null
              ? IconButton(
                  icon: Icon(
                    obscure ? Icons.visibility_off : Icons.visibility,
                    color: AppColors.textGrey,
                    size: 20,
                  ),
                  onPressed: toggleObscure,
                )
              : null,
          hintText: hint,
          hintStyle: const TextStyle(color: AppColors.textGrey),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildSocialButton({
    required Widget child,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.textGrey),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            child,
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(color: AppColors.textDark, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
