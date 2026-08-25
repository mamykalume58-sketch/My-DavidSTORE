import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class SecurityScreen extends StatefulWidget {
  const SecurityScreen({super.key});

  @override
  State<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> with WidgetsBindingObserver {
  bool _sendingVerification = false;
  DateTime? _lastVerificationSent;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshUser();
    }
  }

  Future<void> _refreshUser() async {
    try {
      await FirebaseAuth.instance.currentUser?.reload();
      if (mounted) setState(() {});
    } catch (_) {
      // Ignore silencieusement, l'etat affiche restera celui connu
    }
  }

  Future<void> _resendVerification() async {
    final now = DateTime.now();
    if (_lastVerificationSent != null && now.difference(_lastVerificationSent!).inSeconds < 60) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Merci de patienter avant de renvoyer un nouvel email.')),
      );
      return;
    }

    setState(() => _sendingVerification = true);
    try {
      final email = FirebaseAuth.instance.currentUser?.email;
      if (email != null) {
        await http.post(
          Uri.parse('https://davidstore-payment.vercel.app/api/auth/send-verification'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'email': email}),
        );
        _lastVerificationSent = now;
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Email de verification envoye.')),
          );
        }
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur lors de l\'envoi. Reessaie plus tard.')),
        );
      }
    } finally {
      if (mounted) setState(() => _sendingVerification = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final emailVerified = user?.emailVerified ?? false;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text('Sécurité', style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 17)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildTile(
            context,
            Icons.mail_outline,
            'Adresse e-mail',
            user?.email ?? 'Non renseignee',
            null,
            badge: emailVerified ? 'Vérifié' : 'Non vérifié',
            badgeColor: emailVerified ? Colors.green : Colors.orange,
            trailingAction: !emailVerified
                ? TextButton(
                    onPressed: _sendingVerification ? null : _resendVerification,
                    child: _sendingVerification
                        ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text('Renvoyer', style: TextStyle(fontSize: 12)),
                  )
                : null,
          ),
          _buildTile(context, Icons.lock_outline, 'Mot de passe', 'Modifier votre mot de passe', '/account/change-password'),
          _buildTile(context, Icons.devices_outlined, 'Appareils connectés', 'Gérez vos appareils', '/account/connected-devices'),
          _buildTile(context, Icons.history_outlined, 'Sessions actives', 'Voir et fermer vos sessions', '/account/active-sessions'),
        ],
      ),
    );
  }

  Widget _buildTile(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    String? route, {
    String? badge,
    Color? badgeColor,
    Widget? trailingAction,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF475569)),
        title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
        trailing: trailingAction ??
            (badge != null
                ? Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: (badgeColor ?? Colors.green).withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                    child: Text(badge, style: TextStyle(fontSize: 10, color: badgeColor ?? Colors.green, fontWeight: FontWeight.bold)),
                  )
                : const Icon(Icons.chevron_right, size: 20, color: Colors.grey)),
        onTap: route != null ? () => Navigator.pushNamed(context, route) : null,
      ),
    );
  }
}
