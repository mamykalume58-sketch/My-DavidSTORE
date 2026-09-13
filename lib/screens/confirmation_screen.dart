import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../utils/price_formatter.dart';
import 'home/home_screen.dart';

class ConfirmationScreen extends StatelessWidget {
  const ConfirmationScreen({super.key});

  Map<String, dynamic> _stateFor(String status) {
    switch (status) {
      case 'completed':
      case 'success':
        return {
          'color': Colors.green,
          'icon': Icons.check,
          'title': 'Paiement confirmé',
          'message': 'Votre commande a été enregistrée avec succès.',
          'showDeliveryNote': true,
        };
      case 'failed':
      case 'cancelled':
        return {
          'color': Colors.red,
          'icon': Icons.close,
          'title': 'Le paiement a échoué',
          'message': 'Le paiement n\'a pas pu être finalisé.\nVous pouvez réessayer depuis vos commandes.',
          'showDeliveryNote': false,
        };
      default:
        return {
          'color': Colors.orange,
          'icon': Icons.access_time,
          'title': 'Paiement en cours de vérification',
          'message': 'Nous vérifions votre paiement.\nVous serez notifié dès confirmation.',
          'showDeliveryNote': false,
        };
    }
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final orderId = args?['orderId'] as String?;
    final fallbackAmount = (args?['amount'] as num?)?.toInt() ?? 0;
    final fallbackStatus = args?['status']?.toString() ?? 'pending';

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text('Confirmation',
            style: TextStyle(
                color: AppColors.textDark,
                fontSize: 18,
                fontWeight: FontWeight.w700)),
      ),
      body: Column(
        children: [
          _buildStepper(3),
          Expanded(
            child: orderId == null
                ? _buildBody(
                    context,
                    status: fallbackStatus,
                    amount: fallbackAmount,
                    orderNumber: null,
                  )
                : StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                    stream: FirebaseFirestore.instance.collection('orders').doc(orderId).snapshots(),
                    builder: (context, snapshot) {
                      final data = snapshot.data?.data();
                      final status = data?['paymentStatus']?.toString() ?? fallbackStatus;
                      final amount = (data?['total'] as num?)?.toInt() ?? fallbackAmount;
                      final orderNumber = data?['orderNumber']?.toString();

                      return _buildBody(
                        context,
                        status: status,
                        amount: amount,
                        orderNumber: orderNumber,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(
    BuildContext context, {
    required String status,
    required int amount,
    required String? orderNumber,
  }) {
    final state = _stateFor(status);
    final isSuccess = status == 'completed' || status == 'success';
    final isFailed = status == 'failed' || status == 'cancelled';

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: state['color'] as Color,
                shape: BoxShape.circle,
              ),
              child: Icon(state['icon'] as IconData,
                  color: Colors.white, size: 48),
            ),
            const SizedBox(height: 24),
            Text(state['title'] as String,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark)),
            const SizedBox(height: 8),
            Text(
              state['message'] as String,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 14, color: AppColors.textGrey),
            ),
            if (state['showDeliveryNote'] == true) ...[
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.local_shipping_outlined, color: Colors.green, size: 22),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Un livreur vous contactera prochainement pour la livraison.',
                        style: TextStyle(fontSize: 13, color: AppColors.textDark),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (orderNumber != null) ...[
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F7F7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    _infoRow('Numéro de commande', orderNumber),
                    const SizedBox(height: 8),
                    _infoRow('Total', formatPrice(amount), valueColor: AppColors.orangeDark),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: () {
                  if (isFailed) {
                    Navigator.pushNamedAndRemoveUntil(context, '/tracking', (route) => false);
                  } else if (isSuccess) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const HomeScreen()),
                      (route) => false,
                    );
                  } else {
                    Navigator.pushNamedAndRemoveUntil(context, '/tracking', (route) => false);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isSuccess ? Colors.green : AppColors.orangeDark,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  isSuccess
                      ? 'CONTINUER MES ACHATS'
                      : (isFailed ? 'Réessayer' : 'Voir mes commandes'),
                  style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 13, color: AppColors.textGrey)),
        Text(value,
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: valueColor ?? AppColors.textDark)),
      ],
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
