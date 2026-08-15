import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../utils/price_formatter.dart';
import 'home/home_screen.dart';

class ConfirmationScreen extends StatefulWidget {
  const ConfirmationScreen({super.key});

  @override
  State<ConfirmationScreen> createState() => _ConfirmationScreenState();
}

class _ConfirmationScreenState extends State<ConfirmationScreen> {
  String? _orderNumber;
  bool _loadingOrder = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loadingOrder) {
      _fetchOrderNumber();
    }
  }

  Future<void> _fetchOrderNumber() async {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final orderId = args?['orderId'] as String?;
    if (orderId == null) {
      setState(() => _loadingOrder = false);
      return;
    }
    try {
      final doc = await FirebaseFirestore.instance.collection('orders').doc(orderId).get();
      if (mounted) {
        setState(() {
          _orderNumber = doc.data()?['orderNumber']?.toString();
          _loadingOrder = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loadingOrder = false);
    }
  }

  Map<String, dynamic> _stateFor(String status) {
    switch (status) {
      case 'completed':
      case 'success':
        return {
          'color': Colors.green,
          'icon': Icons.check,
          'title': 'Commande confirmée !',
          'message': 'Merci pour votre achat.\nVotre commande a été enregistrée avec succès.',
        };
      case 'failed':
      case 'cancelled':
        return {
          'color': Colors.red,
          'icon': Icons.close,
          'title': 'Le paiement a échoué',
          'message': 'Le paiement n\'a pas pu être finalisé.\nVous pouvez réessayer depuis vos commandes.',
        };
      default:
        return {
          'color': Colors.orange,
          'icon': Icons.access_time,
          'title': 'Paiement en cours de vérification',
          'message': 'Nous vérifions votre paiement.\nVous serez notifié dès confirmation.',
        };
    }
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final status = args?['status']?.toString() ?? 'pending';
    final amount = (args?['amount'] as num?)?.toInt() ?? 0;
    final state = _stateFor(status);
    final isSuccess = status == 'completed' || status == 'success';

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
            child: Center(
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
                    const SizedBox(height: 32),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7F7F7),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          _infoRow('Numéro de commande',
                              _loadingOrder ? '...' : (_orderNumber ?? '—')),
                          const SizedBox(height: 12),
                          _infoRow('Total payé', formatPrice(amount),
                              valueColor: AppColors.orangeDark),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            isSuccess ? '/profile' : '/tracking',
                            (route) => false,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.orangeDark,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(isSuccess ? 'Voir mes commandes' : 'Retour à mes commandes',
                            style: const TextStyle(
                                color: AppColors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const HomeScreen()),
                          (route) => false,
                        );
                      },
                      child: const Text('Retour à l\'accueil',
                          style: TextStyle(
                              color: AppColors.orangeDark,
                              fontSize: 14)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
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
