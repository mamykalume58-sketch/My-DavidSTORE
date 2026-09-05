import 'package:flutter/material.dart';

class AccountNotificationsScreen extends StatefulWidget {
  const AccountNotificationsScreen({super.key});

  @override
  State<AccountNotificationsScreen> createState() => _AccountNotificationsScreenState();
}

class _AccountNotificationsScreenState extends State<AccountNotificationsScreen> {
  bool _toutesNotifs = true;
  bool _majCommande = true;
  bool _livraison = true;
  bool _offres = true;
  bool _nouveauxProduits = false;
  bool _actualites = true;
  bool _enquetes = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text('Notifications', style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 17)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSwitch('Activer toutes les notifications', _toutesNotifs, (v) => setState(() => _toutesNotifs = v), theme),
          const SizedBox(height: 16),
          _buildSectionTitle('Commandes'),
          _buildSwitch('Mises à jour de commande', _majCommande, (v) => setState(() => _majCommande = v), theme),
          _buildSwitch('Livraison et statut', _livraison, (v) => setState(() => _livraison = v), theme),
          const SizedBox(height: 16),
          _buildSectionTitle('Promotions'),
          _buildSwitch('Offres et promotions', _offres, (v) => setState(() => _offres = v), theme),
          _buildSwitch('Nouveaux produits', _nouveauxProduits, (v) => setState(() => _nouveauxProduits = v), theme),
          const SizedBox(height: 16),
          _buildSectionTitle('Autres'),
          _buildSwitch('Actualités de l\'application', _actualites, (v) => setState(() => _actualites = v), theme),
          _buildSwitch('Enquêtes et avis', _enquetes, (v) => setState(() => _enquetes = v), theme),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
    );
  }

  Widget _buildSwitch(String label, bool value, ValueChanged<bool> onChanged, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
      child: SwitchListTile(
        title: Text(label, style: const TextStyle(fontSize: 14, color: Color(0xFF0F172A))),
        value: value,
        onChanged: onChanged,
        activeColor: theme.primaryColor,
        contentPadding: EdgeInsets.zero,
      ),
    );
  }
}
