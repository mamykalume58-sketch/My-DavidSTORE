import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class TrackingStep {
  final String title;
  final String date;
  final bool done;

  TrackingStep({required this.title, required this.date, this.done = false});
}

class OrderTrackingScreen extends StatelessWidget {
  final String orderNumber;

  const OrderTrackingScreen({super.key, this.orderNumber = 'DS-2024-000123'});

  List<TrackingStep> get _steps => [
        TrackingStep(title: 'Commande confirmée', date: '25 Mai 2024 - 10:30', done: true),
        TrackingStep(title: 'Paiement reçu', date: '25 Mai 2024 - 10:32', done: true),
        TrackingStep(title: 'Préparation en cours', date: '25 Mai 2024 - 14:15', done: true),
        TrackingStep(title: 'En cours de livraison', date: '26 Mai 2024 - 09:00', done: true),
        TrackingStep(title: 'Livré', date: 'Estimation : 27 Mai 2024', done: false),
      ];

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
                    'Suivi de commande',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.navyDark),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.whiteMuted,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Commande', style: TextStyle(fontSize: 12, color: AppColors.textGrey)),
                          const SizedBox(height: 4),
                          Text(
                            orderNumber,
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.navyDark),
                          ),
                          const SizedBox(height: 4),
                          const Text('Passée le 25 Mai 2024', style: TextStyle(fontSize: 12, color: AppColors.textGrey)),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    ...List.generate(_steps.length, (index) {
                      final step = _steps[index];
                      final isLast = index == _steps.length - 1;
                      return IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              children: [
                                Container(
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    color: step.done ? AppColors.orangeDark : Colors.grey.shade300,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    step.done ? Icons.check : Icons.circle,
                                    color: Colors.white,
                                    size: step.done ? 16 : 8,
                                  ),
                                ),
                                if (!isLast)
                                  Expanded(
                                    child: Container(
                                      width: 2,
                                      color: step.done ? AppColors.orangeDark : Colors.grey.shade300,
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 24),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      step.title,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: step.done ? AppColors.navyDark : AppColors.textGrey,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      step.date,
                                      style: const TextStyle(fontSize: 12, color: AppColors.textGrey),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.orangeDark),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  minimumSize: const Size(double.infinity, 0),
                ),
                child: const Text(
                  'Contacter le support',
                  style: TextStyle(color: AppColors.orangeDark, fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
