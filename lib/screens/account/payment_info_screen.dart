import 'package:flutter/material.dart';

class PaymentInfoScreen extends StatelessWidget {
  const PaymentInfoScreen({super.key});

  Widget _section(String title, String content) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
          const SizedBox(height: 8),
          Text(content, style: const TextStyle(fontSize: 13, color: Color(0xFF64748B), height: 1.5)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text('Paiement', style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 17)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _section(
            'Moyens de paiement acceptés',
            'Airtel Money, M-Pesa, Orange Money et carte Visa. Tu peux gérer tes moyens de paiement depuis Mes moyens de paiement.',
          ),
          _section(
            'Sécurité des paiements',
            'Toutes les transactions sont chiffrées et traitées par des partenaires de paiement certifiés. Nous ne stockons jamais tes identifiants Mobile Money.',
          ),
          _section(
            'Facturation',
            'Un reçu est généré automatiquement après chaque paiement validé et reste consultable dans le détail de ta commande.',
          ),
          _section(
            'Échec de paiement',
            "En cas d'échec, vérifie ton solde ou réessaie avec un autre moyen de paiement. Si le problème persiste, contacte notre support.",
          ),
        ],
      ),
    );
  }
}
