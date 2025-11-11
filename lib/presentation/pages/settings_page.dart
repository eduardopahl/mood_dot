import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/theme_provider.dart';
import '../providers/reminder_provider.dart';
import '../providers/premium_provider.dart';
import '../widgets/app_snackbar.dart';
import '../../core/services/premium_service.dart';
import '../theme/app_theme.dart';
import '../../core/services/ad_event_service.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(themeNotifierProvider);
    final reminderState = ref.watch(reminderStateProvider);

    // 🎬 Registrar abertura de configurações para intersticiais
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AdEventService.instance.onSettingsOpen(context);
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Configurações')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Seção Premium
          _buildPremiumSection(context),
          const SizedBox(height: 24),

          _buildSettingsSection(context, 'Aparência', [
            _buildThemeToggleTile(context, ref, isDarkMode),
            _buildSettingsTile(Icons.language, 'Idioma', 'Português', () {}),
          ]),
          const SizedBox(height: 24),
          _buildSettingsSection(context, 'Notificações', [
            _buildReminderToggleTile(context, reminderState, ref),
            _buildTestButton(context, ref),
            _buildResetLearningButton(context, ref),
          ]),
          const SizedBox(height: 24),
          _buildSettingsSection(context, 'Sobre', [
            _buildSettingsTile(Icons.info, 'Versão', '1.0.0', () {}),
          ]),
        ],
      ),
    );
  }

  Widget _buildThemeToggleTile(
    BuildContext context,
    WidgetRef ref,
    bool isDarkMode,
  ) {
    return ListTile(
      leading: Icon(
        isDarkMode ? Icons.dark_mode : Icons.light_mode,
        color: Theme.of(context).colorScheme.onSurface,
      ),
      title: const Text('Modo escuro'),
      subtitle: Text(isDarkMode ? 'Ativado' : 'Desativado'),
      trailing: Switch(
        value: isDarkMode,
        onChanged: (value) {
          ref.read(themeNotifierProvider.notifier).toggleTheme();
        },
      ),
    );
  }

  Widget _buildSettingsSection(
    BuildContext context,
    String title,
    List<Widget> children,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Card(child: Column(children: children)),
      ],
    );
  }

  Widget _buildSettingsTile(
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Icon(icon, color: isDestructive ? Colors.red : null),
      title: Text(
        title,
        style: TextStyle(color: isDestructive ? Colors.red : null),
      ),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  Widget _buildReminderToggleTile(
    BuildContext context,
    ReminderState reminderState,
    WidgetRef ref,
  ) {
    debugPrint(
      '🎨 Construindo switch - enabled: ${reminderState.isEnabled}, loading: ${reminderState.isLoading}, erro: ${reminderState.error}',
    );

    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.notifications),
          title: const Text('Lembretes diários'),
          subtitle:
              reminderState.isLoading
                  ? const Text('Carregando...')
                  : Text(reminderState.statusText),
          trailing: Switch(
            value: reminderState.isEnabled,
            onChanged:
                reminderState.isLoading
                    ? null
                    : (value) async {
                      debugPrint(
                        '🔘 Switch tocado! Valor atual: ${reminderState.isEnabled}, novo valor: $value',
                      );
                      try {
                        // Limpa erro anterior
                        ref.read(reminderStateProvider.notifier).clearError();
                        await ref
                            .read(reminderStateProvider.notifier)
                            .toggleReminders();
                        debugPrint('✅ toggleReminders() executado com sucesso');
                      } catch (e) {
                        debugPrint('💥 Erro ao executar toggleReminders(): $e');
                      }
                    },
          ),
        ),
        if (reminderState.error != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Icon(
                  Icons.error,
                  color: Theme.of(context).colorScheme.error,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    reminderState.error!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontSize: 12,
                    ),
                  ),
                ),
                TextButton(
                  onPressed:
                      () =>
                          ref.read(reminderStateProvider.notifier).clearError(),
                  child: const Text('OK'),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildTestButton(BuildContext context, WidgetRef ref) {
    return ListTile(
      leading: const Icon(Icons.bug_report),
      title: const Text('Testar Notificação'),
      subtitle: const Text('Enviar notificação de teste'),
      trailing: const Icon(Icons.send),
      onTap: () async {
        debugPrint('Test button pressed');
        await ref.read(reminderStateProvider.notifier).testNotification();
        AppSnackBar.showNotificationSuccess(
          context,
          'Notificação de teste enviada!',
        );
      },
    );
  }

  Widget _buildResetLearningButton(BuildContext context, WidgetRef ref) {
    return ListTile(
      leading: const Icon(Icons.psychology, color: Colors.orange),
      title: const Text('Resetar IA'),
      subtitle: const Text(
        'Remove padrões aprendidos de horários e preferências de notificação',
      ),
      trailing: const Icon(Icons.refresh),
      onTap: () async {
        // Mostra diálogo de confirmação
        final confirmed = await showDialog<bool>(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text('Resetar Sistema Inteligente?'),
                content: const Text(
                  'Isso irá limpar todos os dados aprendidos:\n\n'
                  '• Horários preferidos de notificação\n'
                  '• Score de engajamento personalizado\n'
                  '• Padrões de uso identificados\n\n'
                  'O sistema voltará a usar configurações padrão e precisará reaprender seus hábitos.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Cancelar'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text('Resetar'),
                  ),
                ],
              ),
        );

        if (confirmed == true) {
          debugPrint('Resetando sistema de aprendizado...');

          // Acessa o serviço diretamente
          final notificationService = ref.read(notificationServiceProvider);
          await notificationService.resetLearningSystem();

          AppSnackBar.showAISuccess(
            context,
            'Sistema inteligente resetado com sucesso!',
          );
        }
      },
    );
  }

  Widget _buildPremiumSection(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        // Usa o provider para status reativo
        final isPremium = ref.watch(premiumStatusProvider);

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors:
                  isPremium
                      ? [
                        AppTheme.primaryColor.withOpacity(0.1),
                        AppTheme.primaryColor.withOpacity(0.05),
                      ]
                      : [
                        Colors.amber.withOpacity(0.1),
                        Colors.orange.withOpacity(0.05),
                      ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color:
                  isPremium
                      ? AppTheme.primaryColor.withOpacity(0.3)
                      : Colors.amber.withOpacity(0.3),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    isPremium ? Icons.verified : Icons.star,
                    color:
                        isPremium
                            ? AppTheme.primaryColor
                            : Colors.amber.shade700,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isPremium
                              ? 'MoodDot Premium'
                              : 'Upgrade para Premium',
                          style: Theme.of(
                            context,
                          ).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color:
                                isPremium
                                    ? AppTheme.primaryColor
                                    : Colors.amber.shade700,
                          ),
                        ),
                        Text(
                          isPremium
                              ? 'Obrigado por apoiar o MoodDot!'
                              : 'Remova anúncios e ajude no desenvolvimento',
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              if (!isPremium) ...[
                // Benefícios do Premium
                _buildPremiumBenefit(context, 'Sem anúncios', Icons.block),
                const SizedBox(height: 8),
                _buildPremiumBenefit(
                  context,
                  'Apoie o desenvolvimento',
                  Icons.favorite,
                ),

                const SizedBox(height: 20),

                // Botão de compra
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _purchasePremium(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber.shade600,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Comprar Premium - \$0.99',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Botão de restaurar compras
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => _restorePurchases(context),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      'Restaurar Compras',
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ),
              ] else ...[
                // Status Premium Ativo
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, color: AppTheme.primaryColor),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Você tem acesso premium ativo!',
                          style: TextStyle(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildPremiumBenefit(
    BuildContext context,
    String text,
    IconData icon,
  ) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.amber.shade700),
        const SizedBox(width: 8),
        Text(
          text,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  /// Processa a compra do premium
  Future<void> _purchasePremium(BuildContext context) async {
    // Mostrar loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final success = await PremiumService.instance.purchasePremium();

      if (context.mounted) Navigator.of(context).pop(); // Fechar loading

      if (success && context.mounted) {
        // Atualizar o provider
        if (mounted) {
          ref.read(premiumStatusProvider.notifier).updateStatus(true);
        }

        // Sucesso na compra
        showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text('🏆 Premium Ativado!'),
                content: const Text(
                  'Obrigado por apoiar o MoodDot!\n\n'
                  'Todos os anúncios foram removidos e você agora tem acesso premium completo.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Excelente!'),
                  ),
                ],
              ),
        );
      } else if (context.mounted) {
        // Erro na compra
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro na compra. Tente novamente.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) Navigator.of(context).pop(); // Fechar loading
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro inesperado: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Restaura compras anteriores
  Future<void> _restorePurchases(BuildContext context) async {
    // Mostrar loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => const AlertDialog(
            content: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 16),
                Text('Restaurando compras...'),
              ],
            ),
          ),
    );

    try {
      final success = await PremiumService.instance.restorePurchases();

      if (context.mounted) Navigator.of(context).pop(); // Fechar loading

      if (success && context.mounted) {
        // Compras restauradas com sucesso
        showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text('✅ Compras Restauradas!'),
                content: const Text(
                  'Suas compras foram restauradas com sucesso!\n\n'
                  'O acesso premium foi reativado.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('OK'),
                  ),
                ],
              ),
        );
      } else if (context.mounted) {
        // Nenhuma compra encontrada
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Nenhuma compra anterior encontrada.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) Navigator.of(context).pop(); // Fechar loading
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao restaurar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
