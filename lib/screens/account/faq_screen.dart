import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

const List<Map<String, String>> _fallbackFaqs = [
  {
    'question': 'Comment passer une commande ?',
    'answer': 'Ajoute les articles souhaités à ton panier, puis suis les étapes de la commande jusqu\'au paiement.',
  },
  {
    'question': 'Comment suivre ma commande ?',
    'answer': "Rends-toi dans l'onglet Suivi depuis le menu principal pour voir le statut en temps réel de ta commande.",
  },
  {
    'question': 'Quels moyens de paiement acceptez-vous ?',
    'answer': 'Nous acceptons Airtel Money, M-Pesa, Orange Money et les cartes Visa.',
  },
  {
    'question': 'Comment utiliser un coupon de réduction ?',
    'answer': 'Sélectionne un coupon disponible dans Mes coupons, il sera automatiquement appliqué au moment du paiement.',
  },
  {
    'question': 'Comment retourner un article ?',
    'answer': "Contacte notre support via WhatsApp ou l'assistante Nicole pour lancer une demande de retour.",
  },
  {
    'question': 'Combien de temps prend la livraison ?',
    'answer': 'Le délai de livraison varie selon ta localisation, généralement entre 1 et 5 jours ouvrés.',
  },
];

class FaqScreen extends StatelessWidget {
  const FaqScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text('FAQ', style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 17)),
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance.collection('contentPages').doc('faq').snapshots(),
        builder: (context, snapshot) {
          final rawItems = snapshot.data?.data()?['items'] as List<dynamic>?;
          final faqs = rawItems != null && rawItems.isNotEmpty
              ? rawItems.map((e) => Map<String, String>.from(e as Map)).toList()
              : _fallbackFaqs;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: faqs.map((faq) {
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: ExpansionTile(
                  title: Text(faq['question']!, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
                  childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  expandedCrossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(faq['answer']!, style: const TextStyle(fontSize: 13, color: Color(0xFF64748B))),
                  ],
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
