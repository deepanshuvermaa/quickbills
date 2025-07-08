import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

// Theme mode provider
final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier();
});

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  static const String _themeBoxName = 'theme_settings';
  static const String _themeModeKey = 'theme_mode';
  
  late Box _box;
  
  ThemeModeNotifier() : super(ThemeMode.light) {
    _loadThemeMode();
  }
  
  Future<void> _loadThemeMode() async {
    _box = await Hive.openBox(_themeBoxName);
    final savedThemeMode = _box.get(_themeModeKey, defaultValue: 'light');
    
    switch (savedThemeMode) {
      case 'dark':
        state = ThemeMode.dark;
        break;
      case 'system':
        state = ThemeMode.system;
        break;
      default:
        state = ThemeMode.light;
    }
  }
  
  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    
    String modeString;
    switch (mode) {
      case ThemeMode.dark:
        modeString = 'dark';
        break;
      case ThemeMode.system:
        modeString = 'system';
        break;
      default:
        modeString = 'light';
    }
    
    await _box.put(_themeModeKey, modeString);
  }
  
  void toggleTheme() {
    if (state == ThemeMode.light) {
      setThemeMode(ThemeMode.dark);
    } else {
      setThemeMode(ThemeMode.light);
    }
  }
}