import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/database/database_helper.dart';
import '../core/notifications/notification_service.dart';

class SettingsProvider extends ChangeNotifier {
  static const _keyOnboardingDone = 'onboarding_done';
  static const _keyNotificationsEnabled = 'notifications_enabled';
  static const _keyThemeMode = 'theme_mode';

  bool _onboardingDone = false;
  bool _notificationsEnabled = false;
  ThemeMode _themeMode = ThemeMode.system;

  bool get onboardingDone => _onboardingDone;
  bool get notificationsEnabled => _notificationsEnabled;
  ThemeMode get themeMode => _themeMode;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _onboardingDone = prefs.getBool(_keyOnboardingDone) ?? false;
    _notificationsEnabled = prefs.getBool(_keyNotificationsEnabled) ?? false;
    final modeIndex = prefs.getInt(_keyThemeMode) ?? 0;
    _themeMode = ThemeMode.values[modeIndex];
    notifyListeners();
  }

  Future<void> completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyOnboardingDone, true);
    _onboardingDone = true;
    notifyListeners();
  }

  Future<void> setNotificationsEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyNotificationsEnabled, value);
    _notificationsEnabled = value;
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyThemeMode, mode.index);
    _themeMode = mode;
    notifyListeners();
  }

  Future<void> resetAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    await DatabaseHelper.instance.clearAllData();

    await NotificationService.instance.cancelAll();

    _onboardingDone = false;
    _notificationsEnabled = false;
    _themeMode = ThemeMode.system;
    notifyListeners();
  }
}
