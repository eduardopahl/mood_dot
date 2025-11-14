import 'package:flutter/material.dart';
import 'package:mooddot/core/app_logger.dart';
import 'admob_service.dart';

/// Serviço que gerencia quando mostrar anúncios intersticiais
/// baseado em eventos e ações do usuário
class AdEventService {
  static AdEventService? _instance;
  static AdEventService get instance => _instance ??= AdEventService._();

  AdEventService._();

  // Contadores de ações
  int _moodEntriesCount = 0;
  int _statisticsViewCount = 0;
  int _settingsOpenCount = 0;

  // Configurações de triggers
  static const int _moodsUntilAd = 5; // A cada 5 registros de humor
  static const int _statisticsUntilAd =
      3; // A cada 3 visualizações de estatísticas
  static const int _settingsUntilAd = 2; // A cada 2 aberturas de configurações

  /// Registra entrada de humor - mostra ad a cada X entradas
  Future<void> onMoodEntry(BuildContext context) async {
    _moodEntriesCount++;
    AppLogger.d('📊 Humor registrado #$_moodEntriesCount');

    if (_moodEntriesCount >= _moodsUntilAd) {
      _moodEntriesCount = 0; // Reset contador
      await _showInterstitialWithMessage(
        context,
        '🎉 Ótimo! Você está mantendo seu registro de humor em dia!',
      );
    }
  }

  /// Registra visualização de estatísticas
  Future<void> onStatisticsView(BuildContext context) async {
    _statisticsViewCount++;
    AppLogger.d('📈 Estatísticas visualizada #$_statisticsViewCount');

    if (_statisticsViewCount >= _statisticsUntilAd) {
      _statisticsViewCount = 0;
      await _showInterstitialWithMessage(
        context,
        '📊 Continue acompanhando sua evolução emocional!',
      );
    }
  }

  /// Registra abertura de configurações
  Future<void> onSettingsOpen(BuildContext context) async {
    _settingsOpenCount++;
    AppLogger.d('⚙️ Configurações aberta #$_settingsOpenCount');

    if (_settingsOpenCount >= _settingsUntilAd) {
      _settingsOpenCount = 0;
      await _showInterstitialWithMessage(
        context,
        '⚙️ Personalize sua experiência no MoodDot!',
      );
    }
  }

  /// Mostra intersticial após completar uma sequência de humores
  Future<void> onStreakMilestone(BuildContext context, int days) async {
    if (days % 7 == 0) {
      // A cada 7 dias de sequência
      await _showInterstitialWithMessage(
        context,
        '🔥 Incrível! Você mantém sua sequência há $days dias!',
      );
    }
  }

  /// Mostra intersticial ao visualizar gráficos
  Future<void> onChartInteraction(BuildContext context) async {
    // Chance de 30% de mostrar ad ao interagir com gráficos
    if (DateTime.now().millisecond % 10 < 3) {
      await _showInterstitialWithMessage(
        context,
        '📈 Seus dados emocionais contam uma história interessante!',
      );
    }
  }

  /// Mostra intersticial quando usuário explora muito o app
  Future<void> onExtendedUsage(BuildContext context) async {
    await _showInterstitialWithMessage(
      context,
      '💡 Que tal remover os anúncios com o MoodDot Premium?',
    );
  }

  /// Método interno para mostrar intersticial com contexto
  Future<void> _showInterstitialWithMessage(
    BuildContext context,
    String message,
  ) async {
    final admobService = AdMobService.instance;

    if (!admobService.canShowInterstitial()) {
      AppLogger.d('⏰ Intersticial em cooldown, pulando...');
      return;
    }

    AppLogger.d('🎬 Exibindo intersticial: $message');

    // Mostra o intersticial sem snackbar irritante
    await admobService.showInterstitialAd();
  }

  /// Reseta todos os contadores (útil para testes)
  void resetCounters() {
    _moodEntriesCount = 0;
    _statisticsViewCount = 0;
    _settingsOpenCount = 0;
    AppLogger.d('🔄 Contadores de ads resetados');
  }

  /// Obtém estatísticas dos contadores (para debug)
  Map<String, int> getCounters() {
    return {
      'moodEntries': _moodEntriesCount,
      'statisticsViews': _statisticsViewCount,
      'settingsOpens': _settingsOpenCount,
    };
  }
}
