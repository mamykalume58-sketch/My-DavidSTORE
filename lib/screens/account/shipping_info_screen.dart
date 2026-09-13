import 'package:flutter/material.dart';

class ShippingInfoScreen extends StatelessWidget {
  const ShippingInfoScreen({super.key});

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
        title: const Text('Livraison', style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 17)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _section(
            'Zones de livraison',
            'Nous livrons actuellement à Kinshasa, Lubumbashi et Goma. La couverture s\'étend progressivement à d\'autres villes.',
          ),
          _section(
            'Délais de livraison',
            'Le délai moyen est de 1 à 3 jours ouvrés à Kinshasa, et de 3 à 5 jours ouvrés pour les autres villes couvertes.',
          ),
          _section(
            'Frais de livraison',
            'Les frais varient selon la zone et le poids de la commande. Ils sont calculés automatiquement et affichés avant la validation du paiement.',
          ),
          _section(
            'Suivi de commande',
            "Une fois ta commande expédiée, tu peux suivre son statut en temps réel depuis l'onglet Suivi.",
          ),
        ],
      ),
    );
  }
}
