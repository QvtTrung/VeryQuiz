// lib/services/theme_service.dart
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService {
  static const String _themeKey = 'is_dark_mode';

  // Lưu trạng thái dark mode
  Future<void> setDarkMode(bool isDarkMode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, isDarkMode);
    print('Saved dark mode: $isDarkMode'); // Log để kiểm tra
  }

  // Đọc trạng thái dark mode
  Future<bool> isDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    bool value = prefs.getBool(_themeKey) ?? false;
    print('Loaded dark mode: $value'); // Log để kiểm tra
    return value;
  }
}
