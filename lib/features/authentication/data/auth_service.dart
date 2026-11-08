import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

/// Thin wrapper around FirebaseAuth. Safe to construct when Firebase is not configured.
class AuthService {
  bool get available => Firebase.apps.isNotEmpty;
  FirebaseAuth get _auth => FirebaseAuth.instance;

  User? get currentUser => available ? _auth.currentUser : null;
  Stream<User?> get changes => available ? _auth.authStateChanges() : const Stream.empty();

  Future<User?> register(String name, String email, String password) async {
    final c = await _auth.createUserWithEmailAndPassword(email: email.trim(), password: password);
    await c.user?.updateDisplayName(name.trim());
    return c.user;
  }

  Future<User?> login(String email, String password) async =>
      (await _auth.signInWithEmailAndPassword(email: email.trim(), password: password)).user;

  Future<void> sendReset(String email) => _auth.sendPasswordResetEmail(email: email.trim());
  Future<void> logout() => _auth.signOut();
}
