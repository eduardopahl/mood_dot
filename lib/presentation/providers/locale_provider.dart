import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _localeKey = 'app_locale';

/// Provider para gerenciar o idioma do app

class LocaleNotifier extends StateNotifier<Locale> {
  LocaleNotifier() : super(_getInitialLocale()) {
    _loadLocale();
  }

  static Locale _getInitialLocale() {
    final systemLocale = WidgetsBinding.instance.platformDispatcher.locale;
    if (systemLocale.languageCode == 'pt') {
      return const Locale('pt', 'BR');
    }
    return const Locale('en', 'US');
  }

  Future<void> _loadLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final localeString = prefs.getString(_localeKey);

      if (localeString != null) {
        final parts = localeString.split('_');
        if (parts.length >= 2) {
          state = Locale(parts[0], parts[1]);
        } else {
          state = Locale(parts[0]);
        }
      }
      // Se não houver escolha do usuário, mantém o detectado do sistema
    } catch (e) {
      debugPrint('Erro ao carregar locale: $e');
      // Mantém o padrão detectado
    }
  }

  Future<void> setLocale(Locale locale) async {
    state = locale;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _localeKey,
        '${locale.languageCode}_${locale.countryCode ?? ''}',
      );
    } catch (e) {
      debugPrint('Erro ao salvar locale: $e');
    }
  }

  Future<void> toggleLanguage() async {
    final newLocale =
        state.languageCode == 'pt'
            ? const Locale('en', 'US')
            : const Locale('pt', 'BR');
    await setLocale(newLocale);
  }
}

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier();
});
