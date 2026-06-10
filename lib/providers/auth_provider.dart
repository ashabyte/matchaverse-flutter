import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  User? _user;
  bool _isLoading = false;
  String? _error;
  String? _authToken;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get authToken => _authToken;
  bool get isAuthenticated => _user != null && _authToken != null;

  AuthProvider() {
    _init();
  }

  void _init() {
    _auth.authStateChanges().listen((User? user) async {
      _user = user;
      if (user != null) {
        await _loadTokenFromPrefs();
      }
      notifyListeners();
    });
  }

  Future<void> _loadTokenFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _authToken = prefs.getString('auth_token');
  }

  Future<bool> signInWithGoogle() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      _user = userCredential.user;

      // Get Firebase ID token for backend auth
      final idToken = await _user!.getIdToken();
      _authToken = idToken;

      // Save token to SharedPreferences for session persistence
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', idToken!);
      await prefs.setString('user_uid', _user!.uid);
      await prefs.setString('user_name', _user!.displayName ?? '');
      await prefs.setString('user_email', _user!.email ?? '');
      await prefs.setString('user_photo', _user!.photoURL ?? '');

      // Register/sync user to MySQL backend
      await ApiService.syncUserToBackend(
        uid: _user!.uid,
        name: _user!.displayName ?? '',
        email: _user!.email ?? '',
        photoUrl: _user!.photoURL ?? '',
        token: idToken,
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Gagal masuk dengan Google: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _googleSignIn.signOut();
      await _auth.signOut();

      // Clear stored session
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      await prefs.remove('user_uid');
      await prefs.remove('user_name');
      await prefs.remove('user_email');
      await prefs.remove('user_photo');

      _user = null;
      _authToken = null;
    } catch (e) {
      _error = 'Gagal keluar: ${e.toString()}';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> checkSession() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token != null && _auth.currentUser != null) {
      _authToken = token;
      _user = _auth.currentUser;
      notifyListeners();
      return true;
    }
    return false;
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
