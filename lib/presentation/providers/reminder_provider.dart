import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
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
    debugPrint('🚀 ReminderNotifier: Iniciando carregamento do estado...');
    state = state.copyWith(isLoading: true);

    try {
      debugPrint('🔧 Inicializando serviço de notificações...');
      await _notificationService.initialize();
      debugPrint('✅ Serviço inicializado com sucesso');

      debugPrint('📊 Carregando status das notificações...');
      final status = await _notificationService.getReminderStatus();
      debugPrint('📊 Status carregado: $status');

      state = ReminderState(
        isEnabled: status['enabled'] ?? false,
        isLoading: false,
      );

      debugPrint('🎉 Estado carregado: enabled=${state.isEnabled}');
    } catch (e) {
      debugPrint('💥 Erro ao carregar estado: $e');
      state = state.copyWith(
        isLoading: false,
        error: 'Erro ao carregar configurações: $e',
      );
    }
  }

  /// Alterna o estado dos lembretes
  Future<void> toggleReminders() async {
    debugPrint(
      '🔄 toggleReminders() chamado - estado atual: enabled=${state.isEnabled}',
    );

    state = state.copyWith(isLoading: true, error: null);
    debugPrint('💭 Estado alterado para loading=true');

    try {
      final newState = !state.isEnabled;
      debugPrint('🎯 Novo estado será: enabled=$newState');

      if (newState) {
        // Solicita permissão antes de ativar
        debugPrint('🔐 Solicitando permissão...');
        final hasPermission = await _notificationService.requestPermission();
        debugPrint('🔐 Permissão concedida: $hasPermission');

        if (!hasPermission) {
          debugPrint('❌ Permissão negada');
          state = state.copyWith(
            isLoading: false,
            error: 'Permissão de notificação necessária',
          );
          return;
        }
      }

      debugPrint('⚙️ Configurando notificações para: $newState');
      await _notificationService.setRemindersEnabled(newState);
      debugPrint('✅ Configuração concluída');

      state = state.copyWith(isEnabled: newState, isLoading: false);
      debugPrint(
        '🎉 Estado final: enabled=${state.isEnabled}, loading=${state.isLoading}',
      );
    } catch (e) {
      debugPrint('💥 Erro em toggleReminders: $e');
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
  Future<void> onMoodRegistered() async {
    try {
      debugPrint('🎭 Notificando sistema sobre registro de humor');
      await _notificationService.onMoodRegistered();
    } catch (e) {
      debugPrint('Erro ao processar registro de humor: $e');
    }
  }

  /// Limpa erros
  void clearError() {
    state = state.copyWith(error: null);
  }
}
