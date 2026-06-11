import 'package:flutter/material.dart';

/// Supported ERP locales (BCP 47).
enum AppLocale {
  english('en', 'English', false),
  somali('so', 'Somali', false),
  arabic('ar', 'Arabic', true);

  const AppLocale(this.code, this.aiLanguageName, this.isRtl);

  final String code;
  final String aiLanguageName;
  final bool isRtl;

  Locale get flutterLocale => Locale(code);

  static AppLocale fromCode(String? code) {
    return switch (code?.toLowerCase()) {
      'so' || 'som' || 'somali' => AppLocale.somali,
      'ar' || 'ara' || 'arabic' => AppLocale.arabic,
      _ => AppLocale.english,
    };
  }

  static const supported = [AppLocale.english, AppLocale.somali, AppLocale.arabic];
}
