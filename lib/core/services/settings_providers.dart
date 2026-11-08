import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Overridden in main() with the real SharedPreferences instance.
final sharedPrefsProvider = Provider<SharedPreferences>((ref) => throw UnimplementedError());

class ThemeModeNotifier extends Notifier<ThemeMode> {
  static const _key = 'theme_mode';
  @override
  ThemeMode build() =>
      ref.read(sharedPrefsProvider).getString(_key) == 'dark' ? ThemeMode.dark : ThemeMode.light;

  Future<void> setDark(bool dark) async {
    state = dark ? ThemeMode.dark : ThemeMode.light;
    await ref.read(sharedPrefsProvider).setString(_key, dark ? 'dark' : 'light');
  }
}

class LocaleNotifier extends Notifier<Locale> {
  static const _key = 'language_code';
  @override
  Locale build() => Locale(ref.read(sharedPrefsProvider).getString(_key) ?? 'en');

  Future<void> setLanguage(String code) async {
    state = Locale(code);
    await ref.read(sharedPrefsProvider).setString(_key, code);
  }
}

final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(ThemeModeNotifier.new);
final localeProvider = NotifierProvider<LocaleNotifier, Locale>(LocaleNotifier.new);

/// Whether the first-run onboarding was completed.
class OnboardingNotifier extends Notifier<bool> {
  static const _key = 'onboarding_done';
  @override
  bool build() => ref.read(sharedPrefsProvider).getBool(_key) ?? false;

  Future<void> complete() async {
    state = true;
    await ref.read(sharedPrefsProvider).setBool(_key, true);
  }
}

final onboardingDoneProvider = NotifierProvider<OnboardingNotifier, bool>(OnboardingNotifier.new);
