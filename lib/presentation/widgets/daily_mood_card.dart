import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/mood_entry.dart';
import '../theme/app_theme.dart';
import '../../generated/l10n/app_localizations.dart';
import '../../core/extensions/app_localizations_extension.dart';
import '../providers/locale_provider.dart';

class DailyMoodCard extends ConsumerWidget {
  final DateTime date;
  final List<MoodEntry> entries;
  final VoidCallback? onTap;
  final Function(MoodEntry)? onEntryTap;
  final Function(MoodEntry)? onEntryDelete;

  const DailyMoodCard({
    super.key,
    required this.date,
    required this.entries,
    this.onTap,
    this.onEntryTap,
    this.onEntryDelete,
  });

  String getMoodDescription(int moodLevel, AppLocalizations l10n) {
    switch (moodLevel) {
      case 1:
        return l10n.moodVerySad;
      case 2:
        return l10n.moodSad;
      case 3:
        return l10n.moodNeutral;
      case 4:
        return l10n.moodHappy;
      case 5:
        return l10n.moodVeryHappy;
      default:
        return l10n.moodNeutral;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final currentLocale = ref.watch(
      localeProvider,
    ); // Usar as entradas já ordenadas (mais recente primeiro)
    final sortedEntries = entries;

    // Calcular humor médio do dia
    final averageMood =
        entries.map((e) => e.moodLevel).reduce((a, b) => a + b) /
        entries.length;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.12 * 255).round()),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cabeçalho do dia
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getAverageMoodColor(
                        context,
                        averageMood,
                      ).withAlpha((0.1 * 255).round()),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _getAverageMoodColor(
                          context,
                          averageMood,
                        ).withAlpha((0.3 * 255).round()),
                      ),
                    ),
                    child: Text(
                      DateFormat(
                        'dd MMM',
                        currentLocale.languageCode == 'pt' ? 'pt_BR' : 'en_US',
                      ).format(date),
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: _getAverageMoodColor(context, averageMood),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          DateFormat(
                            'EEEE',
                            currentLocale.languageCode == 'pt'
                                ? 'pt_BR'
                                : 'en_US',
                          ).format(date),
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          '${entries.length} ${entries.length == 1 ? l10n.recordSingle : l10n.recordPlural}',
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface
                                .withAlpha((0.6 * 255).round()),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Linha do tempo dos humores
              _buildMoodTimeline(context, sortedEntries),

              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMoodTimeline(
    BuildContext context,
    List<MoodEntry> sortedEntries,
  ) {
    return Column(
      children:
          sortedEntries.asMap().entries.map((entry) {
            final index = entry.key;
            final moodEntry = entry.value;
            final isLast = index == sortedEntries.length - 1;

            return Column(
              children: [
                Row(
                  children: [
                    // Horário
                    SizedBox(
                      width: 50,
                      child: Text(
                        DateFormat('HH:mm').format(moodEntry.date),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface
                              .withAlpha((0.7 * 255).round()),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Linha vertical e círculo do humor
                    Column(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: moodEntry.getColorFromContext(context),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: moodEntry
                                    .getColorFromContext(context)
                                    .withAlpha((0.3 * 255).round()),
                                blurRadius: 4,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: Image.asset(
                              moodEntry.iconPath,
                              fit: BoxFit.cover,
                              errorBuilder:
                                  (context, error, stackTrace) => Center(
                                    child: Text(
                                      moodEntry.emoji,
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ),
                            ),
                          ),
                        ),
                        if (!isLast)
                          Container(
                            width: 2,
                            height: 20,
                            decoration: BoxDecoration(
                              color: Theme.of(context).dividerColor,
                              borderRadius: BorderRadius.circular(1),
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(width: 12),

                    // Descrição do humor e nota (se houver)
                    Expanded(
                      child: GestureDetector(
                        onTap: () => onEntryTap?.call(moodEntry),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: moodEntry
                                .getColorFromContext(context)
                                .withAlpha((0.05 * 255).round()),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: moodEntry
                                  .getColorFromContext(context)
                                  .withAlpha((0.2 * 255).round()),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                getMoodDescription(
                                  moodEntry.moodLevel,
                                  context.l10n,
                                ),
                                style: Theme.of(
                                  context,
                                ).textTheme.labelMedium?.copyWith(
                                  color: moodEntry.getColorFromContext(context),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (moodEntry.note != null &&
                                  moodEntry.note!.isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Text(
                                  moodEntry.note!,
                                  style: Theme.of(
                                    context,
                                  ).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withAlpha((0.7 * 255).round()),
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Menu de ações (editar/excluir)
                    if (onEntryTap != null || onEntryDelete != null)
                      PopupMenuButton<String>(
                        icon: Icon(
                          Icons.more_vert,
                          size: 16,
                          color: Theme.of(context).colorScheme.onSurface
                              .withAlpha((0.6 * 255).round()),
                        ),
                        onSelected: (value) {
                          if (value == 'edit' && onEntryTap != null) {
                            onEntryTap!(moodEntry);
                          } else if (value == 'delete' &&
                              onEntryDelete != null) {
                            onEntryDelete!(moodEntry);
                          }
                        },
                        itemBuilder:
                            (context) => [
                              if (onEntryTap != null)
                                PopupMenuItem(
                                  value: 'edit',
                                  child: Row(
                                    children: [
                                      const Icon(Icons.edit, size: 18),
                                      const SizedBox(width: 8),
                                      Text(context.l10n.editAction),
                                    ],
                                  ),
                                ),
                              if (onEntryDelete != null)
                                PopupMenuItem(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.delete,
                                        size: 18,
                                        color: Colors.red,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        context.l10n.deleteAction,
                                        style: const TextStyle(
                                          color: Colors.red,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                      ),
                  ],
                ),
                if (!isLast) const SizedBox(height: 12),
              ],
            );
          }).toList(),
    );
  }

  Color _getAverageMoodColor(BuildContext context, double averageMood) {
    return AppTheme.getMoodColorFromContext(context, averageMood.round());
  }
}
