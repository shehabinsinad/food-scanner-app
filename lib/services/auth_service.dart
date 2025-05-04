import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Listen to authentication state changes.
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Signs in with the provided [email] and [password].
  /// Returns null on success, or an error message on failure.
  Future<String?> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null; // Login successful.
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return 'No account found for that email. Please check your email or sign up.';
      } else if (e.code == 'wrong-password') {
        return 'Incorrect password. Please try again.';
      } else {
        return e.message ?? 'An error occurred during login. Please try again later.';
      }
    } catch (e) {
      return 'An unknown error occurred. Please try again later.';
    }
  }

  /// Signs up with the provided [email] and [password].
  /// Returns null on success, or an error message on failure.
  Future<String?> signUpWithEmail(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(email: email, password: password);
      return null; // Sign up successful.
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        return 'This email is already in use. Please use a different email or log in instead.';
      } else {
        return e.message ?? 'An error occurred during sign up. Please try again later.';
      }
    } catch (e) {
      return 'An unknown error occurred. Please try again later.';
    }
  }

  /// Signs out the current user.
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Returns the current user.
  User? getCurrentUser() {
    return _auth.currentUser;
  }
}
