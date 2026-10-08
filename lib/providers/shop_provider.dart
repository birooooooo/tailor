import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/shop_profile.dart';

/// The shop's profile (name, owner, contact, location, logo, staff,
/// services, measurement fields). Saved on the device; syncs to Firestore
/// later the same way orders do.
class ShopProvider extends ChangeNotifier {
  static const String _key = 'shop_profile_v1';

  ShopProfile _profile = ShopProfile.empty;
  ShopProfile get profile => _profile;

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
      ),
    );
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
