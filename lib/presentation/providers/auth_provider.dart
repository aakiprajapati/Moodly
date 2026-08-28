import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Simple auth provider that signs in via Google/Firebase and
/// stores a per-user onboarding flag in SharedPreferences.
///
/// Written for google_sign_in ^7.0.0+, which replaced the old
/// GoogleSignIn() + signIn() pattern with a singleton instance
/// that must be initialized before use, and authenticate() which
/// throws GoogleSignInException instead of returning null.
class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  bool _googleSignInInitialized = false;
  Future<void>? _initFuture;

  User? get user => _auth.currentUser;
  bool get isSignedIn => user != null;

  /// Ensures GoogleSignIn.initialize() has been called exactly once.
  /// Safe to call repeatedly; concurrent callers share the same future.
  Future<void> _ensureGoogleSignInInitialized() {
    if (_googleSignInInitialized) return Future.value();
    return _initFuture ??= _googleSignIn
        .initialize(serverClientId: '327425222350-f9h94g1bjhif07qi3cg4hj81qj2n1rb8.apps.googleusercontent.com')
        .then((_) {
      _googleSignInInitialized = true;
    });
  }

  Future<UserCredential?> signInWithGoogle() async {
    try {
      await _ensureGoogleSignInInitialized();

      // authenticate() throws GoogleSignInException (code: canceled)
      // instead of returning null when the user cancels.
      final GoogleSignInAccount googleUser =
      await _googleSignIn.authenticate();

      // ID token comes synchronously off the account in v7.
      final idToken = googleUser.authentication.idToken;

      // Access token now comes from the authorization client, scoped
      // per-request rather than baked into sign-in.
      final authorization = await _googleSignIn.authorizationClient
          .authorizationForScopes(['email']);

      final credential = GoogleAuthProvider.credential(
        accessToken: authorization?.accessToken,
        idToken: idToken,
      );

      final result = await _auth.signInWithCredential(credential);
      notifyListeners();
      return result;
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        // User cancelled the sign-in flow — not an error.
        return null;
      }
      if (kDebugMode) print('Google sign in failed: ${e.code} ${e.description}');
      rethrow;
    } catch (e) {
      if (kDebugMode) print('Google sign in failed: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
    notifyListeners();
  }

  Future<bool> isOnboardedForCurrentUser() async {
    final u = user;
    if (u == null) return false;
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('onboarded_${u.uid}') ?? false;
  }

  Future<void> markOnboardedForCurrentUser() async {
    final u = user;
    if (u == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarded_${u.uid}', true);
  }
}