import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth/firebase_auth.dart';

enum _SnackType { success, error, info }

/// Helper centralisé pour des SnackBars cohérentes dans toute l'app :
/// icône + couleur selon le type, carte blanche arrondie, style uniforme.
class AppSnackBar {
  static void success(
    BuildContext context,
    String message, {
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    _show(context, message, _SnackType.success, actionLabel: actionLabel, onAction: onAction);
  }

  static void error(BuildContext context, String message) {
    _show(context, message, _SnackType.error);
  }

  /// Traduit une exception Firebase en message compréhensible pour
  /// l'utilisateur, au lieu d'afficher le texte technique brut.
  static void errorFromException(BuildContext context, Object err, {String? fallback}) {
    final message = _friendlyMessage(err) ?? fallback ?? 'Une erreur est survenue. Réessaie.';
    error(context, message);
  }

  static String? _friendlyMessage(Object err) {
    if (err is FirebaseAuthException) {
      switch (err.code) {
        case 'wrong-password':
        case 'invalid-credential':
          return 'Mot de passe incorrect.';
        case 'user-not-found':
          return 'Aucun compte trouvé avec cet email.';
        case 'invalid-email':
          return 'Adresse email invalide.';
        case 'email-already-in-use':
          return 'Cet email est déjà utilisé.';
        case 'weak-password':
          return 'Le mot de passe doit contenir au moins 6 caractères.';
        case 'too-many-requests':
          return 'Trop de tentatives. Réessaie dans quelques minutes.';
        case 'network-request-failed':
          return 'Vérifie ta connexion internet.';
        default:
          return null;
      }
    }
    return null;
  }

  static void info(BuildContext context, String message) {
    _show(context, message, _SnackType.info);
  }

  static void _show(
    BuildContext context,
    String message,
    _SnackType type, {
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    late final IconData icon;
    late final Color color;
    switch (type) {
      case _SnackType.success:
        icon = Icons.check_circle_rounded;
        color = const Color(0xFF22C55E);
        break;
      case _SnackType.error:
        icon = Icons.error_rounded;
        color = const Color(0xFFEF4444);
        break;
      case _SnackType.info:
        icon = Icons.info_rounded;
        color = const Color(0xFF3B82F6);
        break;
    }

    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.white,
        elevation: 4,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
        content: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Color(0xFF0F172A), fontSize: 13.5, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        action: actionLabel != null
            ? SnackBarAction(label: actionLabel, textColor: color, onPressed: onAction ?? () {})
            : null,
      ),
    );
  }
}
