import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Flutter does not ship Kurdish (ku) localizations.
///
/// These delegates mark `ku` as supported so the framework does not print
/// its "locale not supported" warning, while falling back to the built-in
/// English strings for the few framework widgets that need them (date
/// pickers, tooltips, ...). All of the app's own visible text comes from
/// `AppLocalizations`, which we translate into Kurdish ourselves.
class KuMaterialLocalizationsDelegate
    extends LocalizationsDelegate<MaterialLocalizations> {
  const KuMaterialLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<MaterialLocalizations> load(Locale locale) =>
      DefaultMaterialLocalizations.load(locale);

  @override
  bool shouldReload(LocalizationsDelegate<MaterialLocalizations> old) => false;
}

class KuCupertinoLocalizationsDelegate
    extends LocalizationsDelegate<CupertinoLocalizations> {
  const KuCupertinoLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<CupertinoLocalizations> load(Locale locale) =>
      DefaultCupertinoLocalizations.load(locale);

  @override
  bool shouldReload(LocalizationsDelegate<CupertinoLocalizations> old) => false;
}
