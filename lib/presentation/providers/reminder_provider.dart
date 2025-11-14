import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/app_logger.dart';
import '../../core/services/notification_service.dart';
import 'mood_providers.dart';

// Provider para o serviço de notificações
final notificationServiceProvider = Provider<NotificationService>((ref) {
  final repository = ref.watch(moodRepositoryProvider);
  return NotificationService.getInstance(repository);
});

// Provider para o estado dos lembretes
final reminderStateProvider =
    StateNotifierProvider<ReminderNotifier, ReminderState>((ref) {
      final notificationService = ref.watch(notificationServiceProvider);
      return ReminderNotifier(notificationService);
    });

class ReminderState {
  final bool isEnabled;
  final bool isLoading;
  final String? error;

  const ReminderState({
    required this.isEnabled,
    this.isLoading = false,
    this.error,
  });

  ReminderState copyWith({bool? isEnabled, bool? isLoading, String? error}) {
    return ReminderState(
      isEnabled: isEnabled ?? this.isEnabled,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  String statusText(String enabledText, String disabledText) =>
      isEnabled ? enabledText : disabledText;
}

class ReminderNotifier extends StateNotifier<ReminderState> {
  ReminderNotifier(this._notificationService)
    : super(const ReminderState(isEnabled: false)) {
    _loadState();
  }

  final NotificationService _notificationService;

  /// Carrega o estado atual das configurações
  Future<void> _loadState() async {
    AppLogger.d('🚀 ReminderNotifier: Iniciando carregamento do estado...');
    state = state.copyWith(isLoading: true);

    try {
      AppLogger.d('🔧 Inicializando serviço de notificações...');
      await _notificationService.initialize();
      AppLogger.d('✅ Serviço inicializado com sucesso');

      AppLogger.d('📊 Carregando status das notificações...');
      final status = await _notificationService.getReminderStatus();
      AppLogger.d('📊 Status carregado: $status');

      state = ReminderState(
        isEnabled: status['enabled'] ?? false,
        isLoading: false,
      );

      AppLogger.d('🎉 Estado carregado: enabled=${state.isEnabled}');
    } catch (e) {
      AppLogger.e('Erro ao carregar estado', e);
      state = state.copyWith(
        isLoading: false,
        error: 'Erro ao carregar configurações: $e',
      );
    }
  }

  /// Alterna o estado dos lembretes
  Future<void> toggleReminders() async {
    AppLogger.d(
      '🔄 toggleReminders() chamado - estado atual: enabled=${state.isEnabled}',
    );

    state = state.copyWith(isLoading: true, error: null);
    AppLogger.d('💭 Estado alterado para loading=true');

    try {
      final newState = !state.isEnabled;
      AppLogger.d('🎯 Novo estado será: enabled=$newState');

      if (newState) {
        // Solicita permissão antes de ativar
        AppLogger.d('🔐 Solicitando permissão...');
        final hasPermission = await _notificationService.requestPermission();
        AppLogger.d('🔐 Permissão concedida: $hasPermission');

        if (!hasPermission) {
          AppLogger.w('❌ Permissão negada');
          state = state.copyWith(
            isLoading: false,
            error: 'Permissão de notificação necessária',
          );
          return;
        }
      }

      AppLogger.d('⚙️ Configurando notificações para: $newState');
      await _notificationService.setRemindersEnabled(newState);
      AppLogger.d('✅ Configuração concluída');

      state = state.copyWith(isEnabled: newState, isLoading: false);
      AppLogger.d(
        '🎉 Estado final: enabled=${state.isEnabled}, loading=${state.isLoading}',
      );
    } catch (e) {
      AppLogger.e('Erro em toggleReminders', e);
      state = state.copyWith(
        isLoading: false,
        error:
            'Erro ao ${state.isEnabled ? 'desativar' : 'ativar'} lembretes: $e',
      );
    }
  }

  /// Testa uma notificação
  Future<void> testNotification() async {
    try {
      await _notificationService.testNotification();
    } catch (e) {
      state = state.copyWith(error: 'Erro ao enviar teste: $e');
    }
  }

  /// Chamado quando um humor é registrado - para sistema de aprendizado
  Future<void> onMoodRegistered({bool respondedToNotification = false}) async {
    try {
      AppLogger.d(
        '🎭 Notificando sistema sobre registro de humor (responded=$respondedToNotification)',
      );
      await _notificationService.onMoodRegistered(
        respondedToNotification: respondedToNotification,
      );
    } catch (e) {
      AppLogger.e('Erro ao processar registro de humor', e);
    }
  }

  /// Limpa erros
  void clearError() {
    state = state.copyWith(error: null);
  }
}
