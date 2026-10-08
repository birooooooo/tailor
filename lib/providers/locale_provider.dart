import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The app language: Kurdish (default), Arabic or English.
class LocaleProvider extends ChangeNotifier {
  static const String _key = 'app_locale';

  Locale _locale = const Locale('ku');
  Locale get locale => _locale;

  bool get isRtl =>
      _locale.languageCode == 'ku' || _locale.languageCode == 'ar';

  LocaleProvider() {
    load();
  }

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final code = prefs.getString(_key);
      if (code != null) {
        _locale = Locale(code);
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<void> setLocale(String code) async {
    if (_locale.languageCode == code) return;
    _locale = Locale(code);
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key, code);
    } catch (_) {}
  }
}
