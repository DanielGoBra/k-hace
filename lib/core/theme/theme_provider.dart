import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppThemePreference { auto, light, dark }

const _prefKey = 'theme_preference';

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  Timer? _timer;
  AppThemePreference _preference = AppThemePreference.auto;

  ThemeModeNotifier() : super(ThemeMode.dark) {
    _loadPreference();
  }

  AppThemePreference get preference => _preference;

  Future<void> _loadPreference() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_prefKey);
    if (saved != null) {
      _preference = AppThemePreference.values.firstWhere(
        (e) => e.name == saved,
        orElse: () => AppThemePreference.auto,
      );
    }
    _applyPreference();
    _startAutoTimer();
  }

  void setPreference(AppThemePreference pref) {
    _preference = pref;
    _applyPreference();
    SharedPreferences.getInstance().then((p) => p.setString(_prefKey, pref.name));
  }

  void _applyPreference() {
    switch (_preference) {
      case AppThemePreference.light:
        state = ThemeMode.light;
      case AppThemePreference.dark:
        state = ThemeMode.dark;
      case AppThemePreference.auto:
        state = _themeForCurrentHour();
    }
  }

  ThemeMode _themeForCurrentHour() {
    final hour = DateTime.now().hour;
    return (hour >= 6 && hour < 18) ? ThemeMode.light : ThemeMode.dark;
  }

  void _startAutoTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 60), (_) {
      if (_preference == AppThemePreference.auto) {
        final newMode = _themeForCurrentHour();
        if (state != newMode) state = newMode;
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final themeModeProvider =
    StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  final notifier = ThemeModeNotifier();
  ref.onDispose(() => notifier.dispose());
  return notifier;
});
