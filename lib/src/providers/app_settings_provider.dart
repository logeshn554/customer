import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:allgo_mobile_shared/allgo_mobile_shared.dart';

const String _kLocaleKey = 'allgo_customer_locale';
const String _kThemeModeKey = 'allgo_customer_theme_mode';

final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

class LocaleNotifier extends StateNotifier<Locale> {
  final FlutterSecureStorage _storage;

  LocaleNotifier(this._storage) : super(const Locale('en')) {
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    try {
      final code = await _storage.read(key: _kLocaleKey);
      if (code != null && (code == 'en' || code == 'hi' || code == 'ta')) {
        state = Locale(code);
      }
    } catch (_) {}
  }

  Future<void> setLocale(String languageCode) async {
    if (languageCode != 'en' && languageCode != 'hi' && languageCode != 'ta') {
      return;
    }
    if (state.languageCode == languageCode) return;
    state = Locale(languageCode);
    try {
      await _storage.write(key: _kLocaleKey, value: languageCode);
    } catch (_) {}
  }
}

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  final storage = ref.watch(secureStorageProvider);
  final notifier = LocaleNotifier(storage);

  ref.listen<User?>(currentUserProvider, (prev, next) {
    final lang = next?.defaultLanguage;
    if (lang != null && lang.isNotEmpty) {
      notifier.setLocale(lang);
    }
  });

  return notifier;
});

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  final FlutterSecureStorage _storage;

  ThemeModeNotifier(this._storage) : super(ThemeMode.system) {
    _loadThemeMode();
  }

  Future<void> _loadThemeMode() async {
    try {
      final modeStr = await _storage.read(key: _kThemeModeKey);
      if (modeStr == 'light') {
        state = ThemeMode.light;
      } else if (modeStr == 'dark') {
        state = ThemeMode.dark;
      } else {
        state = ThemeMode.system;
      }
    } catch (_) {}
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    try {
      final val = mode == ThemeMode.light
          ? 'light'
          : mode == ThemeMode.dark
              ? 'dark'
              : 'system';
      await _storage.write(key: _kThemeModeKey, value: val);
    } catch (_) {}
  }
}

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  final storage = ref.watch(secureStorageProvider);
  return ThemeModeNotifier(storage);
});
