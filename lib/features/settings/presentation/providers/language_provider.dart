import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _languageKey = 'app_language';

/// Language setting options
enum LanguageSetting {
  system, // Follow system language
  korean, // Force Korean
  english, // Force English
}

/// Provider for managing app language setting
final languageProvider =
    StateNotifierProvider<LanguageNotifier, Locale?>((ref) {
  return LanguageNotifier();
});

/// Provider for the current language setting (enum)
final languageSettingProvider =
    StateNotifierProvider<LanguageSettingNotifier, LanguageSetting>((ref) {
  return LanguageSettingNotifier(ref);
});

class LanguageNotifier extends StateNotifier<Locale?> {
  LanguageNotifier() : super(null) {
    _loadSavedLanguage();
  }

  Future<void> _loadSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLanguage = prefs.getString(_languageKey);

    if (savedLanguage == null || savedLanguage == 'system') {
      state = null; // Use system language
    } else if (savedLanguage == 'ko') {
      state = const Locale('ko');
    } else if (savedLanguage == 'en') {
      state = const Locale('en');
    }
  }

  Future<void> setLanguage(LanguageSetting setting) async {
    final prefs = await SharedPreferences.getInstance();

    switch (setting) {
      case LanguageSetting.system:
        await prefs.setString(_languageKey, 'system');
        state = null;
        break;
      case LanguageSetting.korean:
        await prefs.setString(_languageKey, 'ko');
        state = const Locale('ko');
        break;
      case LanguageSetting.english:
        await prefs.setString(_languageKey, 'en');
        state = const Locale('en');
        break;
    }
  }
}

class LanguageSettingNotifier extends StateNotifier<LanguageSetting> {
  final Ref _ref;

  LanguageSettingNotifier(this._ref) : super(LanguageSetting.system) {
    _loadSetting();
  }

  Future<void> _loadSetting() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLanguage = prefs.getString(_languageKey);

    if (savedLanguage == null || savedLanguage == 'system') {
      state = LanguageSetting.system;
    } else if (savedLanguage == 'ko') {
      state = LanguageSetting.korean;
    } else if (savedLanguage == 'en') {
      state = LanguageSetting.english;
    }
  }

  Future<void> setSetting(LanguageSetting setting) async {
    state = setting;
    await _ref.read(languageProvider.notifier).setLanguage(setting);
  }
}
