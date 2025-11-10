import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/theme_provider.dart';
import '../providers/reminder_provider.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(themeNotifierProvider);
    final reminderState = ref.watch(reminderStateProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Configurações')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
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
          _buildSettingsSection(context, 'Dados', [
            _buildSettingsTile(Icons.backup, 'Backup', 'Fazer backup', () {}),
            _buildSettingsTile(
              Icons.restore,
              'Restaurar',
              'Restaurar dados',
              () {},
            ),
            _buildSettingsTile(
              Icons.delete_forever,
              'Limpar dados',
              'Excluir tudo',
              () {},
              isDestructive: true,
            ),
          ]),
          const SizedBox(height: 24),
          _buildSettingsSection(context, 'Sobre', [
            _buildSettingsTile(Icons.info, 'Versão', '1.0.0', () {}),
            _buildSettingsTile(Icons.help, 'Ajuda', 'Central de ajuda', () {}),
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Notificação de teste enviada!')),
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

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('🧠 Sistema inteligente resetado com sucesso!'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      },
    );
  }
}
