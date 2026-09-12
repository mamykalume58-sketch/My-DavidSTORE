import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'device_service.dart';
import 'notification_service.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId:
        '27947559228-36j1vtt3pinki041dtpfar6oiptlfhlm.apps.googleusercontent.com',
  );
  final DeviceService _deviceService = DeviceService();
  final NotificationService _notificationService = NotificationService();

  User? get currentUser => _firebaseAuth.currentUser;

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  // Inscription avec email et mot de passe
  Future<UserCredential> registerWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      try {
        await http.post(
          Uri.parse(
              'https://davidstore-payment.vercel.app/api/auth/send-verification'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'email': email}),
        );
      } catch (_) {
        // Ne bloque jamais l'inscription si l'envoi de verification echoue
      }
      await _deviceService.registerCurrentDevice();
      await _notificationService.registerFcmToken();
      try {
        await http.post(
          Uri.parse('https://davidstore-payment.vercel.app/api/auth/welcome'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'email': email}),
        );
      } catch (_) {
        // Ne bloque jamais l'inscription si l'email de bienvenue echoue
      }
      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Connexion avec email et mot de passe
  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      await _deviceService.registerCurrentDevice();
      await _notificationService.registerFcmToken();
      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Connexion avec Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? account = await _googleSignIn.signIn();

      if (account == null) {
        return null; // l'utilisateur a annule la connexion
      }

      final GoogleSignInAuthentication googleAuth =
          await account.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential =
          await _firebaseAuth.signInWithCredential(credential);
      await _deviceService.registerCurrentDevice();
      await _notificationService.registerFcmToken();
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Erreur de connexion Google : $e';
    }
  }

  // Mot de passe oublié
  Future<void> resetPassword(String email) async {
    try {
      final response = await http.post(
        Uri.parse(
            'https://davidstore-payment.vercel.app/api/auth/forgot-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );
      if (response.statusCode != 200) {
        throw 'Impossible d\'envoyer l\'email de réinitialisation. Réessayez plus tard.';
      }
    } on http.ClientException {
      throw 'Vérifiez votre connexion internet et réessayez.';
    }
  }

  // Demande d'un code PIN de reinitialisation (nouveau flux)
  Future<String> requestResetPin(String email) async {
    try {
      final response = await http.post(
        Uri.parse(
            'https://davidstore-payment.vercel.app/api/auth/forgot-password-pin'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode != 200) {
        throw data['error'] ?? 'Impossible d\'envoyer le code. Réessayez plus tard.';
      }
      return data['requestId'] as String;
    } on http.ClientException {
      throw 'Vérifiez votre connexion internet et réessayez.';
    }
  }

  // Verification du PIN recu par email
  Future<String> verifyResetPin(String requestId, String pin) async {
    try {
      final response = await http.post(
        Uri.parse(
            'https://davidstore-payment.vercel.app/api/auth/verify-reset-pin'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'requestId': requestId, 'pin': pin}),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode != 200) {
        throw data['error'] ?? 'Code incorrect.';
      }
      return data['resetToken'] as String;
    } on http.ClientException {
      throw 'Vérifiez votre connexion internet et réessayez.';
    }
  }

  // Application du nouveau mot de passe apres verification du PIN
  Future<void> resetPasswordWithPin(
      String requestId, String resetToken, String newPassword) async {
    try {
      final response = await http.post(
        Uri.parse(
            'https://davidstore-payment.vercel.app/api/auth/reset-password-pin'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'requestId': requestId,
          'resetToken': resetToken,
          'newPassword': newPassword,
        }),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode != 200) {
        throw data['error'] ?? 'Impossible de réinitialiser le mot de passe.';
      }
    } on http.ClientException {
      throw 'Vérifiez votre connexion internet et réessayez.';
    }
  }

  // Déconnexion
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
    await _googleSignIn.signOut();
  }

  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'Aucun compte trouvé avec cet email.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Mot de passe incorrect.';
      case 'email-already-in-use':
        return 'Cet email est déjà utilisé.';
      case 'weak-password':
        return 'Le mot de passe est trop faible.';
      case 'invalid-email':
        return 'Adresse email invalide.';
      default:
        return 'Erreur : ${e.message}';
    }
  }
}
