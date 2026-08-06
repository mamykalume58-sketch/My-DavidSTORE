import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  int _selectedDelivery = 0;

  final List<Map<String, String>> _deliveryOptions = [
    {'label': 'Livraison standard (3-5 jours)', 'price': 'Gratuite'},
    {'label': 'Livraison express (1-2 jours)', 'price': '10 000 FC'},
  ];

  static const int _sousTotal = 1375000;

  int get _fraisLivraison => _selectedDelivery == 1 ? 10000 : 0;
  int get _total => _sousTotal + _fraisLivraison;

  String _formatPrice(int value) {
    final str = value.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) buffer.write(' ');
      buffer.write(str[i]);
    }
    return '${buffer.toString()} FC';
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
                    'Informations de livraison',
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
                    const Text(
                      'Adresse de livraison',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.navyDark),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.whiteMuted,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.location_on_outlined, color: AppColors.orangeDark),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Gaël Mpanga', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark)),
                                SizedBox(height: 4),
                                Text(
                                  'C/ de Lubumbashi Q/ Mampala à la Gécamine, Lubumbashi',
                                  style: TextStyle(fontSize: 13, color: AppColors.textGrey),
                                ),
                                SizedBox(height: 4),
                                Text('+243 97 000 00 00', style: TextStyle(fontSize: 13, color: AppColors.textGrey)),
                              ],
                            ),
                          ),
                          TextButton(
                            onPressed: () {},
                            child: const Text('Changer', style: TextStyle(color: AppColors.orangeDark, fontSize: 13)),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),
                    const Text(
                      'Méthode de livraison',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.navyDark),
                    ),
                    const SizedBox(height: 10),
                    ...List.generate(_deliveryOptions.length, (index) {
                      final option = _deliveryOptions[index];
                      final isSelected = _selectedDelivery == index;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedDelivery = index),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: AppColors.whiteMuted,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isSelected ? AppColors.orangeDark : Colors.grey.shade200,
                              width: isSelected ? 1.5 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                                color: isSelected ? AppColors.orangeDark : Colors.grey,
                                size: 20,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(option['label']!, style: const TextStyle(fontSize: 13, color: AppColors.textDark)),
                              ),
                              Text(
                                option['price']!,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: option['price'] == 'Gratuite' ? Colors.green : AppColors.navyDark,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),

                    const SizedBox(height: 20),
                    const Text(
                      'Résumé de commande',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.navyDark),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Sous-total', style: TextStyle(color: AppColors.textGrey)),
                        Text(_formatPrice(_sousTotal), style: const TextStyle(fontWeight: FontWeight.w600)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Livraison', style: TextStyle(color: AppColors.textGrey)),
                        Text(
                          _fraisLivraison == 0 ? 'Gratuite' : _formatPrice(_fraisLivraison),
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: _fraisLivraison == 0 ? Colors.green : AppColors.navyDark,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.navyDark)),
                        Text(
                          _formatPrice(_total),
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.orangeDark),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/payment'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.orangeDark,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  minimumSize: const Size(double.infinity, 0),
                ),
                child: const Text(
                  'Choisir le mode de paiement',
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
