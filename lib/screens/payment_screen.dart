import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'confirmation_screen.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  int _selectedPayment = 0;

  final List<Map<String, dynamic>> _methods = [
    {
      'name': 'M-Pesa',
      'color': const Color(0xFF00A651),
      'icon': Icons.phone_android,
    },
    {
      'name': 'Airtel Money',
      'color': const Color(0xFFE40000),
      'icon': Icons.phone_android,
    },
    {
      'name': 'Orange Money',
      'color': const Color(0xFFFF6600),
      'icon': Icons.phone_android,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Paiement',
            style: TextStyle(
                color: AppColors.textDark,
                fontSize: 18,
                fontWeight: FontWeight.w700)),
      ),
      body: Column(
        children: [
          _buildStepper(2),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                const Text('Méthode de paiement',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark)),
                const SizedBox(height: 4),
                const Text('Choisissez votre moyen de paiement mobile money',
                    style: TextStyle(
                        fontSize: 13, color: AppColors.textGrey)),
                const SizedBox(height: 16),
                ..._methods.asMap().entries.map((entry) {
                  final i = entry.key;
                  final method = entry.value;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedPayment = i),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: _selectedPayment == i
                              ? AppColors.orangeDark
                              : const Color(0xFFEEEEEE),
                          width: _selectedPayment == i ? 2 : 1,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: (method['color'] as Color)
                                  .withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(method['icon'] as IconData,
                                color: method['color'] as Color),
                          ),
                          const SizedBox(width: 16),
                          Text(method['name'] as String,
                              style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textDark)),
                          const Spacer(),
                          Radio<int>(
                            value: i,
                            groupValue: _selectedPayment,
                            activeColor: AppColors.orangeDark,
                            onChanged: (val) =>
                                setState(() => _selectedPayment = val!),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const ConfirmationScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.orangeDark,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Continuer',
                    style: TextStyle(
                        color: AppColors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepper(int currentStep) {
    final steps = ['Livraison', 'Paiement', 'Confirmation'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: List.generate(steps.length, (i) {
          final isActive = i + 1 == currentStep;
          final isDone = i + 1 < currentStep;
          return Expanded(
            child: Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: isActive || isDone
                      ? AppColors.orangeDark
                      : const Color(0xFFEEEEEE),
                  child: Text('${i + 1}',
                      style: TextStyle(
                          color: isActive || isDone
                              ? AppColors.white
                              : AppColors.textGrey,
                          fontSize: 12,
                          fontWeight: FontWeight.w700)),
                ),
                const SizedBox(width: 6),
                Text(steps[i],
                    style: TextStyle(
                        fontSize: 12,
                        color: isActive || isDone
                            ? AppColors.orangeDark
                            : AppColors.textGrey,
                        fontWeight: isActive
                            ? FontWeight.w700
                            : FontWeight.normal)),
                if (i < steps.length - 1)
                  Expanded(
                    child: Container(
                      height: 1,
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      color: isDone
                          ? AppColors.orangeDark
                          : const Color(0xFFEEEEEE),
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
