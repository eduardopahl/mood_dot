import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/mood_providers.dart';
import '../providers/locale_provider.dart';
import '../../domain/entities/mood_entry.dart';
import 'add_mood_page.dart';
import '../widgets/daily_mood_card.dart';
import '../widgets/app_snackbar.dart';
import '../theme/app_theme.dart';
import '../../core/extensions/app_localizations_extension.dart';

// Provider para controlar se devemos mostrar histórico completo
final showFullHistoryProvider = StateProvider<bool>((ref) => false);

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showFullHistory = ref.watch(showFullHistoryProvider);
    final l10n = context.l10n;
    final currentLocale = ref.watch(localeProvider);
    final moodEntriesAsync = ref.watch(
      showFullHistory ? moodEntriesProvider : recentMoodEntriesProvider,
    );
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            final showFullHistory = ref.read(showFullHistoryProvider);
            ref.invalidate(
              showFullHistory ? moodEntriesProvider : recentMoodEntriesProvider,
            );
          },
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
                  decoration: BoxDecoration(
                    gradient:
                        isDarkMode
                            ? LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppTheme.darkCardBackground,
                                AppTheme.darkSurface,
                              ],
                            )
                            : LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppTheme.primaryColor.withAlpha(
                                  (0.15 * 255).round(),
                                ),
                                AppTheme.secondaryColor.withAlpha(
                                  (0.15 * 255).round(),
                                ),
                              ],
                            ),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(32),
                      bottomRight: Radius.circular(32),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.hello,
                                style: Theme.of(
                                  context,
                                ).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.getSecondaryTextColor(
                                    context,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                l10n.howAreYouToday,
                                style: Theme.of(
                                  context,
                                ).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.getPrimaryTextColor(context),
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.getCardBackgroundColor(
                                context,
                              ).withAlpha((0.8 * 255).round()),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: Theme.of(context).colorScheme.primary
                                    .withAlpha((0.3 * 255).round()),
                                width: 1,
                              ),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  DateFormat(
                                    'dd',
                                    currentLocale.languageCode == 'pt'
                                        ? 'pt_BR'
                                        : 'en_US',
                                  ).format(DateTime.now()),
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                                Text(
                                  DateFormat(
                                    'MMM',
                                    currentLocale.languageCode == 'pt'
                                        ? 'pt_BR'
                                        : 'en_US',
                                  ).format(DateTime.now()),
                                  style: Theme.of(
                                    context,
                                  ).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context).colorScheme.primary
                                        .withAlpha((0.8 * 255).round()),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.getCardBackgroundColor(
                            context,
                          ).withAlpha((0.6 * 255).round()),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          DateFormat(
                            'EEEE',
                            currentLocale.languageCode == 'pt'
                                ? 'pt_BR'
                                : 'en_US',
                          ).format(DateTime.now()),
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.getPrimaryTextColor(context),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 24)),

              moodEntriesAsync.when(
                data: (entries) {
                  if (entries.isEmpty) {
                    return SliverFillRemaining(
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.surface,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.sentiment_neutral_outlined,
                                  size: 40,
                                  color: AppTheme.getSecondaryTextColor(
                                    context,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                              Text(
                                l10n.noRecordsYet,
                                style: Theme.of(
                                  context,
                                ).textTheme.titleLarge?.copyWith(
                                  color: AppTheme.getPrimaryTextColor(context),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                l10n.tapToAddFirstMood,
                                style: Theme.of(
                                  context,
                                ).textTheme.bodyMedium?.copyWith(
                                  color: AppTheme.getSecondaryTextColor(
                                    context,
                                  ),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }

                  // Agrupar entries por dia
                  final groupedEntries = _groupEntriesByDay(entries);

                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        // Items dos mood cards
                        if (index < groupedEntries.length) {
                          final dayEntries = groupedEntries[index];
                          final date = dayEntries.first.date;

                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: DailyMoodCard(
                              date: date,
                              entries: dayEntries,
                              onEntryTap:
                                  (entry) => _editMoodEntry(context, entry),
                              onEntryDelete:
                                  (entry) =>
                                      _deleteMoodEntry(context, ref, entry),
                            ),
                          );
                        }
                        // Botão "Ver histórico completo" ou "Mostrar recentes" no final
                        else if (index == groupedEntries.length) {
                          final showFullHistory = ref.watch(
                            showFullHistoryProvider,
                          );
                          return Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              children: [
                                OutlinedButton.icon(
                                  onPressed: () => _toggleHistoryView(ref),
                                  icon: Icon(
                                    showFullHistory
                                        ? Icons.access_time
                                        : Icons.history,
                                  ),
                                  label: Text(
                                    showFullHistory
                                        ? l10n.showOnlyRecent
                                        : l10n.viewFullHistory,
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 12,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  showFullHistory
                                      ? l10n.showingFullHistory
                                      : l10n.showingLast30Days,
                                  style: Theme.of(
                                    context,
                                  ).textTheme.bodySmall?.copyWith(
                                    color: AppTheme.getSecondaryTextColor(
                                      context,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                        return null;
                      },
                      childCount: groupedEntries.length + 1, // +1 para o botão
                    ),
                  );
                },
                loading:
                    () => SliverFillRemaining(
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        child: const Center(
                          child: CircularProgressIndicator(strokeWidth: 2.5),
                        ),
                      ),
                    ),
                error:
                    (error, stack) => SliverFillRemaining(
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: Colors.red.withAlpha(
                                    (0.1 * 255).round(),
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.error_outline,
                                  size: 40,
                                  color: Colors.red,
                                ),
                              ),
                              const SizedBox(height: 24),
                              Text(
                                l10n.errorOccurred,
                                style: Theme.of(
                                  context,
                                ).textTheme.titleLarge?.copyWith(
                                  color: Colors.red,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                l10n.tryAgainLater,
                                style: Theme.of(
                                  context,
                                ).textTheme.bodyMedium?.copyWith(
                                  color: AppTheme.getSecondaryTextColor(
                                    context,
                                  ),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        ),
      ),
    );
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
            title: Text(context.l10n.deleteRecord),
            content: Text(context.l10n.confirmDeleteRecord),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(context.l10n.cancel),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: Text(context.l10n.delete),
              ),
            ],
          ),
    );

    if (confirm == true && entry.id != null) {
      await ref.read(moodEntryProvider.notifier).deleteMoodEntry(entry.id!);

      // Invalidar ambos os providers para manter sincronização
      ref.invalidate(recentMoodEntriesProvider);
      ref.invalidate(moodEntriesProvider);

      if (context.mounted) {
        AppSnackBar.showSuccess(context, context.l10n.recordDeletedSuccess);
      }
    }
  }

  // Agrupa entries por dia, mantendo a ordem decrescente
  List<List<MoodEntry>> _groupEntriesByDay(List<MoodEntry> entries) {
    final Map<String, List<MoodEntry>> grouped = {};

    for (final entry in entries) {
      final dateKey = DateFormat('yyyy-MM-dd').format(entry.date);
      grouped.putIfAbsent(dateKey, () => []).add(entry);
    }

    // Ordenar cada grupo por horário (decrescente - mais recente primeiro) e retornar grupos por data (decrescente)
    final result =
        grouped.entries.toList()..sort(
          (a, b) => b.key.compareTo(a.key),
        ); // Dias mais recentes primeiro

    return result.map((entry) {
      entry.value.sort(
        (a, b) => b.date.compareTo(a.date),
      ); // Horários decrescentes dentro do dia (mais recente primeiro)
      return entry.value;
    }).toList();
  }

  void _toggleHistoryView(WidgetRef ref) {
    final currentState = ref.read(showFullHistoryProvider);
    ref.read(showFullHistoryProvider.notifier).state = !currentState;
  }
}
