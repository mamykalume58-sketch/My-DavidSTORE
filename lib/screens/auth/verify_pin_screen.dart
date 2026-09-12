import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_snackbar.dart';

class VerifyPinScreen extends StatefulWidget {
  final String email;
  final String requestId;

  const VerifyPinScreen({
    super.key,
    required this.email,
    required this.requestId,
  });

  @override
  State<VerifyPinScreen> createState() => _VerifyPinScreenState();
}

class _VerifyPinScreenState extends State<VerifyPinScreen> {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  final AuthService _authService = AuthService();

  bool _loading = false;
  int _resendSeconds = 45;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  void _startResendTimer() {
    _resendSeconds = 45;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendSeconds <= 1) {
        timer.cancel();
        setState(() => _resendSeconds = 0);
      } else {
        setState(() => _resendSeconds--);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  String get _pin => _controllers.map((c) => c.text).join();

  Future<void> _verify() async {
    if (_pin.length != 6) {
      AppSnackBar.info(context, 'Veuillez entrer les 6 chiffres du code');
      return;
    }

    setState(() => _loading = true);

    try {
      final resetToken = await _authService.verifyResetPin(widget.requestId, _pin);

      if (mounted) {
        Navigator.pushNamed(
          context,
          '/new-password',
          arguments: {
            'requestId': widget.requestId,
            'resetToken': resetToken,
          },
        );
      }
    } catch (e) {
      if (mounted) {
        AppSnackBar.errorFromException(context, e);
        for (final c in _controllers) {
          c.clear();
        }
        _focusNodes[0].requestFocus();
      }
    }

    if (mounted) setState(() => _loading = false);
  }

  Future<void> _resend() async {
    if (_resendSeconds > 0) return;

    try {
      await _authService.requestResetPin(widget.email);
      if (mounted) {
        AppSnackBar.success(context, 'Un nouveau code a été envoyé');
        _startResendTimer();
      }
    } catch (e) {
      if (mounted) {
        AppSnackBar.errorFromException(context, e);
      }
    }
  }

  Widget _pinBox(int index) {
    return SizedBox(
      width: 44,
      height: 52,
      child: TextField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.navyDark),
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.zero,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.orangeDark, width: 1.5),
          ),
        ),
        onChanged: (value) {
          if (value.isNotEmpty && index < 5) {
            _focusNodes[index + 1].requestFocus();
          } else if (value.isEmpty && index > 0) {
            _focusNodes[index - 1].requestFocus();
          }
          if (index == 5 && value.isNotEmpty) {
            FocusScope.of(context).unfocus();
          }
          setState(() {});
        },
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
          'Vérification',
          style: TextStyle(color: AppColors.navyDark, fontWeight: FontWeight.w600),
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
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    color: AppColors.navyDark.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.verified_user_outlined, size: 44, color: AppColors.navyDark),
                ),
              ),

              const SizedBox(height: 24),

              Text(
                'Nous avons envoyé un code à 6 chiffres à votre adresse e-mail. Entrez-le ci-dessous pour continuer.',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600, height: 1.4),
              ),

              const SizedBox(height: 28),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (i) => _pinBox(i)),
              ),

              const SizedBox(height: 28),

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
                  onPressed: _loading ? null : _verify,
                  child: _loading
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text(
                          'Vérifier le code',
                          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
              ),

              const SizedBox(height: 20),

              Center(
                child: _resendSeconds > 0
                    ? Text(
                        'Renvoyer le code dans $_resendSeconds secondes',
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                      )
                    : GestureDetector(
                        onTap: _resend,
                        child: const Text(
                          'Renvoyer le code',
                          style: TextStyle(color: AppColors.orangeDark, fontWeight: FontWeight.w600, fontSize: 13),
                        ),
                      ),
              ),

              const SizedBox(height: 8),

              Center(
                child: Text(
                  "Vous n'avez pas reçu le code ? Vérifiez vos spams.",
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
