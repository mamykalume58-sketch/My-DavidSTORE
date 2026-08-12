import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  Future<void> _submit() async {
    if (_newController.text != _confirmController.text) {
      setState(() => _error = 'Les mots de passe ne correspondent pas.');
      return;
    }
    if (_newController.text.length < 6) {
      setState(() => _error = 'Le nouveau mot de passe doit contenir au moins 6 caractères.');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      final email = user?.email;
      if (user == null || email == null) {
        throw Exception('Utilisateur non connecté');
      }
      final credential = EmailAuthProvider.credential(email: email, password: _currentController.text);
      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(_newController.text);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Mot de passe mis à jour avec succès.')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() => _error = "Impossible de modifier le mot de passe. Vérifie ton mot de passe actuel.");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text('Modifier le mot de passe', style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 16)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 13)),
            ),
          TextField(
            controller: _currentController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'Mot de passe actuel',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _newController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'Nouveau mot de passe',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _confirmController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'Confirmer le nouveau mot de passe',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _submit,
              child: _isLoading
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Mettre à jour'),
            ),
          ),
        ],
      ),
    );
  }
}
