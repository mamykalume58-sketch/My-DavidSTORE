import 'package:flutter/material.dart';

class ReturnsInfoScreen extends StatelessWidget {
  const ReturnsInfoScreen({super.key});

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
        title: const Text('Retour et remboursement', style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 17)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _section(
            'Politique de retour',
            'Tu disposes de 7 jours après réception pour demander un retour, à condition que l\'article soit inutilisé et dans son emballage d\'origine.',
          ),
          _section(
            'Articles non retournables',
            'Les produits périssables, personnalisés ou intimes ne peuvent pas être retournés pour des raisons d\'hygiène et de sécurité.',
          ),
          _section(
            'Comment faire une demande',
            "Contacte notre support via WhatsApp ou l'assistante Nicole en précisant le numéro de commande et le motif du retour.",
          ),
          _section(
            'Délais de remboursement',
            'Une fois le retour validé, le remboursement est effectué sous 3 à 7 jours ouvrés sur le moyen de paiement utilisé lors de l\'achat.',
          ),
        ],
      ),
    );
  }
}
