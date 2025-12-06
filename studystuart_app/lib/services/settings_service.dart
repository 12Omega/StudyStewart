import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService extends ChangeNotifier {
  static final SettingsService _instance = SettingsService._internal();
  factory SettingsService() => _instance;
  SettingsService._internal();

  ThemeMode _themeMode = ThemeMode.light;
  double _volume = 1.0;
  bool _notificationsEnabled = true;
  bool _soundEffectsEnabled = true;

  ThemeMode get themeMode => _themeMode;
  double get volume => _volume;
  bool get notificationsEnabled => _notificationsEnabled;
  bool get soundEffectsEnabled => _soundEffectsEnabled;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Load theme mode
    final themeModeString = prefs.getString('theme_mode') ?? 'light';
    _themeMode = themeModeString == 'dark' ? ThemeMode.dark : ThemeMode.light;
    
    // Load volume
    _volume = prefs.getDouble('volume') ?? 1.0;
    
    // Load notifications
    _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
    
    // Load sound effects
    _soundEffectsEnabled = prefs.getBool('sound_effects_enabled') ?? true;
    
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme_mode', mode == ThemeMode.dark ? 'dark' : 'light');
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    final newMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    await setThemeMode(newMode);
  }

  Future<void> setVolume(double value) async {
    _volume = value.clamp(0.0, 1.0);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('volume', _volume);
    notifyListeners();
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    _notificationsEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', enabled);
    notifyListeners();
  }

  Future<void> setSoundEffectsEnabled(bool enabled) async {
    _soundEffectsEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('sound_effects_enabled', enabled);
    notifyListeners();
  }

  Future<void> resetToDefaults() async {
    await setThemeMode(ThemeMode.light);
    await setVolume(1.0);
    await setNotificationsEnabled(true);
    await setSoundEffectsEnabled(true);
  }
}
