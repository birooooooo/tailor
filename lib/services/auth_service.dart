import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/order_repository.dart';

/// The logged-in shop.
class AppUser {
  final String id;
  final String email;
  final String shopName;

  const AppUser({required this.id, required this.email, this.shopName = ''});

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'shopName': shopName,
  };

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
    id: json['id'] as String? ?? '',
    email: json['email'] as String? ?? '',
    shopName: json['shopName'] as String? ?? '',
  );
}

/// Shop authentication.
///
/// [FirebaseAuthService] is used once the app is configured for Firebase;
/// otherwise [LocalAuthService] keeps a simple account on the device so the
/// shop can still log in (offline).
abstract class AuthService extends ChangeNotifier {
  AppUser? _user;
  AppUser? get user => _user;
  bool get isLoggedIn => _user != null;

  bool _loading = false;
  bool get isLoading => _loading;

  /// In offline mode a shop can continue without an account.
  bool get supportsGuest => false;

  Future<void> init();
  Future<void> signIn(String email, String password);
  Future<void> register(String email, String password, String shopName);
  Future<void> signOut();
  Future<void> continueAsGuest();

  @protected
  void setUser(AppUser? user) {
    _user = user;
    notifyListeners();
  }

  @protected
  void setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }
}

// ------------------------------------------------------------------ offline

class LocalAuthService extends AuthService {
  static const String _key = 'local_shop_user';

  @override
  bool get supportsGuest => true;

  @override
  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_key);
      if (raw != null) {
        setUser(AppUser.fromJson((jsonDecode(raw) as Map).cast()));
      }
    } catch (e) {
      debugPrint('Local auth init failed: $e');
    }
  }

  @override
  Future<void> signIn(String email, String password) async {
    setLoading(true);
    await Future<void>.delayed(const Duration(milliseconds: 300));
    setUser(
      AppUser(id: 'shop-${email.trim().hashCode.abs()}', email: email.trim()),
    );
    await _persist();
    setLoading(false);
  }

  @override
  Future<void> register(String email, String password, String shopName) async {
    setLoading(true);
    await Future<void>.delayed(const Duration(milliseconds: 300));
    setUser(
      AppUser(
        id: 'shop-${email.trim().hashCode.abs()}',
        email: email.trim(),
        shopName: shopName.trim(),
      ),
    );
    await _persist();
    setLoading(false);
  }

  @override
  Future<void> continueAsGuest() async {
    setUser(const AppUser(id: 'guest', email: '', shopName: 'دوکانی من'));
    await _persist();
  }

  @override
  Future<void> signOut() async {
    setUser(null);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_key);
    } catch (_) {}
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final u = user;
      if (u != null) await prefs.setString(_key, jsonEncode(u.toJson()));
    } catch (_) {}
  }
}

// ----------------------------------------------------------------- Firebase

class FirebaseAuthService extends AuthService {
  final fb.FirebaseAuth _auth = fb.FirebaseAuth.instance;

  @override
  Future<void> init() async {
    _auth.authStateChanges().listen((fb.User? u) {
      setUser(u == null ? null : AppUser(id: u.uid, email: u.email ?? ''));
    });
  }

  @override
  Future<void> signIn(String email, String password) async {
    setLoading(true);
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } finally {
      setLoading(false);
    }
  }

  @override
  Future<void> register(String email, String password, String shopName) async {
    setLoading(true);
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      await cred.user?.updateDisplayName(shopName.trim());
      await cred.user?.reload();
      final u = _auth.currentUser;
      if (u != null) {
        setUser(AppUser(id: u.uid, email: u.email ?? '', shopName: shopName));
      }
    } finally {
      setLoading(false);
    }
  }

  @override
  Future<void> signOut() => _auth.signOut();

  @override
  Future<void> continueAsGuest() async {
    // Not available when Firebase is configured.
  }
}

class AuthServiceFactory {
  AuthServiceFactory._();

  static AuthService create() {
    if (FirebaseServiceAvailable.value) return FirebaseAuthService();
    return LocalAuthService();
  }
}
