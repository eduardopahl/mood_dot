import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/mood_entry.dart';
import '../theme/app_theme.dart';

class DailyMoodCard extends StatelessWidget {
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

  @override
  Widget build(BuildContext context) {
    // Usar as entradas já ordenadas (mais recente primeiro)
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
            color: Colors.black.withOpacity(0.12),
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
                      ).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _getAverageMoodColor(
                          context,
                          averageMood,
                        ).withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      DateFormat('dd MMM', 'pt_BR').format(date),
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
                          DateFormat('EEEE', 'pt_BR').format(date),
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          '${entries.length} ${entries.length == 1 ? 'registro' : 'registros'}',
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall?.copyWith(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withOpacity(0.6),
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
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.7),
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
                                    .withOpacity(0.3),
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
                                .withOpacity(0.05),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: moodEntry
                                  .getColorFromContext(context)
                                  .withOpacity(0.2),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                moodEntry.moodDescription,
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
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface.withOpacity(0.7),
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
