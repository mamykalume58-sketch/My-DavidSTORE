import 'package:flutter/material.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  static const List<Map<String, String>> _faqs = [
    {
      'question': 'Comment suivre ma commande ?',
      'answer': "Rends-toi dans l'onglet Suivi depuis le menu principal pour voir le statut en temps réel de ta commande.",
    },
    {
      'question': 'Quels moyens de paiement acceptez-vous ?',
      'answer': 'Nous acceptons Airtel Money, M-Pesa et Orange Money.',
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text("Centre d'aide", style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 17)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 8, left: 4),
            child: Text('Questions fréquentes', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
          ),
          ..._faqs.map((faq) {
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
          }),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Besoin de plus d\'aide ?', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
                const SizedBox(height: 8),
                const Text('Notre équipe support est disponible pour répondre à toutes tes questions.', style: TextStyle(fontSize: 13, color: Color(0xFF64748B))),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pushNamed(context, '/support-chat'),
                    child: const Text('Contacter le support'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
