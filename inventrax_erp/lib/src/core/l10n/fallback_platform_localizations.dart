import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

/// Flutter Material/Cupertino only ship en, ar, etc. — not `so`.
/// Map custom app locales to the nearest supported platform locale.
Locale platformLocaleFor(Locale appLocale) {
  switch (appLocale.languageCode) {
    case 'ar':
      return const Locale('ar');
    default:
      return const Locale('en');
  }
}

/// MaterialLocalizations for all app locales (Somali → English widgets).
class FallbackMaterialLocalizationsDelegate
    extends LocalizationsDelegate<MaterialLocalizations> {
  const FallbackMaterialLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<MaterialLocalizations> load(Locale locale) =>
      GlobalMaterialLocalizations.delegate.load(platformLocaleFor(locale));

  @override
  bool shouldReload(FallbackMaterialLocalizationsDelegate old) => false;
}

class FallbackWidgetsLocalizationsDelegate
    extends LocalizationsDelegate<WidgetsLocalizations> {
  const FallbackWidgetsLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<WidgetsLocalizations> load(Locale locale) =>
      GlobalWidgetsLocalizations.delegate.load(platformLocaleFor(locale));

  @override
  bool shouldReload(FallbackWidgetsLocalizationsDelegate old) => false;
}

class FallbackCupertinoLocalizationsDelegate
    extends LocalizationsDelegate<CupertinoLocalizations> {
  const FallbackCupertinoLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<CupertinoLocalizations> load(Locale locale) =>
      GlobalCupertinoLocalizations.delegate.load(platformLocaleFor(locale));

  @override
  bool shouldReload(FallbackCupertinoLocalizationsDelegate old) => false;
}

/// Use in [MaterialApp.localizationsDelegates] instead of [GlobalMaterialLocalizations.delegate].
const inventraxLocalizationDelegates = <LocalizationsDelegate<dynamic>>[
  FallbackMaterialLocalizationsDelegate(),
  FallbackWidgetsLocalizationsDelegate(),
  FallbackCupertinoLocalizationsDelegate(),
];
