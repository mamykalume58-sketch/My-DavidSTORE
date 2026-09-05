import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'device_service.dart';
import 'notification_service.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  final DeviceService _deviceService = DeviceService();
  final NotificationService _notificationService = NotificationService();

  bool _googleSignInInitialized = false;

  User? get currentUser => _firebaseAuth.currentUser;

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  Future<void> _ensureGoogleSignInInitialized() async {
    if (!_googleSignInInitialized) {
      await _googleSignIn.initialize(
        serverClientId:
            '27947559228-36j1vtt3pinki041dtpfar6oiptlfhlm.apps.googleusercontent.com',
      );
      _googleSignInInitialized = true;
    }
  }

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
      await _ensureGoogleSignInInitialized();

      final GoogleSignInAccount account = await _googleSignIn.authenticate();

      final GoogleSignInAuthentication googleAuth = account.authentication;

      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      final userCredential =
          await _firebaseAuth.signInWithCredential(credential);
      await _deviceService.registerCurrentDevice();
      await _notificationService.registerFcmToken();
      return userCredential;
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        return null; // l'utilisateur a annulé la connexion
      }
      throw 'Erreur de connexion Google : ${e.description ?? e.code}';
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
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
