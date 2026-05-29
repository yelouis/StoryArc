import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

class AuthService {
  final FirebaseAuth? _auth;

  AuthService({FirebaseAuth? auth}) : _auth = auth;

  FirebaseAuth get auth => _auth ?? FirebaseAuth.instance;

  Stream<User?> get authStateChanges => auth.authStateChanges();

  User? get currentUser => auth.currentUser;

  Future<UserCredential> signInAnonymously() async {
    return await auth.signInAnonymously();
  }

  Future<void> signOut() async {
    await auth.signOut();
  }
}
