import 'package:flutter/material.dart';
import '../../generated/l10n/app_localizations.dart';

extension AppLocalizationsExtension on BuildContext {
  /// Retorna o AppLocalizations garantindo que nunca seja null.
  /// Se por algum motivo for null, retorna o localizations em inglês como fallback.
  AppLocalizations get l10n {
    final localizations = AppLocalizations.of(this);
    if (localizations == null) {
      // Fallback para inglês se não encontrar localização
      return lookupAppLocalizations(const Locale('en'));
    }
    return localizations;
  }
}
