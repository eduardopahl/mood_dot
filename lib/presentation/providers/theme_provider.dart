import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Provider para gerenciar o estado do modo dark
final themeNotifierProvider = StateNotifierProvider<ThemeNotifier, bool>((ref) {
  return ThemeNotifier();
});

class ThemeNotifier extends StateNotifier<bool> {
  static const String _key = 'isDarkMode';

  ThemeNotifier() : super(false) {
    _loadTheme();
  }

  // Carrega o tema salvo
  Future<void> _loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      state = prefs.getBool(_key) ?? false;
    } catch (e) {
      // Se há erro ao carregar, mantem o tema padrão (light)
      state = false;
    }
  }

  // Alterna entre light e dark mode
  Future<void> toggleTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      state = !state;
      await prefs.setBool(_key, state);
    } catch (e) {
      // Se há erro ao salvar, apenas alterna o estado
      state = !state;
    }
  }

  // Define um tema específico
  Future<void> setTheme(bool isDark) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      state = isDark;
      await prefs.setBool(_key, isDark);
    } catch (e) {
      // Se há erro ao salvar, apenas define o estado
      state = isDark;
    }
  }

  // Getters para facilitar o uso
  bool get isDarkMode => state;
  bool get isLightMode => !state;
}
