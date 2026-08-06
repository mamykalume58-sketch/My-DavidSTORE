import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  int _selectedMethod = 0;

  final List<Map<String, String>> _methods = [
    {'name': 'M-Pesa', 'desc': 'Paiement rapide et sécurisé', 'logo': 'assets/images/mpesa_logo.png'},
    {'name': 'Airtel Money', 'desc': 'Paiement rapide et sécurisé', 'logo': 'assets/images/airtel_money_logo.png'},
    {'name': 'Orange Money', 'desc': 'Paiement rapide et sécurisé', 'logo': 'assets/images/orange_money_logo.png'},
  ];

  void _payer() {
    Navigator.pushNamed(context, '/confirmation');
  }

  @override
  Widget build(BuildContext context) {
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
                ],
              ),
            ),

            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                itemCount: _methods.length,
                separatorBuilder: (_, __) => const SizedBox(height: 14),
                itemBuilder: (context, index) {
                  final method = _methods[index];
                  final isSelected = _selectedMethod == index;
                  return GestureDetector(
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
                  );
                },
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
                onPressed: _payer,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.orangeDark,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  minimumSize: const Size(double.infinity, 0),
                ),
                child: const Text(
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
