import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'payment_screen.dart';

class DeliveryScreen extends StatefulWidget {
  const DeliveryScreen({super.key});

  @override
  State<DeliveryScreen> createState() => _DeliveryScreenState();
}

class _DeliveryScreenState extends State<DeliveryScreen> {
  int _selectedAddress = 0;

  final List<Map<String, String>> _addresses = [
    {
      'label': 'Maison',
      'address': '123, Avenue de la Paix,\nCommune de Gombe, Kinshasa, RDC',
      'phone': '+243 01 234 5678',
    },
    {
      'label': 'Bureau',
      'address': '456, Boulevard du 30 Juin,\nCommune de Gombe, Kinshasa, RDC',
      'phone': '+243 99 876 6422',
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
        title: const Text('Livraison',
            style: TextStyle(
                color: AppColors.textDark,
                fontSize: 18,
                fontWeight: FontWeight.w700)),
      ),
      body: Column(
        children: [
          _buildStepper(1),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                const Text('Adresse de livraison',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark)),
                const SizedBox(height: 16),
                ..._addresses.asMap().entries.map((entry) {
                  final i = entry.key;
                  final addr = entry.value;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedAddress = i),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: _selectedAddress == i
                              ? AppColors.orangeDark
                              : const Color(0xFFEEEEEE),
                          width: _selectedAddress == i ? 2 : 1,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(addr['label']!,
                                    style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textDark)),
                                const SizedBox(height: 4),
                                Text(addr['address']!,
                                    style: const TextStyle(
                                        fontSize: 13,
                                        color: AppColors.textGrey)),
                                const SizedBox(height: 4),
                                Text(addr['phone']!,
                                    style: const TextStyle(
                                        fontSize: 13,
                                        color: AppColors.textGrey)),
                              ],
                            ),
                          ),
                          Radio<int>(
                            value: i,
                            groupValue: _selectedAddress,
                            activeColor: AppColors.orangeDark,
                            onChanged: (val) =>
                                setState(() => _selectedAddress = val!),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () {},
                  child: Row(
                    children: const [
                      Icon(Icons.add_circle_outline,
                          color: AppColors.orangeDark),
                      SizedBox(width: 8),
                      Text('Ajouter une nouvelle adresse',
                          style: TextStyle(
                              color: AppColors.orangeDark,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
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
                        builder: (_) => const PaymentScreen()),
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
