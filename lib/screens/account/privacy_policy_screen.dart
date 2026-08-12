import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text('Politique de confidentialité', style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 16)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          Text(
            "Chez DAVIDSTORE, nous accordons une grande importance à la protection de vos données personnelles.\n\n"
            "Données collectées : nom, email, numéro de téléphone, adresses de livraison, historique de commandes.\n\n"
            "Utilisation : ces données servent uniquement à traiter vos commandes, améliorer votre expérience et vous contacter concernant vos achats.\n\n"
            "Partage : vos informations de paiement ne sont jamais stockées directement par DAVIDSTORE et transitent de façon sécurisée via nos prestataires de paiement mobile.\n\n"
            "Sécurité : vos données sont stockées sur des serveurs sécurisés et l'accès est strictement limité au personnel autorisé.\n\n"
            "Pour toute question concernant vos données, contactez notre support.",
            style: TextStyle(fontSize: 13, color: Color(0xFF334155), height: 1.6),
          ),
        ],
      ),
    );
  }
}
