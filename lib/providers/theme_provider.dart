import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Remembers whether the user chose the dark theme.
class ThemeProvider extends ChangeNotifier {
  static const String _key = 'dark_mode';

  bool _dark = false;
  bool get isDark => _dark;

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _dark = prefs.getBool(_key) ?? false;
      notifyListeners();
    } catch (_) {
      // Ignore — fall back to light.
    }
  }

  Future<void> toggle() => setDark(!_dark);

  Future<void> setDark(bool value) async {
    if (_dark == value) return;
    _dark = value;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_key, value);
    } catch (_) {
      // Ignore persistence errors.
    }
  }
}
