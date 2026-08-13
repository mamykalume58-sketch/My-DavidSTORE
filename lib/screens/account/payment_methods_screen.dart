import 'package:flutter/material.dart';
import '../../models/payment_method.dart';
import '../../services/payment_methods_service.dart';

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  final _service = PaymentMethodsService();

  final List<Map<String, String>> _providers = [
    {'name': 'Airtel Money', 'logo': 'assets/images/airtel_money_logo.png'},
    {'name': 'M-Pesa', 'logo': 'assets/images/mpesa_logo.png'},
    {'name': 'Orange Money', 'logo': 'assets/images/orange_money_logo.png'},
  ];

  void _openAddMethodSheet() {
    String? selectedProvider;
    final phoneController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Ajouter un moyen de paiement', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                  const SizedBox(height: 16),
                  const Text('Opérateur', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                  const SizedBox(height: 8),
                  Row(
                    children: _providers.map((p) {
                      final isSelected = selectedProvider == p['name'];
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => setModalState(() => selectedProvider = p['name']),
                          child: Container(
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              border: Border.all(color: isSelected ? Theme.of(context).primaryColor : Colors.grey.shade300, width: isSelected ? 2 : 1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                Image.asset(p['logo']!, width: 32, height: 32, errorBuilder: (_, __, ___) => const Icon(Icons.phone_android)),
                                const SizedBox(height: 4),
                                Text(p['name']!, style: const TextStyle(fontSize: 10), textAlign: TextAlign.center),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  const Text('Numéro de téléphone', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                        decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(12)),
                        child: const Text('+243', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            hintText: '812345678',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () async {
                        final rawPhone = phoneController.text.trim();
                        if (selectedProvider == null || rawPhone.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Choisis un opérateur et entre ton numéro.')));
                          return;
                        }
                        await _service.addPaymentMethod(
                          provider: selectedProvider!,
                          phoneNumber: '+243$rawPhone',
                        );
                        if (ctx.mounted) Navigator.pop(ctx);
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).primaryColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      child: const Text('Ajouter', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text('Mes moyens de paiement', style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 17)),
      ),
      body: StreamBuilder<List<PaymentMethod>>(
        stream: _service.watchPaymentMethods(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erreur : ${snapshot.error}'));
          }
          final methods = snapshot.data ?? [];

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (methods.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: Text('Aucun moyen de paiement enregistré', style: TextStyle(color: Color(0xFF64748B))),
                  ),
                ),
              ...methods.map((m) => GestureDetector(
                    onTap: m.isDefault ? null : () => _service.setAsDefault(m.id),
                    onLongPress: () => _confirmDelete(m),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.grey.shade200)),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(10)),
                            child: Image.asset(
                              m.logoAsset,
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) => const Icon(Icons.phone_android, color: Colors.grey),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(m.provider, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F172A))),
                                const SizedBox(height: 2),
                                Text(m.phoneNumber, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                              ],
                            ),
                          ),
                          if (m.isDefault)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(color: theme.primaryColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                              child: Text('Par défaut', style: TextStyle(fontSize: 10, color: theme.primaryColor, fontWeight: FontWeight.bold)),
                            )
                          else
                            const Icon(Icons.chevron_right, color: Colors.grey),
                        ],
                      ),
                    ),
                  )),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: _openAddMethodSheet,
                  icon: const Icon(Icons.add),
                  label: const Text('Ajouter un moyen de paiement'),
                  style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _confirmDelete(PaymentMethod m) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer ce moyen ?'),
        content: Text('${m.provider} · ${m.phoneNumber}'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
          TextButton(
            onPressed: () {
              _service.deletePaymentMethod(m.id);
              Navigator.pop(ctx);
            },
            child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
