import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/mood_providers.dart';
import '../../domain/entities/mood_entry.dart';
import 'add_mood_page.dart';
import '../widgets/mood_entry_card.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final moodEntriesAsync = ref.watch(moodEntriesProvider);
    final todayMoodAsync = ref.watch(todayMoodEntryProvider);

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(moodEntriesProvider);
            ref.invalidate(todayMoodEntryProvider);
          },
          child: CustomScrollView(
            slivers: [
              // Header customizado
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Text(
                        'MoodDot',
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      Text(
                        DateFormat(
                          'EEEE, dd MMM',
                          'pt_BR',
                        ).format(DateTime.now()),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Seção do humor de hoje
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: _buildTodaySection(context, todayMoodAsync),
                ),
              ),

              // Lista de entradas de humor
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'Histórico',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 8)),

              moodEntriesAsync.when(
                data: (entries) {
                  if (entries.isEmpty) {
                    return const SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.sentiment_neutral,
                              size: 64,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Nenhum registro ainda',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Adicione seu primeiro humor!',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final entry = entries[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 4.0,
                        ),
                        child: MoodEntryCard(
                          entry: entry,
                          onTap: () => _editMoodEntry(context, entry),
                          onDelete: () => _deleteMoodEntry(context, ref, entry),
                        ),
                      );
                    }, childCount: entries.length),
                  );
                },
                loading:
                    () => const SliverFillRemaining(
                      child: Center(child: CircularProgressIndicator()),
                    ),
                error:
                    (error, stack) => SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              size: 64,
                              color: Colors.red,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Erro ao carregar dados',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              error.toString(),
                              style: Theme.of(context).textTheme.bodyMedium,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
              ),

              // Espaço extra no final
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTodaySection(
    BuildContext context,
    AsyncValue<MoodEntry?> todayMoodAsync,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Hoje', style: Theme.of(context).textTheme.titleLarge),
                const Spacer(),
                Text(
                  DateFormat('dd/MM/yyyy').format(DateTime.now()),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            todayMoodAsync.when(
              data: (todayEntry) {
                if (todayEntry == null) {
                  return Column(
                    children: [
                      const Icon(
                        Icons.sentiment_neutral,
                        size: 48,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Como você está se sentindo hoje?',
                        style: Theme.of(context).textTheme.bodyLarge,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => _addMoodEntry(context),
                          child: const Text('Registrar humor'),
                        ),
                      ),
                    ],
                  );
                }

                return Column(
                  children: [
                    Text(
                      todayEntry.emoji,
                      style: const TextStyle(fontSize: 48),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      todayEntry.moodDescription,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Registrado às ${DateFormat('HH:mm').format(todayEntry.createdAt)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                    if (todayEntry.note != null &&
                        todayEntry.note!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        '"${todayEntry.note}"',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed:
                                () => _editMoodEntry(context, todayEntry),
                            child: const Text('Editar'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => _addMoodEntry(context),
                            child: const Text('Novo registro'),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error:
                  (error, stack) => Text(
                    'Erro ao carregar humor de hoje',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.red),
                  ),
            ),
          ],
        ),
      ),
    );
  }

  void _addMoodEntry(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddMoodPage()),
    );

    if (result == true && context.mounted) {
      // Atualizar a lista quando voltar da tela de adicionar
      // O Riverpod vai automaticamente refrescar os providers
    }
  }

  void _editMoodEntry(BuildContext context, MoodEntry entry) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddMoodPage(existingEntry: entry),
      ),
    );

    if (result == true && context.mounted) {
      // Atualizar a lista quando voltar da tela de editar
    }
  }

  void _deleteMoodEntry(
    BuildContext context,
    WidgetRef ref,
    MoodEntry entry,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Excluir registro'),
            content: const Text(
              'Tem certeza que deseja excluir este registro de humor?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Excluir'),
              ),
            ],
          ),
    );

    if (confirm == true && entry.id != null) {
      await ref
          .read(moodEntryNotifierProvider.notifier)
          .deleteMoodEntry(entry.id!);
      ref.invalidate(moodEntriesProvider);
      ref.invalidate(todayMoodEntryProvider);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registro excluído com sucesso')),
        );
      }
    }
  }
}
