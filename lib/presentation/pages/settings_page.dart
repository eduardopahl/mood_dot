import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/theme_provider.dart';
import '../providers/reminder_provider.dart';
import '../providers/premium_provider.dart';
import '../providers/locale_provider.dart';
import '../widgets/app_snackbar.dart';
import '../../core/services/premium_service.dart';
import '../../generated/l10n/app_localizations.dart';
import '../../core/extensions/app_localizations_extension.dart';
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
    final currentLocale = ref.watch(localeProvider);
    final l10n = context.l10n;

    // 🎬 Registrar abertura de configurações para intersticiais
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AdEventService.instance.onSettingsOpen(context);
    });

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          //TODO Ativar seção premium depois
          // Seção Premium
          // _buildPremiumSection(context, l10n),
          const SizedBox(height: 24),

          _buildSettingsSection(context, l10n.appearance, [
            _buildThemeToggleTile(context, ref, isDarkMode, l10n),
            _buildLanguageTile(context, ref, currentLocale, l10n),
          ]),
          const SizedBox(height: 24),
          _buildSettingsSection(context, l10n.notifications, [
            _buildReminderToggleTile(context, reminderState, ref, l10n),
            _buildTestButton(context, ref, l10n),
            _buildResetLearningButton(context, ref, l10n),
          ]),
          const SizedBox(height: 24),
          _buildSettingsSection(context, l10n.about, [
            _buildSettingsTile(Icons.info, l10n.version, '1.0.0', () {}),
          ]),
        ],
      ),
    );
  }

  Widget _buildThemeToggleTile(
    BuildContext context,
    WidgetRef ref,
    bool isDarkMode,
    AppLocalizations l10n,
  ) {
    return ListTile(
      leading: Icon(
        isDarkMode ? Icons.dark_mode : Icons.light_mode,
        color: Theme.of(context).colorScheme.onSurface,
      ),
      title: Text(l10n.darkMode),
      subtitle: Text(isDarkMode ? l10n.enabled : l10n.disabled),
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

  Widget _buildLanguageTile(
    BuildContext context,
    WidgetRef ref,
    Locale currentLocale,
    AppLocalizations l10n,
  ) {
    String getCurrentLanguageName() {
      return currentLocale.languageCode == 'pt'
          ? l10n.portuguese
          : l10n.english;
    }

    return ListTile(
      leading: const Icon(Icons.language),
      title: Text(l10n.language),
      subtitle: Text(getCurrentLanguageName()),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _showLanguageDialog(context, ref, l10n),
    );
  }

  void _showLanguageDialog(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(l10n.language),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Text('🇧🇷'),
                  title: Text(l10n.portuguese),
                  trailing:
                      ref.watch(localeProvider).languageCode == 'pt'
                          ? const Icon(Icons.check, color: Colors.green)
                          : null,
                  onTap: () {
                    ref
                        .read(localeProvider.notifier)
                        .setLocale(const Locale('pt', 'BR'));
                    Navigator.of(context).pop();
                  },
                ),
                ListTile(
                  leading: const Text('🇺🇸'),
                  title: Text(l10n.english),
                  trailing:
                      ref.watch(localeProvider).languageCode == 'en'
                          ? const Icon(Icons.check, color: Colors.green)
                          : null,
                  onTap: () {
                    ref
                        .read(localeProvider.notifier)
                        .setLocale(const Locale('en', 'US'));
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(l10n.cancel),
              ),
            ],
          ),
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
    AppLocalizations l10n,
  ) {
    debugPrint(
      '🎨 Construindo switch - enabled: ${reminderState.isEnabled}, loading: ${reminderState.isLoading}, erro: ${reminderState.error}',
    );

    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.notifications),
          title: Text(l10n.dailyReminders),
          subtitle:
              reminderState.isLoading
                  ? Text(l10n.loading)
                  : Text(reminderState.statusText(l10n.enabled, l10n.disabled)),
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
                  child: Text(l10n.ok),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildTestButton(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) {
    return ListTile(
      leading: const Icon(Icons.bug_report),
      title: Text(l10n.testNotification),
      subtitle: Text(l10n.sendTestNotification),
      trailing: const Icon(Icons.send),
      onTap: () async {
        debugPrint('Test button pressed');
        final status = await Permission.notification.status;
        if (!status.isGranted) {
          final result = await Permission.notification.request();
          if (!result.isGranted) {
            AppSnackBar.showError(context, l10n.testNotificationSent);
            return;
          }
        }
        await ref.read(reminderStateProvider.notifier).testNotification();
        AppSnackBar.showNotificationSuccess(context, l10n.testNotificationSent);
      },
    );
  }

  Widget _buildResetLearningButton(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) {
    return ListTile(
      leading: const Icon(Icons.psychology, color: Colors.orange),
      title: Text(l10n.resetAI),
      subtitle: Text(l10n.resetAIDescription),
      trailing: const Icon(Icons.refresh),
      onTap: () async {
        // Mostra diálogo de confirmação
        final confirmed = await showDialog<bool>(
          context: context,
          builder:
              (context) => AlertDialog(
                title: Text(l10n.resetIntelligentSystem),
                content: Text(l10n.resetConfirmation),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text(l10n.cancel),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: Text(l10n.reset),
                  ),
                ],
              ),
        );

        if (confirmed == true) {
          debugPrint('Resetando sistema de aprendizado...');

          // Acessa o serviço diretamente
          final notificationService = ref.read(notificationServiceProvider);
          await notificationService.resetLearningSystem();

          AppSnackBar.showAISuccess(context, l10n.aiResetSuccess);
        }
      },
    );
  }

  Widget _buildPremiumSection(BuildContext context, AppLocalizations l10n) {
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
                          isPremium ? l10n.moodDotPremium : l10n.premiumUpgrade,
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
                          isPremium ? l10n.alreadyPremium : l10n.removeAds,
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
                _buildPremiumBenefit(context, l10n.noAds, Icons.block),
                const SizedBox(height: 8),
                _buildPremiumBenefit(
                  context,
                  l10n.supportDevelopment,
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
                    child: Text(
                      l10n.buyPremiumPrice,
                      style: const TextStyle(
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
                      l10n.restorePurchases,
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
                          l10n.youHavePremiumAccess,
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
    final l10n = context.l10n;

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
                title: Text('🏆 ${l10n.premiumActivated}'),
                content: Text(
                  '${l10n.thanksForSupport}\n\n'
                  '${l10n.premiumActivatedMessage}',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(l10n.excellent),
                  ),
                ],
              ),
        );
      } else if (context.mounted) {
        // Erro na compra
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.purchaseError),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) Navigator.of(context).pop(); // Fechar loading
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.unexpectedError(e.toString())),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Restaura compras anteriores
  Future<void> _restorePurchases(BuildContext context) async {
    final l10n = context.l10n;

    // Mostrar loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            content: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(width: 16),
                Text(l10n.restoringPurchases),
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
                title: Text('✅ ${l10n.purchasesRestored}'),
                content: Text(l10n.purchasesRestoredMessage),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(l10n.ok),
                  ),
                ],
              ),
        );
      } else if (context.mounted) {
        // Nenhuma compra encontrada
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.noPurchasesFound),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) Navigator.of(context).pop(); // Fechar loading
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.restoreError(e.toString())),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
