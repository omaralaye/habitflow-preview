import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettings {
  AppSettings._();

  static final ValueNotifier<ThemeMode> themeModeNotifier =
      ValueNotifier(ThemeMode.light);
  static bool hapticEnabled = true;
  static bool showStreak = true;
  static bool motivationalQuotes = true;
  static int resetHour = 0;
  static int resetMinute = 0;

  static Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final darkMode = prefs.getBool('dark_mode') ?? false;
    themeModeNotifier.value =
        darkMode ? ThemeMode.dark : ThemeMode.light;
    hapticEnabled = prefs.getBool('haptic_feedback') ?? true;
    showStreak = prefs.getBool('show_streak') ?? true;
    motivationalQuotes = prefs.getBool('motivational_quotes') ?? true;
    resetHour = prefs.getInt('reset_time_hour') ?? 0;
    resetMinute = prefs.getInt('reset_time_minute') ?? 0;
  }

  static Future<void> setDarkMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dark_mode', value);
    themeModeNotifier.value = value ? ThemeMode.dark : ThemeMode.light;
  }

  static Future<void> setHapticEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('haptic_feedback', value);
    hapticEnabled = value;
  }

  static Future<void> setShowStreak(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('show_streak', value);
    showStreak = value;
  }

  static Future<void> setMotivationalQuotes(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('motivational_quotes', value);
    motivationalQuotes = value;
  }

  static Future<void> setResetTime(int hour, int minute) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('reset_time_hour', hour);
    await prefs.setInt('reset_time_minute', minute);
    resetHour = hour;
    resetMinute = minute;
  }

  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}

class HapticUtil {
  HapticUtil._();

  static void lightImpact() {
    if (AppSettings.hapticEnabled) HapticFeedback.lightImpact();
  }

  static void mediumImpact() {
    if (AppSettings.hapticEnabled) HapticFeedback.mediumImpact();
  }

  static void heavyImpact() {
    if (AppSettings.hapticEnabled) HapticFeedback.heavyImpact();
  }

  static void selectionClick() {
    if (AppSettings.hapticEnabled) HapticFeedback.selectionClick();
  }
}


