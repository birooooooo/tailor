import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/order_repository.dart';

/// The logged-in shop.
class AppUser {
  final String id;
  final String name;
  final String phone;
  final String email;
  final String shopName;

  const AppUser({
    required this.id,
    this.name = '',
    this.phone = '',
    this.email = '',
    this.shopName = '',
  });

  String get displayName => name.isNotEmpty
      ? name
      : shopName.isNotEmpty
      ? shopName
      : email.isNotEmpty
      ? email
      : 'میوان';

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'phone': phone,
    'email': email,
    'shopName': shopName,
  };

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
    id: json['id'] as String? ?? '',
    name: json['name'] as String? ?? '',
    phone: json['phone'] as String? ?? '',
    email: json['email'] as String? ?? '',
    shopName: json['shopName'] as String? ?? '',
  );
}

/// A login error with a machine code the UI turns into Kurdish text.
class AuthException implements Exception {
  final String code;
  AuthException(this.code);
  @override
  String toString() => code;
}

/// Shop authentication.
///
/// [FirebaseAuthService] is used once Firebase is configured; otherwise
/// [LocalAuthService] keeps accounts on the device (offline).
abstract class AuthService extends ChangeNotifier {
  AppUser? _user;
  AppUser? get user => _user;
  bool get isLoggedIn => _user != null;

  bool _loading = false;
  bool get isLoading => _loading;

  /// In offline mode a shop can continue without an account.
  bool get supportsGuest => false;

  Future<void> init();

  /// Log in with an email, a phone number, or a name + password.
  Future<void> signInByIdentifier(String identifier, String password);

  Future<void> register({
    required String name,
    required String phone,
    required String email,
    required String password,
  });

  /// Sends a reset link / resets the password for the given identifier.
  Future<void> resetPassword(String identifier);

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
  static const String _sessionKey = 'local_shop_user';
  static const String _accountsKey = 'local_accounts_v1';

  @override
  bool get supportsGuest => true;

  @override
  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_sessionKey);
      if (raw != null) {
        setUser(AppUser.fromJson((jsonDecode(raw) as Map).cast()));
      }
    } catch (e) {
      debugPrint('Local auth init failed: $e');
    }
  }

  Future<List<Map<String, dynamic>>> _accounts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_accountsKey);
      if (raw == null) return [];
      return (jsonDecode(raw) as List)
          .map((e) => (e as Map).cast<String, dynamic>())
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> _saveAccounts(List<Map<String, dynamic>> list) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accountsKey, jsonEncode(list));
  }

  @override
  Future<void> register({
    required String name,
    required String phone,
    required String email,
    required String password,
  }) async {
    setLoading(true);
    await Future<void>.delayed(const Duration(milliseconds: 300));
    final accounts = await _accounts();

    final exists = accounts.any(
      (a) =>
          (a['email'] as String).toLowerCase() == email.trim().toLowerCase() ||
          (a['phone'] as String) == phone.trim(),
    );
    if (exists) {
      setLoading(false);
      throw AuthException('email-already-in-use');
    }

    final account = {
      'id': 'shop-${DateTime.now().millisecondsSinceEpoch}',
      'name': name.trim(),
      'phone': phone.trim(),
      'email': email.trim(),
      'password': password,
    };
    accounts.add(account);
    await _saveAccounts(accounts);

    setUser(AppUser.fromJson(account));
    await _persistSession();
    setLoading(false);
  }

  @override
  Future<void> signInByIdentifier(String identifier, String password) async {
    setLoading(true);
    await Future<void>.delayed(const Duration(milliseconds: 300));
    final id = identifier.trim().toLowerCase();
    final accounts = await _accounts();

    final match = accounts.where(
      (a) =>
          (a['email'] as String).toLowerCase() == id ||
          (a['phone'] as String) == id ||
          (a['name'] as String).toLowerCase() == id,
    );
    if (match.isEmpty) {
      setLoading(false);
      throw AuthException('user-not-found');
    }
    final account = match.first;
    if (account['password'] != password) {
      setLoading(false);
      throw AuthException('wrong-password');
    }

    setUser(AppUser.fromJson(account));
    await _persistSession();
    setLoading(false);
  }

  @override
  Future<void> resetPassword(String identifier) async {
    setLoading(true);
    await Future<void>.delayed(const Duration(milliseconds: 300));
    final id = identifier.trim().toLowerCase();
    final accounts = await _accounts();
    final found = accounts.any(
      (a) =>
          (a['email'] as String).toLowerCase() == id ||
          (a['phone'] as String) == id ||
          (a['name'] as String).toLowerCase() == id,
    );
    setLoading(false);
    if (!found) throw AuthException('user-not-found');
    // Offline: there is no email to send — the caller shows a message.
  }

  @override
  Future<void> continueAsGuest() async {
    setUser(const AppUser(id: 'guest', name: ' میوان', shopName: 'دوکانی من'));
    await _persistSession();
  }

  @override
  Future<void> signOut() async {
    setUser(null);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_sessionKey);
    } catch (_) {}
  }

  Future<void> _persistSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final u = user;
      if (u != null) await prefs.setString(_sessionKey, jsonEncode(u.toJson()));
    } catch (_) {}
  }
}

// ----------------------------------------------------------------- Firebase

class FirebaseAuthService extends AuthService {
  final fb.FirebaseAuth _auth = fb.FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get _users =>
      FirebaseFirestore.instance.collection('users');

  @override
  Future<void> init() async {
    _auth.authStateChanges().listen((fb.User? u) {
      if (u == null) {
        setUser(null);
      } else {
        setUser(
          AppUser(id: u.uid, name: u.displayName ?? '', email: u.email ?? ''),
        );
      }
    });
  }

  /// Finds the email for a phone number or a name.
  Future<String?> _emailFor(String identifier) async {
    for (final field in ['phone', 'name']) {
      final snap = await _users
          .where(field, isEqualTo: identifier.trim())
          .limit(1)
          .get();
      if (snap.docs.isNotEmpty) {
        return snap.docs.first.data()['email'] as String?;
      }
    }
    return null;
  }

  @override
  Future<void> signInByIdentifier(String identifier, String password) async {
    setLoading(true);
    try {
      var email = identifier.trim();
      if (!email.contains('@')) {
        final found = await _emailFor(identifier);
        if (found == null) throw AuthException('user-not-found');
        email = found;
      }
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on AuthException {
      rethrow;
    } on fb.FirebaseAuthException catch (e) {
      throw AuthException(e.code);
    } finally {
      setLoading(false);
    }
  }

  @override
  Future<void> register({
    required String name,
    required String phone,
    required String email,
    required String password,
  }) async {
    setLoading(true);
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      await cred.user?.updateDisplayName(name.trim());
      await _users.doc(cred.user!.uid).set({
        'name': name.trim(),
        'phone': phone.trim(),
        'email': email.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });
      final u = _auth.currentUser;
      if (u != null) {
        setUser(
          AppUser(
            id: u.uid,
            name: name.trim(),
            phone: phone.trim(),
            email: email.trim(),
          ),
        );
      }
    } on fb.FirebaseAuthException catch (e) {
      throw AuthException(e.code);
    } finally {
      setLoading(false);
    }
  }

  @override
  Future<void> resetPassword(String identifier) async {
    setLoading(true);
    try {
      var email = identifier.trim();
      if (!email.contains('@')) {
        final found = await _emailFor(identifier);
        if (found == null) throw AuthException('user-not-found');
        email = found;
      }
      await _auth.sendPasswordResetEmail(email: email);
    } on AuthException {
      rethrow;
    } on fb.FirebaseAuthException catch (e) {
      throw AuthException(e.code);
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
