import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configurações')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSettingsSection('Aparência', [
            _buildSettingsTile(Icons.palette, 'Tema', 'Sistema', () {}),
            _buildSettingsTile(Icons.language, 'Idioma', 'Português', () {}),
          ]),
          const SizedBox(height: 24),
          _buildSettingsSection('Notificações', [
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
          _buildSettingsSection('Dados', [
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
          _buildSettingsSection('Sobre', [
            _buildSettingsTile(Icons.info, 'Versão', '1.0.0', () {}),
            _buildSettingsTile(Icons.help, 'Ajuda', 'Central de ajuda', () {}),
          ]),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 8),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
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
