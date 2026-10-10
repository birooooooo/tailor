import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/shop_profile.dart';
import '../core/constants/app_constants.dart';

/// The shop's profile (name, owner, contact, location, logo, staff,
/// services, measurement fields). Saved on the device; syncs to Firestore
/// later the same way orders do.
class ShopProvider extends ChangeNotifier {
  static const String _key = 'shop_profile_v1';

  ShopProfile _profile = ShopProfile.empty;
  ShopProfile get profile => _profile;

  /// The shop's styles, or the built-in defaults when none were customised.
  List<String> get styles =>
      _profile.styles.isEmpty ? kDefaultStyles : _profile.styles;

  void addStyle(String style) {
    final name = style.trim();
    if (name.isEmpty || styles.contains(name)) return;
    update(_profile.copyWith(styles: [...styles, name]));
  }

  void removeStyle(String style) {
    update(
      _profile.copyWith(
        styles: styles.where((s) => s != style).toList(),
      ),
    );
  }

  bool _loading = true;
  bool get isLoading => _loading;

  ShopProvider() {
    load();
  }

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_key);
      if (raw != null) {
        _profile = ShopProfile.fromJson((jsonDecode(raw) as Map).cast());
      }
    } catch (e) {
      debugPrint('Shop profile load failed: $e');
    }
    _loading = false;
    notifyListeners();
  }

  void update(ShopProfile profile) {
    _profile = profile;
    _save();
    notifyListeners();
  }

  void setLocation(double? lat, double? lng) {
    update(
      ShopProfile(
        ownerName: _profile.ownerName,
        shopName: _profile.shopName,
        phone: _profile.phone,
        address: _profile.address,
        logoPath: _profile.logoPath,
        lat: lat,
        lng: lng,
        staff: _profile.staff,
        services: _profile.services,
        measurementFields: _profile.measurementFields,
        styles: _profile.styles,
        subscriptionPlan: _profile.subscriptionPlan,
        subscribedUntil: _profile.subscribedUntil,
      ),
    );
  }

  /// Activates a subscription plan until [until].
  void subscribe({required String plan, required DateTime until}) {
    update(_profile.copyWith(subscriptionPlan: plan, subscribedUntil: until));
  }

  /// Clears the profile (used when a brand-new account signs up).
  Future<void> clear() async {
    _profile = ShopProfile.empty;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_key);
    } catch (_) {}
  }

  Future<void> _save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key, jsonEncode(_profile.toJson()));
    } catch (e) {
      debugPrint('Shop profile save failed: $e');
    }
  }
}
