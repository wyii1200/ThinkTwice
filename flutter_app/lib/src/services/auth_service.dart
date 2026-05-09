import 'package:firebase_auth/firebase_auth.dart';
import 'backend_api_service.dart';

class AuthService {
  static final _auth = FirebaseAuth.instance;

  /// Current signed-in user, or null
  static User? get currentUser => _auth.currentUser;

  /// Stream that emits whenever auth state changes
  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Sign in with email + password. Returns the [User] on success.
  static Future<User> signIn({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    return credential.user!;
  }

  /// Register a new account, set displayName, call backend setup.
  /// Returns the [User] on success.
  static Future<User> signUp({
    required String email,
    required String password,
    required String displayName,
    double dailyBudget = 50,
    double savingsGoal = 500,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    final user = credential.user!;

    // Set display name in Firebase Auth
    await user.updateDisplayName(displayName.trim().isEmpty ? email.split('@')[0] : displayName.trim());
    await user.reload();

    return _auth.currentUser!;
  }

  /// Sign out the current user.
  static Future<void> signOut() => _auth.signOut();

  /// Human-readable error message for FirebaseAuthException codes.
  static String friendlyError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No account found with that email.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password.';
      case 'email-already-in-use':
        return 'An account already exists with that email.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'too-many-requests':
        return 'Too many attempts. Try again later.';
      case 'network-request-failed':
        return 'Network error. Check your connection.';
      default:
        return e.message ?? 'Authentication failed. Try again.';
    }
  }
}
