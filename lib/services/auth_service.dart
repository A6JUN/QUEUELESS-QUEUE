import 'package:firebase_auth/firebase_auth.dart';

/// Service class for handling Firebase Authentication
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Get current user
  User? get currentUser => _auth.currentUser;

  /// Get auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Check if user is currently logged in
  bool get isLoggedIn => _auth.currentUser != null;

  /// Get current user's ID token
  /// This token can be used for API authentication
  Future<String?> getIdToken({bool forceRefresh = false}) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        return await user.getIdToken(forceRefresh);
      }
      return null;
    } catch (e) {
      throw 'Failed to get authentication token.';
    }
  }

  /// Get current user's email
  String? get userEmail => _auth.currentUser?.email;

  /// Get current user's UID
  String? get userId => _auth.currentUser?.uid;

  /// Sign up with email and password
  /// 
  /// Returns the created user on success
  /// Throws FirebaseAuthException on error
  Future<User?> signUp({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'An unexpected error occurred. Please try again.';
    }
  }

  /// Sign in with email and password
  /// 
  /// Returns the signed-in user on success
  /// Throws FirebaseAuthException on error
  Future<User?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'An unexpected error occurred. Please try again.';
    }
  }

  /// Sign out current user
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw 'Failed to sign out. Please try again.';
    }
  }

  /// Reload current user data
  Future<void> reloadUser() async {
    try {
      await _auth.currentUser?.reload();
    } catch (e) {
      throw 'Failed to reload user data.';
    }
  }

  /// Handle Firebase Auth exceptions and return user-friendly messages
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'email-already-in-use':
        return 'An account already exists for this email.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'operation-not-allowed':
        return 'Email/password accounts are not enabled.';
      case 'invalid-credential':
        return 'Invalid email or password.';
      default:
        return e.message ?? 'Authentication failed. Please try again.';
    }
  }
}
