import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import '../theme/app_theme.dart';
import '../services/payment_methods_service.dart';

// ⚠️ Remplace par l'URL de ton service une fois déployé sur Render.
const String kBackendBaseUrl = 'https://davidstore-payment.vercel.app';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  int _selectedMethod = 0;
  bool _isLoading = false;
  bool _isLoadingDefault = true;
  String? _errorMessage;

  final _paymentMethodsService = PaymentMethodsService();
  final TextEditingController _phoneController = TextEditingController();

  final List<Map<String, String>> _methods = [
    {'name': 'M-Pesa', 'desc': 'Paiement rapide et sécurisé', 'logo': 'assets/images/mpesa_logo.png'},
    {'name': 'Airtel Money', 'desc': 'Paiement rapide et sécurisé', 'logo': 'assets/images/airtel_money_logo.png'},
    {'name': 'Orange Money', 'desc': 'Paiement rapide et sécurisé', 'logo': 'assets/images/orange_money_logo.png'},
  ];

  @override
  void initState() {
    super.initState();
    _loadDefaultPaymentMethod();
  }

  Future<void> _loadDefaultPaymentMethod() async {
    try {
      final defaultMethod = await _paymentMethodsService.getDefaultPaymentMethod();
      if (defaultMethod != null && mounted) {
        final index = _methods.indexWhere((m) => m['name'] == defaultMethod.provider);
        final rawPhone = defaultMethod.phoneNumber.replaceFirst('+243', '');
        setState(() {
          if (index != -1) _selectedMethod = index;
          _phoneController.text = rawPhone;
        });
      }
    } catch (_) {
      // Pas grave si ça échoue : l'utilisateur remplit manuellement.
    } finally {
      if (mounted) setState(() => _isLoadingDefault = false);
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _payer({
    required String orderId,
    required double amount,
    required String userId,
  }) async {
    final rawPhone = _phoneController.text.trim();

    if (rawPhone.length != 9) {
      setState(() => _errorMessage = 'Entre les 9 chiffres de ton numéro (sans le +243)');
      return;
    }

    final fullPhoneNumber = '+243$rawPhone';

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await http.post(
        Uri.parse('$kBackendBaseUrl/api/shwary/pay'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'orderId': orderId,
          'amount': amount,
          'clientPhoneNumber': fullPhoneNumber,
          'userId': userId,
          'paymentMethod': _methods[_selectedMethod]['name'],
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (!mounted) return;
        Navigator.pushNamed(
          context,
          '/confirmation',
          arguments: {
            'orderId': orderId,
            'transactionId': data['transactionId'],
            'status': data['status'],
            'amount': amount,
          },
        );
      } else {
        setState(() {
          _errorMessage = data['error'] ?? 'Le paiement a échoué, réessaie.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Impossible de contacter le serveur. Vérifie ta connexion.';
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;

    if (args == null || args['orderId'] == null || args['amount'] == null || args['userId'] == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Impossible de charger le paiement : commande introuvable.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textGrey),
            ),
          ),
        ),
      );
    }

    final String orderId = args['orderId'];
    final double amount = (args['amount'] as num).toDouble();
    final String userId = args['userId'];

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back, color: AppColors.navyDark),
                  ),
                  const Text(
                    'Choisir le mode de paiement',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.navyDark),
                  ),
                  if (_isLoadingDefault) ...[
                    const SizedBox(width: 10),
                    const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ],
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Total à payer : ${amount.toStringAsFixed(0)} FC',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.orangeDark),
                ),
              ),
            ),
            const SizedBox(height: 8),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                children: [
                  ...List.generate(_methods.length, (index) {
                    final method = _methods[index];
                    final isSelected = _selectedMethod == index;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedMethod = index),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.whiteMuted,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected ? AppColors.orangeDark : Colors.grey.shade200,
                              width: isSelected ? 1.5 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.all(8),
                                child: Image.asset(
                                  method['logo']!,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(Icons.account_balance_wallet_outlined, color: AppColors.orangeDark),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      method['name']!,
                                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.navyDark),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      method['desc']!,
                                      style: const TextStyle(fontSize: 12, color: AppColors.textGrey),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                                color: isSelected ? AppColors.orangeDark : Colors.grey,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),

                  const SizedBox(height: 4),
                  const Text(
                    'Numéro mobile money',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.navyDark),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.whiteMuted,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Row(
                      children: [
                        const Text(
                          '+243',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.navyDark),
                        ),
                        const SizedBox(width: 8),
                        Container(width: 1, height: 24, color: Colors.grey.shade300),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _phoneController,
                            keyboardType: TextInputType.number,
                            maxLength: 9,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            decoration: const InputDecoration(
                              counterText: '',
                              border: InputBorder.none,
                              hintText: '812345678',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ],
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: Row(
                children: [
                  const Icon(Icons.lock_outline, size: 16, color: AppColors.textGrey),
                  const SizedBox(width: 6),
                  const Text('Paiement 100% sécurisé', style: TextStyle(fontSize: 12, color: AppColors.textGrey)),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: ElevatedButton(
                onPressed: _isLoading
                    ? null
                    : () => _payer(orderId: orderId, amount: amount, userId: userId),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.orangeDark,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  minimumSize: const Size(double.infinity, 0),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text(
                        'Payer maintenant',
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
