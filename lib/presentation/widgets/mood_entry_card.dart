import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/mood_entry.dart';
import '../../generated/l10n/app_localizations.dart';
import '../../core/extensions/app_localizations_extension.dart';
import '../providers/locale_provider.dart';

class MoodEntryCard extends ConsumerWidget {
  final MoodEntry entry;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const MoodEntryCard({
    super.key,
    required this.entry,
    this.onTap,
    this.onDelete,
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
    final currentLocale = ref.watch(localeProvider);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.08 * 255).round()),
            blurRadius: 16,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: const BoxDecoration(shape: BoxShape.circle),
                  clipBehavior: Clip.hardEdge,
                  child: Image.asset(
                    entry.iconPath,
                    width: 56,
                    height: 56,
                    fit: BoxFit.cover,
                    errorBuilder:
                        (context, error, stackTrace) => Container(
                          decoration: BoxDecoration(
                            color: entry
                                .getColorFromContext(context)
                                .withAlpha((0.15 * 255).round()),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              entry.emoji,
                              style: const TextStyle(fontSize: 36),
                            ),
                          ),
                        ),
                  ),
                ),

                const SizedBox(width: 16),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              getMoodDescription(entry.moodLevel, l10n),
                              style: Theme.of(
                                context,
                              ).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ),
                          Text(
                            _formatTime(entry.createdAt, currentLocale),
                            style: Theme.of(
                              context,
                            ).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.outline,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatDate(entry.date, l10n, currentLocale),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                      ),
                      if (entry.note != null && entry.note!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface
                                .withAlpha((0.5 * 255).round()),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            entry.note!,
                            style: Theme.of(
                              context,
                            ).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface
                                  .withAlpha((0.7 * 255).round()),
                              fontStyle: FontStyle.italic,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                if (onDelete != null) ...[
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      shape: BoxShape.circle,
                    ),
                    child: PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'delete') {
                          onDelete?.call();
                        }
                      },
                      itemBuilder:
                          (context) => [
                            PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.delete_outline,
                                    color: Colors.red,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(context.l10n.deleteAction),
                                ],
                              ),
                            ),
                          ],
                      icon: Icon(
                        Icons.more_horiz,
                        color: Theme.of(context).colorScheme.outline,
                        size: 20,
                      ),
                      padding: const EdgeInsets.all(8),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(
    DateTime date,
    AppLocalizations l10n,
    Locale currentLocale,
  ) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final entryDate = DateTime(date.year, date.month, date.day);

    if (entryDate == today) {
      return l10n.today;
    } else if (entryDate == yesterday) {
      return l10n.yesterday;
    } else {
      final locale = currentLocale.languageCode == 'pt' ? 'pt_BR' : 'en_US';
      return DateFormat('dd/MM/yyyy', locale).format(date);
    }
  }

  String _formatTime(DateTime dateTime, Locale currentLocale) {
    final locale = currentLocale.languageCode == 'pt' ? 'pt_BR' : 'en_US';
    return DateFormat('HH:mm', locale).format(dateTime);
  }
}
