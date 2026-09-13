import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_snackbar.dart';

class NewPasswordScreen extends StatefulWidget {
  final String requestId;
  final String resetToken;

  const NewPasswordScreen({
    super.key,
    required this.requestId,
    required this.resetToken,
  });

  @override
  State<NewPasswordScreen> createState() => _NewPasswordScreenState();
}

class _NewPasswordScreenState extends State<NewPasswordScreen> {
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final AuthService _authService = AuthService();

  bool _obscure1 = true;
  bool _obscure2 = true;
  bool _loading = false;

  bool get _hasMinLength => _passwordController.text.length >= 8;
  bool get _hasLetter => RegExp(r'[a-zA-Z]').hasMatch(_passwordController.text);
  bool get _hasDigit => RegExp(r'[0-9]').hasMatch(_passwordController.text);
  bool get _hasSpecial => RegExp(r'[!@#\$%^&*(),.?":{}|<>_\-]').hasMatch(_passwordController.text);

  bool get _isValidPassword => _hasMinLength && _hasLetter && _hasDigit;
  bool get _passwordsMatch =>
      _passwordController.text.isNotEmpty && _passwordController.text == _confirmController.text;

  bool get _canSubmit => _isValidPassword && _passwordsMatch && !_loading;

  double get _strength {
    var score = 0;
    if (_hasMinLength) score++;
    if (_hasLetter) score++;
    if (_hasDigit) score++;
    if (_hasSpecial) score++;
    return score / 4;
  }

  Color get _strengthColor {
    if (_strength <= 0.25) return Colors.red;
    if (_strength <= 0.5) return Colors.orange;
    if (_strength <= 0.75) return Colors.amber;
    return Colors.green;
  }

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(() => setState(() {}));
    _confirmController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_isValidPassword) {
      AppSnackBar.info(context, 'Le mot de passe ne respecte pas les exigences');
      return;
    }
    if (!_passwordsMatch) {
      AppSnackBar.error(context, 'Les mots de passe ne correspondent pas.');
      return;
    }

    setState(() => _loading = true);

    try {
      await _authService.resetPasswordWithPin(
        widget.requestId,
        widget.resetToken,
        _passwordController.text,
      );

      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/password-reset-success',
          (route) => route.isFirst,
        );
      }
    } catch (e) {
      if (mounted) {
        AppSnackBar.errorFromException(context, e);
      }
    }

    if (mounted) setState(() => _loading = false);
  }

  Widget _requirementRow(String label, bool met) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Icon(
            met ? Icons.check_circle : Icons.check_circle_outline,
            size: 16,
            color: met ? const Color(0xFF1EA85D) : Colors.grey.shade400,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: met ? Colors.grey.shade800 : Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _decoration(String hint, bool obscure, VoidCallback toggle) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.grey, fontSize: 15),
      prefixIcon: const Icon(Icons.lock_outline, color: AppColors.orangeDark),
      suffixIcon: IconButton(
        icon: Icon(
          obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
          color: Colors.grey,
        ),
        onPressed: toggle,
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.orangeDark, width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.navyDark),
        title: const Text(
          'Créer un nouveau mot de passe',
          style: TextStyle(color: AppColors.navyDark, fontWeight: FontWeight.w600, fontSize: 16),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    color: AppColors.navyDark.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.lock_outline, size: 40, color: AppColors.navyDark),
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                'Nouveau mot de passe',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.navyDark),
              ),

              const SizedBox(height: 4),

              Text(
                'Choisissez un mot de passe sécurisé pour votre compte.',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),

              const SizedBox(height: 24),

              TextFormField(
                controller: _passwordController,
                obscureText: _obscure1,
                decoration: _decoration('Nouveau mot de passe', _obscure1, () {
                  setState(() => _obscure1 = !_obscure1);
                }),
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _confirmController,
                obscureText: _obscure2,
                decoration: _decoration('Confirmer le nouveau mot de passe', _obscure2, () {
                  setState(() => _obscure2 = !_obscure2);
                }),
              ),

              if (_confirmController.text.isNotEmpty && !_passwordsMatch) ...[
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFDEAEA),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.error_outline, color: Color(0xFFC0392B), size: 18),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Les mots de passe ne correspondent pas.',
                          style: TextStyle(color: Color(0xFFC0392B), fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 20),

              Text(
                'Exigences du mot de passe :',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey.shade700),
              ),
              const SizedBox(height: 6),
              _requirementRow('Minimum 8 caractères', _hasMinLength),
              _requirementRow('Au moins une lettre', _hasLetter),
              _requirementRow('Au moins un chiffre', _hasDigit),
              _requirementRow('Idéalement au moins un caractère spécial', _hasSpecial),

              const SizedBox(height: 16),

              Text(
                'Force du mot de passe',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey.shade700),
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: _strength,
                  minHeight: 6,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation(_strengthColor),
                ),
              ),

              const SizedBox(height: 28),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.orangeDark,
                    disabledBackgroundColor: Colors.grey.shade300,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  onPressed: _canSubmit ? _submit : null,
                  child: _loading
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text(
                          'Réinitialiser le mot de passe',
                          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
