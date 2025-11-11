import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/premium_service.dart';

/// Provider que monitora o status premium em tempo real
final premiumStatusProvider =
    StateNotifierProvider<PremiumStatusNotifier, bool>((ref) {
      return PremiumStatusNotifier();
    });

class PremiumStatusNotifier extends StateNotifier<bool> {
  PremiumStatusNotifier() : super(PremiumService.instance.isPremium) {
    // Verifica o status inicial
    _checkStatus();
  }

  void _checkStatus() {
    state = PremiumService.instance.isPremium;
  }

  /// Atualiza o status premium e notifica listeners
  void updateStatus(bool isPremium) {
    state = isPremium;
  }

  /// Força uma verificação do status
  void refresh() {
    _checkStatus();
  }
}
