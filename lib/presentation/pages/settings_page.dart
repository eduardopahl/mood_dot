import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/theme_provider.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(themeNotifierProvider);

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
            _buildSettingsTile(
              Icons.notifications,
              'Lembretes diários',
              'Desativado',
              () {},
            ),
            _buildSettingsTile(
              Icons.schedule,
              'Horário do lembrete',
              '20:00',
              () {},
            ),
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
        color: Theme.of(context).primaryColor,
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
              color: Theme.of(context).colorScheme.outline,
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
}
