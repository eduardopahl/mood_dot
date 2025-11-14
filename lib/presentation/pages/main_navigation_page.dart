import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'home_page.dart';
import 'statistics_page.dart';
import 'add_mood_page.dart';
import 'calendar_page.dart';
import 'settings_page.dart';
import '../providers/mood_providers.dart';
import '../../core/extensions/app_localizations_extension.dart';

final navigationIndexProvider = StateProvider<int>((ref) => 0);

class MainNavigationPage extends ConsumerWidget {
  const MainNavigationPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(navigationIndexProvider);
    final l10n = context.l10n;

    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: const [
          HomePage(),
          StatisticsPage(),
          CalendarPage(),
          SettingsPage(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
          boxShadow: [
            BoxShadow(
              color: Theme.of(
                context,
              ).shadowColor.withAlpha((0.1 * 255).round()),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Container(
            height: 70,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(context, ref, 0, Icons.home_rounded, l10n.home),
                _buildNavItem(
                  context,
                  ref,
                  1,
                  Icons.bar_chart_rounded,
                  l10n.stats,
                ),
                _buildAddButton(context, ref),
                _buildNavItem(
                  context,
                  ref,
                  2,
                  Icons.calendar_month_rounded,
                  l10n.calendar,
                ),
                _buildNavItem(
                  context,
                  ref,
                  3,
                  Icons.settings_rounded,
                  l10n.settings,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    WidgetRef ref,
    int index,
    IconData icon,
    String label,
  ) {
    final currentIndex = ref.watch(navigationIndexProvider);
    final isSelected = currentIndex == index;
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () => ref.read(navigationIndexProvider.notifier).state = index,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color:
              isSelected
                  ? theme.primaryColor.withAlpha((0.1 * 255).round())
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 24,
              color:
                  isSelected
                      ? Theme.of(
                        context,
                      ).bottomNavigationBarTheme.selectedItemColor
                      : Theme.of(
                        context,
                      ).bottomNavigationBarTheme.unselectedItemColor,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color:
                    isSelected
                        ? Theme.of(
                          context,
                        ).bottomNavigationBarTheme.selectedItemColor
                        : Theme.of(
                          context,
                        ).bottomNavigationBarTheme.unselectedItemColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddButton(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () async {
        final result = await Navigator.of(context).push<bool>(
          MaterialPageRoute(builder: (context) => const AddMoodPage()),
        );

        if (result == true) {
          ref.invalidate(moodEntriesProvider);
          ref.invalidate(recentMoodEntriesProvider);
          ref.invalidate(moodStatisticsProvider);
        }
      },
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              theme.primaryColor,
              theme.primaryColor.withAlpha((0.8 * 255).round()),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: theme.primaryColor.withAlpha((0.3 * 255).round()),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(Icons.add_rounded, size: 28, color: Colors.white),
      ),
    );
  }
}
