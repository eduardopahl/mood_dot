import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/mood_providers.dart';
import '../../domain/entities/mood_entry.dart';
import '../theme/app_theme.dart';
import '../widgets/ad_banner_widget.dart';
import '../../core/services/ad_event_service.dart';
import '../../generated/l10n/app_localizations.dart';
import '../../core/extensions/app_localizations_extension.dart';

enum StatisticsPeriod {
  week7Days('week7Days'),
  month30Days('month30Days'),
  month90Days('month90Days'),
  allTime('allTime');

  const StatisticsPeriod(this.key);
  final String key;
}

// Provider para gerenciar o período selecionado
final selectedPeriodProvider = StateProvider<StatisticsPeriod>((ref) {
  return StatisticsPeriod.month30Days;
});

class StatisticsPage extends ConsumerWidget {
  const StatisticsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedPeriod = ref.watch(selectedPeriodProvider);
    final l10n = context.l10n;

    // Usar o provider filtrado baseado no período selecionado
    final filteredStatsAsync = ref.watch(
      filteredStatisticsProvider(selectedPeriod.key),
    );
    final advancedStatsAsync = ref.watch(advancedStatsProvider);
    final moodEntriesAsync = ref.watch(moodEntriesProvider);

    // 🎬 Registrar visualização de estatísticas para intersticiais
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AdEventService.instance.onStatisticsView(context);
    });

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            // Invalida apenas os dados base - o filteredStatisticsProvider se atualizará automaticamente
            ref.invalidate(moodStatisticsProvider);
            ref.invalidate(advancedStatsProvider);
            ref.invalidate(moodEntriesProvider);
            ref.invalidate(recentMoodEntriesProvider);
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Text(
                  l10n.statistics,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // Seletor de período
                _buildPeriodSelector(context, ref),
                const SizedBox(height: 12),

                // Banner de anúncio centralizado com margens top e bottom
                Center(child: AdBannerWidget()),
                const SizedBox(height: 12),
                // Cards de métricas principais
                _buildMetricsCards(
                  context,
                  filteredStatsAsync,
                  advancedStatsAsync,
                ),

                const SizedBox(height: 24),

                // Gráfico de distribuição por humor
                _buildMoodDistribution(context, filteredStatsAsync),

                // const SizedBox(height: 24),
                const SizedBox(height: 24),

                // Padrão semanal
                _buildWeeklyPattern(context, advancedStatsAsync),

                const SizedBox(height: 24),

                // Gráfico de linha temporal (últimos 30 dias)
                _buildTimelineChart(context, moodEntriesAsync),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPeriodSelector(BuildContext context, WidgetRef ref) {
    final selectedPeriod = ref.watch(selectedPeriodProvider);
    final l10n = context.l10n;

    String getPeriodLabel(StatisticsPeriod period) {
      switch (period) {
        case StatisticsPeriod.week7Days:
          return l10n.last7DaysLabel;
        case StatisticsPeriod.month30Days:
          return l10n.last30DaysLabel;
        case StatisticsPeriod.month90Days:
          return l10n.last90DaysLabel;
        case StatisticsPeriod.allTime:
          return l10n.allTimeLabel;
      }
    }

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor, width: 1),
      ),
      child: Row(
        children:
            StatisticsPeriod.values.map((period) {
              final isSelected = selectedPeriod == period;
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    ref.read(selectedPeriodProvider.notifier).state = period;
                    // O FutureProvider.family automaticamente atualiza quando o parâmetro muda
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 12,
                    ),
                    decoration: BoxDecoration(
                      color:
                          isSelected
                              ? Theme.of(context).colorScheme.primary
                              : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      getPeriodLabel(period),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color:
                            isSelected
                                ? Colors.white
                                : Theme.of(context).colorScheme.onSurface,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }

  Widget _buildMetricsCards(
    BuildContext context,
    AsyncValue<Map<String, dynamic>> filteredStatsAsync,
    AsyncValue<Map<String, dynamic>> advancedStatsAsync,
  ) {
    final l10n = context.l10n;

    return filteredStatsAsync.when(
      data:
          (stats) => advancedStatsAsync.when(
            data: (advancedStats) {
              final average = stats['average'] as double;
              final totalEntries = stats['totalEntries'] as int;
              return Row(
                children: [
                  Expanded(
                    child: _buildMetricCard(
                      context,
                      l10n.averageMoodLabel,
                      '${average.toStringAsFixed(1)}/5',
                      _getAverageEmoji(average),
                      _getAverageColor(context, average),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildMetricCard(
                      context,
                      l10n.totalEntriesLabel,
                      totalEntries.toString(),
                      '�',
                      AppTheme.secondaryColor,
                    ),
                  ),
                ],
              );
            },
            loading:
                () => Row(
                  children: [
                    Expanded(
                      child: _buildMetricCard(
                        context,
                        l10n.averageMoodLabel,
                        '...',
                        '⏳',
                        Colors.grey.shade300,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildMetricCard(
                        context,
                        l10n.totalEntriesLabel,
                        '...',
                        '⏳',
                        Colors.grey.shade300,
                      ),
                    ),
                  ],
                ),
            error: (error, stack) => Text('Erro: $error'),
          ),
      loading:
          () => Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  context,
                  l10n.averageMoodLabel,
                  '...',
                  '⏳',
                  Colors.grey.shade300,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildMetricCard(
                  context,
                  l10n.totalEntriesLabel,
                  '...',
                  '⏳',
                  Colors.grey.shade300,
                ),
              ),
            ],
          ),
      error: (error, stack) => Text('Erro: $error'),
    );
  }

  Widget _buildMetricCard(
    BuildContext context,
    String title,
    String value,
    String emoji,
    Color color, {
    Key? key,
  }) {
    return Container(
      key: key,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Ícone mais elegante e minimalista
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(_getIconForCard(title), size: 24, color: color),
          ),
          const SizedBox(height: 16),

          // Título elegante
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              fontWeight: FontWeight.w500,
              fontSize: 12,
              letterSpacing: 0.5,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),

          // Valor com destaque sutil
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 20,
            ),
            textAlign: TextAlign.center,
          ),

          // Pequena barra de cor como acento
          const SizedBox(height: 12),
          Container(
            width: 24,
            height: 3,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }

  // Método para escolher ícones mais elegantes
  IconData _getIconForCard(String title) {
    // Usar as chaves de tradução para identificar o ícone
    if (title.contains('Médio') || title.contains('Average')) {
      return Icons.sentiment_satisfied_rounded;
    } else if (title.contains('Registros') || title.contains('Records')) {
      return Icons.analytics_rounded;
    } else {
      return Icons.info_rounded;
    }
  }

  Widget _buildMoodDistribution(
    BuildContext context,
    AsyncValue<Map<String, dynamic>> filteredStatsAsync,
  ) {
    final l10n = context.l10n;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).cardTheme.color ?? Colors.white,
            Theme.of(context).colorScheme.primary.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.secondaryColor,
                        AppTheme.secondaryColor.withOpacity(0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.pie_chart, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l10n.moodDistributionLabel,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            filteredStatsAsync.when(
              data: (stats) {
                final countByLevelRaw = stats['countByLevel'];
                final countByLevel =
                    countByLevelRaw is List
                        ? countByLevelRaw
                            .where((item) => item is Map<String, dynamic>)
                            .cast<Map<String, dynamic>>()
                            .toList()
                        : <Map<String, dynamic>>[];

                if (countByLevel.isEmpty) {
                  return _buildEmptyState(l10n.noDataToDisplay);
                }

                // Ordenar do maior para o menor
                countByLevel.sort(
                  (a, b) => (b['count'] as int).compareTo(a['count'] as int),
                );

                final total = countByLevel.fold<int>(
                  0,
                  (sum, item) => sum + (item['count'] as int),
                );

                return Column(
                  children: [
                    Container(
                      height: 320,
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Theme.of(context).colorScheme.surface,
                            Theme.of(
                              context,
                            ).colorScheme.primary.withOpacity(0.02),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(
                              context,
                            ).shadowColor.withOpacity(0.08),
                            blurRadius: 24,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      child: Center(
                        child: SizedBox(
                          height: 240,
                          width: 240,
                          child: Stack(
                            children: [
                              PieChart(
                                PieChartData(
                                  sections:
                                      countByLevel.map((item) {
                                        final moodLevel =
                                            item['mood_level'] as int;
                                        final count = item['count'] as int;
                                        final percentage =
                                            (count / total * 100).round();

                                        final sectionColor =
                                            _getModernMoodColor(
                                              moodLevel,
                                              context,
                                            );

                                        return PieChartSectionData(
                                          value: count.toDouble(),
                                          title:
                                              percentage >= 5
                                                  ? '$percentage%'
                                                  : '',
                                          color: sectionColor,
                                          radius: 75,
                                          titleStyle: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black87,
                                            shadows: [
                                              Shadow(
                                                color: Colors.white.withOpacity(
                                                  0.8,
                                                ),
                                                blurRadius: 3,
                                              ),
                                            ],
                                          ),
                                        );
                                      }).toList(),
                                  centerSpaceRadius: 50,
                                  sectionsSpace: 3,
                                  pieTouchData: PieTouchData(
                                    touchCallback: (
                                      FlTouchEvent event,
                                      pieTouchResponse,
                                    ) {
                                      // 🎬 Registrar interação com gráfico para intersticiais
                                      if (event is FlTapUpEvent) {
                                        AdEventService.instance
                                            .onChartInteraction(context);
                                      }
                                    },
                                  ),
                                ),
                              ),
                              Center(
                                child: Container(
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Theme.of(context).cardColor,
                                        Theme.of(
                                          context,
                                        ).colorScheme.primary.withOpacity(0.05),
                                      ],
                                    ),
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Theme.of(
                                          context,
                                        ).shadowColor.withOpacity(0.15),
                                        blurRadius: 16,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                    border: Border.all(
                                      color: Theme.of(
                                        context,
                                      ).dividerColor.withOpacity(0.1),
                                      width: 1,
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppTheme.primaryColor
                                              .withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Text(
                                          '$total',
                                          style: Theme.of(
                                            context,
                                          ).textTheme.headlineSmall?.copyWith(
                                            fontWeight: FontWeight.w700,
                                            color: AppTheme.primaryColor,
                                            letterSpacing: -0.5,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        l10n.records,
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodySmall?.copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface
                                              .withOpacity(0.6),
                                          fontWeight: FontWeight.w500,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildMoodLegend(countByLevel, total, context, l10n),
                  ],
                );
              },
              loading:
                  () => Column(
                    children: [
                      Container(
                        height: 320,
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Theme.of(context).colorScheme.surface,
                              Theme.of(
                                context,
                              ).colorScheme.primary.withOpacity(0.02),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(
                                context,
                              ).shadowColor.withOpacity(0.08),
                              blurRadius: 24,
                              offset: const Offset(0, 12),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Icon(
                            Icons.pie_chart,
                            size: 64,
                            color: Colors.grey.shade300,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Container(
                        height: 48,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ],
                  ),
              error:
                  (error, stack) =>
                      _buildErrorState(l10n.errorGeneric(error.toString())),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyPattern(
    BuildContext context,
    AsyncValue<Map<String, dynamic>> advancedStatsAsync,
  ) {
    final l10n = context.l10n;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).cardTheme.color ?? Colors.white,
            AppTheme.primaryColor.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.primaryColor,
                        AppTheme.primaryColor.withOpacity(0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.calendar_view_week,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l10n.currentWeek,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            advancedStatsAsync.when(
              data: (stats) {
                final weeklyPattern =
                    stats['weeklyPattern'] as Map<int, double>;

                if (weeklyPattern.isEmpty) {
                  return _buildEmptyState(l10n.noDataToDisplay);
                }

                return Column(
                  children: [
                    SizedBox(
                      height: 220,
                      child: BarChart(
                        BarChartData(
                          maxY: 5,
                          minY: 0,
                          barTouchData: BarTouchData(
                            enabled: true,
                            touchTooltipData: BarTouchTooltipData(
                              tooltipBgColor:
                                  Theme.of(context).colorScheme.inverseSurface,
                              tooltipRoundedRadius: 8,
                              getTooltipItem: (
                                group,
                                groupIndex,
                                rod,
                                rodIndex,
                              ) {
                                final keys = weeklyPattern.keys.toList();
                                final idx = group.x.toInt();
                                final dayIndex = keys[idx]; // 0 = domingo
                                final shortNames = context.l10n.weekdaysShort
                                    .split(',');
                                final dayLabel = shortNames[dayIndex];
                                final originalValue =
                                    weeklyPattern.values.toList()[idx];
                                final displayText =
                                    originalValue < 0
                                        ? '$dayLabel\nNão lançado'
                                        : '$dayLabel\n${originalValue.toStringAsFixed(1)}';
                                return BarTooltipItem(
                                  displayText,
                                  TextStyle(
                                    color:
                                        Theme.of(
                                          context,
                                        ).colorScheme.onInverseSurface,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                );
                              },
                            ),
                          ),
                          titlesData: FlTitlesData(
                            show: true,
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 30,
                                getTitlesWidget: (
                                  double value,
                                  TitleMeta meta,
                                ) {
                                  final days = weeklyPattern.keys.toList();
                                  final shortNames = context.l10n.weekdaysShort
                                      .split(',');
                                  if (value.toInt() < days.length) {
                                    final dayIndex = days[value.toInt()];
                                    final label = shortNames[dayIndex];
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Text(
                                        label,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface
                                              .withOpacity(0.7),
                                        ),
                                      ),
                                    );
                                  }
                                  return const Text('');
                                },
                              ),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 40,
                                interval: 1,
                                getTitlesWidget: (value, meta) {
                                  // Mostrar apenas valores de 1 a 5 (níveis de humor)
                                  if (value >= 1 && value <= 5) {
                                    return Padding(
                                      padding: const EdgeInsets.only(
                                        right: 8.0,
                                      ),
                                      child: Text(
                                        value.toInt().toString(),
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface
                                              .withOpacity(0.6),
                                        ),
                                      ),
                                    );
                                  }
                                  return const Text('');
                                },
                              ),
                            ),
                            topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                          ),
                          borderData: FlBorderData(
                            show: true,
                            border: Border(
                              left: BorderSide(
                                color: Theme.of(context).dividerColor,
                              ),
                              bottom: BorderSide(
                                color: Theme.of(context).dividerColor,
                              ),
                            ),
                          ),
                          gridData: FlGridData(
                            show: true,
                            drawHorizontalLine: true,
                            drawVerticalLine: false,
                            horizontalInterval: 1,
                            getDrawingHorizontalLine: (value) {
                              return FlLine(
                                color: Theme.of(
                                  context,
                                ).dividerColor.withOpacity(0.5),
                                strokeWidth: 1,
                              );
                            },
                          ),
                          barGroups:
                              weeklyPattern.entries
                                  .toList()
                                  .asMap()
                                  .entries
                                  .map((entry) {
                                    final index = entry.key;
                                    final value = entry.value.value;
                                    final isNotLaunched = value < 0;
                                    final displayValue =
                                        isNotLaunched ? 0.2 : value;

                                    return BarChartGroupData(
                                      x: index,
                                      barRods: [
                                        BarChartRodData(
                                          toY: displayValue,
                                          fromY: 0,
                                          gradient: LinearGradient(
                                            begin: Alignment.bottomCenter,
                                            end: Alignment.topCenter,
                                            colors:
                                                isNotLaunched
                                                    ? [
                                                      Theme.of(context)
                                                          .disabledColor
                                                          .withOpacity(0.3),
                                                      Theme.of(context)
                                                          .disabledColor
                                                          .withOpacity(0.5),
                                                    ]
                                                    : [
                                                      _getModernMoodColor(
                                                        _getMoodLevelFromValue(
                                                          value,
                                                        ),
                                                        context,
                                                      ),
                                                      _getModernMoodColor(
                                                        _getMoodLevelFromValue(
                                                          value,
                                                        ),
                                                        context,
                                                      ).withOpacity(0.7),
                                                    ],
                                          ),
                                          width: 32,
                                          borderRadius:
                                              const BorderRadius.vertical(
                                                top: Radius.circular(8),
                                              ),
                                          backDrawRodData:
                                              BackgroundBarChartRodData(
                                                show: true,
                                                toY: 5,
                                                color:
                                                    Theme.of(context)
                                                        .colorScheme
                                                        .surfaceVariant,
                                              ),
                                        ),
                                      ],
                                    );
                                  })
                                  .toList(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildDailySummary(),
                  ],
                );
              },
              loading:
                  () => Column(
                    children: [
                      SizedBox(
                        height: 220,
                        child: Center(
                          child: Icon(
                            Icons.bar_chart,
                            size: 64,
                            color: Colors.grey.shade300,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        height: 48,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ],
                  ),
              error:
                  (error, stack) => _buildErrorState('Erro ao carregar dados'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineChart(
    BuildContext context,
    AsyncValue<List<MoodEntry>> moodEntriesAsync,
  ) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).cardColor,
            Theme.of(context).colorScheme.primary.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.green.shade400, Colors.green.shade600],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.timeline, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    context.l10n.last30DaysData,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            moodEntriesAsync.when(
              data: (entries) {
                if (entries.isEmpty) {
                  return _buildEmptyState('Sem dados para exibir');
                }

                final thirtyDaysAgo = DateTime.now().subtract(
                  const Duration(days: 30),
                );
                final recentEntries =
                    entries
                        .where((entry) => entry.date.isAfter(thirtyDaysAgo))
                        .toList();

                if (recentEntries.isEmpty) {
                  return _buildEmptyState(context.l10n.noDataLast30Days);
                }

                // Ordenar por data
                recentEntries.sort((a, b) => a.date.compareTo(b.date));

                // Agrupar por dia e calcular média diária
                final Map<String, List<int>> dailyMoods = {};
                for (final entry in recentEntries) {
                  final dayKey =
                      '${entry.date.year}-${entry.date.month.toString().padLeft(2, '0')}-${entry.date.day.toString().padLeft(2, '0')}';
                  dailyMoods[dayKey] =
                      (dailyMoods[dayKey] ?? [])..add(entry.moodLevel);
                }

                // Calcular médias diárias e criar pontos para o gráfico
                final dailyAverages = <MapEntry<String, double>>[];
                dailyMoods.forEach((day, moods) {
                  final average = moods.reduce((a, b) => a + b) / moods.length;
                  dailyAverages.add(MapEntry(day, average));
                });

                // Ordenar por data
                dailyAverages.sort((a, b) => a.key.compareTo(b.key));

                final spots =
                    dailyAverages.asMap().entries.map((entry) {
                      return FlSpot(entry.key.toDouble(), entry.value.value);
                    }).toList();

                return Column(
                  children: [
                    SizedBox(
                      height: 240,
                      child: LineChart(
                        LineChartData(
                          gridData: FlGridData(
                            show: true,
                            drawHorizontalLine: true,
                            drawVerticalLine: false,
                            horizontalInterval: 1,
                            getDrawingHorizontalLine: (value) {
                              return FlLine(
                                color: Theme.of(
                                  context,
                                ).dividerColor.withOpacity(0.5),
                                strokeWidth: 1,
                              );
                            },
                          ),
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 40,
                                interval: 1,
                                getTitlesWidget: (value, meta) {
                                  // Mostrar valores de 0 a 5
                                  if (value == 0) {
                                    return Padding(
                                      padding: const EdgeInsets.only(
                                        right: 8.0,
                                      ),
                                      child: Text(
                                        '0',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface
                                              .withOpacity(0.6),
                                        ),
                                      ),
                                    );
                                  } else if (value >= 1 && value <= 5) {
                                    return Padding(
                                      padding: const EdgeInsets.only(
                                        right: 8.0,
                                      ),
                                      child: Text(
                                        '${value.toInt()}',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface
                                              .withOpacity(0.6),
                                        ),
                                      ),
                                    );
                                  }
                                  return const Text('');
                                },
                              ),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 30,
                                interval:
                                    (dailyAverages.length / 6).ceilToDouble(),
                                getTitlesWidget: (value, meta) {
                                  if (value.toInt() < dailyAverages.length) {
                                    final dayKey =
                                        dailyAverages[value.toInt()].key;
                                    final parts = dayKey.split('-');
                                    final day = parts[2];
                                    final month = parts[1];
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Text(
                                        '$day/$month',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface
                                              .withOpacity(0.6),
                                        ),
                                      ),
                                    );
                                  }
                                  return const Text('');
                                },
                              ),
                            ),
                            topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                          ),
                          borderData: FlBorderData(
                            show: true,
                            border: Border(
                              left: BorderSide(
                                color: Theme.of(context).dividerColor,
                              ),
                              bottom: BorderSide(
                                color: Theme.of(context).dividerColor,
                              ),
                            ),
                          ),
                          minX: 0,
                          maxX: (dailyAverages.length - 1).toDouble(),
                          minY: 0,
                          maxY: 5,
                          lineTouchData: LineTouchData(
                            enabled: true,
                            touchTooltipData: LineTouchTooltipData(
                              tooltipBgColor:
                                  Theme.of(context).colorScheme.inverseSurface,
                              tooltipRoundedRadius: 8,
                              getTooltipItems: (
                                List<LineBarSpot> touchedSpots,
                              ) {
                                return touchedSpots.map((
                                  LineBarSpot touchedSpot,
                                ) {
                                  final dayEntry =
                                      dailyAverages[touchedSpot.x.toInt()];
                                  final dayKey = dayEntry.key;
                                  final parts = dayKey.split('-');
                                  final day = parts[2];
                                  final month = parts[1];
                                  final avgValue = dayEntry.value;
                                  return LineTooltipItem(
                                    '$day/$month\nMédia: ${avgValue.toStringAsFixed(1)}',
                                    TextStyle(
                                      color:
                                          Theme.of(
                                            context,
                                          ).colorScheme.onInverseSurface,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  );
                                }).toList();
                              },
                            ),
                          ),
                          lineBarsData: [
                            LineChartBarData(
                              spots: spots,
                              isCurved: true,
                              color: Colors.green.shade600,
                              barWidth: 4,
                              isStrokeCapRound: true,
                              dotData: FlDotData(
                                show: true,
                                getDotPainter: (spot, percent, barData, index) {
                                  return FlDotCirclePainter(
                                    radius: 4,
                                    color: Colors.white,
                                    strokeWidth: 2,
                                    strokeColor: Colors.green.shade600,
                                  );
                                },
                              ),
                              belowBarData: BarAreaData(
                                show: true,
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.green.shade400.withOpacity(0.3),
                                    Colors.green.shade400.withOpacity(0.1),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildTimelineSummary(recentEntries, context),
                  ],
                );
              },
              loading:
                  () => Column(
                    children: [
                      SizedBox(
                        height: 240,
                        child: Center(
                          child: Icon(
                            Icons.timeline,
                            size: 64,
                            color: Colors.grey.shade300,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        height: 48,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ],
                  ),
              error:
                  (error, stack) => _buildErrorState('Erro ao carregar dados'),
            ),
          ],
        ),
      ),
    );
  }

  // Métodos auxiliares
  String _getMoodDescription(int moodLevel, AppLocalizations l10n) {
    switch (moodLevel) {
      case 1:
        return l10n.veryBad;
      case 2:
        return l10n.bad;
      case 3:
        return l10n.neutral;
      case 4:
        return l10n.good;
      case 5:
        return l10n.veryGood;
      default:
        return l10n.moodLevelUnknown;
    }
  }

  String _getMoodEmoji(int moodLevel) {
    switch (moodLevel) {
      case 1:
        return '😢';
      case 2:
        return '😕';
      case 3:
        return '😐';
      case 4:
        return '😊';
      case 5:
        return '😁';
      default:
        return '😐';
    }
  }

  String _getWeekdayName(int weekday, AppLocalizations l10n) {
    switch (weekday) {
      case 1:
        return l10n.monday;
      case 2:
        return l10n.tuesday;
      case 3:
        return l10n.wednesday;
      case 4:
        return l10n.thursday;
      case 5:
        return l10n.friday;
      case 6:
        return l10n.saturday;
      case 7:
        return l10n.sunday;
      default:
        return '';
    }
  }

  String _getAverageEmoji(double average) {
    if (average <= 1.5) return '😢';
    if (average <= 2.5) return '😕';
    if (average <= 3.5) return '😐';
    if (average <= 4.5) return '😊';
    return '😁';
  }

  Color _getAverageColor(BuildContext context, double average) {
    final moodLevel = _getMoodLevel(average);
    return AppTheme.getMoodColorFromContext(context, moodLevel);
  }

  int _getMoodLevel(double average) {
    if (average <= 1.5) return 1;
    if (average <= 2.5) return 2;
    if (average <= 3.5) return 3;
    if (average <= 4.5) return 4;
    return 5;
  }

  // Métodos auxiliares para os novos gráficos
  Color _getModernMoodColor(int moodLevel, BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    switch (moodLevel) {
      case 1:
        return isDark ? AppTheme.darkMoodVeryBad : AppTheme.lightMoodVeryBad;
      case 2:
        return isDark ? AppTheme.darkMoodBad : AppTheme.lightMoodBad;
      case 3:
        return isDark ? AppTheme.darkMoodNeutral : AppTheme.lightMoodNeutral;
      case 4:
        return isDark ? AppTheme.darkMoodGood : AppTheme.lightMoodGood;
      case 5:
        return isDark ? AppTheme.darkMoodVeryGood : AppTheme.lightMoodVeryGood;
      default:
        return Colors.grey;
    }
  }

  Widget _buildEmptyState(String message) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.insert_chart_outlined,
              size: 48,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red.shade400),
            const SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(color: Colors.red.shade600, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoodLegend(
    List<Map<String, dynamic>> countByLevel,
    int total,
    BuildContext context,
    AppLocalizations l10n,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.legend_toggle_rounded,
                color: AppTheme.primaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                l10n.moodDistributionLabel,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...countByLevel.map((item) {
            final moodLevel = item['mood_level'] as int;
            final count = item['count'] as int;
            final percentage = (count / total * 100);

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    _getModernMoodColor(moodLevel, context).withOpacity(0.08),
                    _getModernMoodColor(moodLevel, context).withOpacity(0.02),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _getModernMoodColor(
                    moodLevel,
                    context,
                  ).withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          _getModernMoodColor(moodLevel, context),
                          _getModernMoodColor(
                            moodLevel,
                            context,
                          ).withOpacity(0.8),
                        ],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: _getModernMoodColor(
                            moodLevel,
                            context,
                          ).withOpacity(0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _getMoodEmoji(moodLevel),
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _getMoodDescription(moodLevel, l10n),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                  Text(
                    '$count',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.6),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          _getModernMoodColor(moodLevel, context),
                          _getModernMoodColor(
                            moodLevel,
                            context,
                          ).withOpacity(0.8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: _getModernMoodColor(
                            moodLevel,
                            context,
                          ).withOpacity(0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      '${percentage.toStringAsFixed(1)}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  // Métodos auxiliares adicionais para os novos gráficos
  int _getMoodLevelFromValue(double value) {
    if (value <= 1.5) return 1;
    if (value <= 2.5) return 2;
    if (value <= 3.5) return 3;
    if (value <= 4.5) return 4;
    return 5;
  }

  Widget _buildDailySummary() {
    return Consumer(
      builder: (context, ref, child) {
        final moodEntriesAsync = ref.watch(moodEntriesProvider);

        return moodEntriesAsync.when(
          data: (entries) {
            if (entries.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200, width: 1),
                ),
                child: const Text(
                  'Registre seu humor para ver insights diários',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
              );
            }

            // Filtrar apenas entradas da semana atual (domingo até hoje)
            final now = DateTime.now();

            // Calcular o domingo desta semana
            int daysFromSunday = now.weekday == 7 ? 0 : now.weekday;
            final startOfWeek = now.subtract(Duration(days: daysFromSunday));

            final weekEntries =
                entries.where((entry) {
                  // Comparar apenas ano, mês e dia (ignorar hora)
                  final entryDate = DateTime(
                    entry.date.year,
                    entry.date.month,
                    entry.date.day,
                  );
                  final weekStart = DateTime(
                    startOfWeek.year,
                    startOfWeek.month,
                    startOfWeek.day,
                  );
                  final todayDate = DateTime(now.year, now.month, now.day);

                  return (entryDate.isAtSameMomentAs(weekStart) ||
                          entryDate.isAfter(weekStart)) &&
                      (entryDate.isAtSameMomentAs(todayDate) ||
                          entryDate.isBefore(todayDate));
                }).toList();

            if (weekEntries.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200, width: 1),
                ),
                child: const Text(
                  'Registre seu humor nesta semana para ver insights',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
              );
            }

            // Agrupar por dia e calcular médias diárias
            final Map<String, List<int>> dailyMoods = {};
            for (final entry in weekEntries) {
              final dayKey =
                  '${entry.date.year}-${entry.date.month.toString().padLeft(2, '0')}-${entry.date.day.toString().padLeft(2, '0')}';
              dailyMoods[dayKey] =
                  (dailyMoods[dayKey] ?? [])..add(entry.moodLevel);
            }

            // Calcular médias diárias
            final dailyAverages = <MapEntry<String, double>>[];
            dailyMoods.forEach((day, moods) {
              final average = moods.reduce((a, b) => a + b) / moods.length;
              dailyAverages.add(MapEntry(day, average));
            });

            if (dailyAverages.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200, width: 1),
                ),
                child: const Text(
                  'Registre seu humor para ver insights diários',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
              );
            }

            // Encontrar melhor e pior dia
            // Usar reduce ao invés de sort para maior clareza
            final bestDay = dailyAverages.reduce(
              (a, b) => a.value > b.value ? a : b,
            );
            final worstDay = dailyAverages.reduce(
              (a, b) => a.value < b.value ? a : b,
            );

            // Debug: imprimir dados para verificação
            print('=== DEBUG DAILY AVERAGES ===');
            print('Total de dias: ${dailyAverages.length}');
            for (final day in dailyAverages) {
              print('${day.key}: ${day.value.toStringAsFixed(2)}');
            }
            print(
              'Melhor calculado: ${bestDay.key} (${bestDay.value.toStringAsFixed(2)})',
            );
            print(
              'Pior calculado: ${worstDay.key} (${worstDay.value.toStringAsFixed(2)})',
            );
            print(
              'Diferença: ${(bestDay.value - worstDay.value).abs().toStringAsFixed(2)}',
            );
            print('São iguais? ${bestDay.key == worstDay.key}');

            // Vamos verificar manualmente qual é realmente o melhor e pior
            double maxValue = dailyAverages.first.value;
            double minValue = dailyAverages.first.value;
            String maxDay = dailyAverages.first.key;
            String minDay = dailyAverages.first.key;

            for (final day in dailyAverages) {
              if (day.value > maxValue) {
                maxValue = day.value;
                maxDay = day.key;
              }
              if (day.value < minValue) {
                minValue = day.value;
                minDay = day.key;
              }
            }

            print('Manual - Melhor: $maxDay ($maxValue)');
            print('Manual - Pior: $minDay ($minValue)');
            print('========================');

            // Se apenas um dia ou se melhor e pior são o mesmo dia, tratamento especial
            if (dailyAverages.length == 1 || bestDay.key == worstDay.key) {
              final day = dailyAverages.first;
              final parts = day.key.split('-');
              final dayMonth = '${parts[2]}/${parts[1]}';

              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade200, width: 1),
                ),
                child: Text(
                  dailyAverages.length == 1
                      ? 'Único dia registrado: $dayMonth (${day.value.toStringAsFixed(1)})'
                      : 'Todos os dias têm valores iguais: $dayMonth (${day.value.toStringAsFixed(1)})',
                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                ),
              );
            }

            // Se valores muito próximos, considerar similares
            if ((bestDay.value - worstDay.value).abs() < 0.5) {
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade200, width: 1),
                ),
                child: Text(
                  '${context.l10n.consistentMood}${(bestDay.value - worstDay.value).abs().toStringAsFixed(1)}',
                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                ),
              );
            }

            // Mostrar melhor e pior dia
            final bestParts = bestDay.key.split('-');
            final bestDate = DateTime(
              int.parse(bestParts[0]),
              int.parse(bestParts[1]),
              int.parse(bestParts[2]),
            );
            final bestDayName = _getWeekdayName(bestDate.weekday, context.l10n);

            final worstParts = worstDay.key.split('-');
            final worstDate = DateTime(
              int.parse(worstParts[0]),
              int.parse(worstParts[1]),
              int.parse(worstParts[2]),
            );
            final worstDayName = _getWeekdayName(
              worstDate.weekday,
              context.l10n,
            );

            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.trending_up,
                              color: Colors.green.shade600,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              context.l10n.bestDay,
                              style: TextStyle(
                                color: Colors.green.shade600,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '$bestDayName (${bestDay.value.toStringAsFixed(1)})',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 30,
                    color: Theme.of(context).dividerColor,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.trending_down,
                              color: Colors.red.shade600,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              context.l10n.hardestDay,
                              style: TextStyle(
                                color: Colors.red.shade600,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '$worstDayName (${worstDay.value.toStringAsFixed(1)})',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
          loading:
              () => Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200, width: 1),
                ),
                child: Row(
                  children: [
                    Icon(Icons.insights, color: Colors.grey.shade300, size: 32),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Container(height: 16, color: Colors.grey.shade200),
                    ),
                  ],
                ),
              ),
          error:
              (error, stack) => Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.shade200, width: 1),
                ),
                child: const Text(
                  'Erro ao carregar insights',
                  style: TextStyle(color: Colors.red, fontSize: 14),
                ),
              ),
        );
      },
    );
  }
}

Widget _buildTimelineSummary(List<MoodEntry> entries, BuildContext context) {
  // Agrupar por dia e calcular médias diárias (igual ao gráfico de evolução)
  final Map<String, List<int>> dailyMoods = {};
  for (final entry in entries) {
    final dayKey =
        '${entry.date.year}-${entry.date.month.toString().padLeft(2, '0')}-${entry.date.day.toString().padLeft(2, '0')}';
    dailyMoods[dayKey] = (dailyMoods[dayKey] ?? [])..add(entry.moodLevel);
  }

  // Calcular médias diárias
  final dailyAverages = <MapEntry<String, double>>[];
  dailyMoods.forEach((day, moods) {
    final average = moods.reduce((a, b) => a + b) / moods.length;
    dailyAverages.add(MapEntry(day, average));
  });

  if (dailyAverages.isEmpty) {
    return const SizedBox.shrink();
  }

  // Calcular média geral
  final overallAverage =
      dailyAverages.map((e) => e.value).reduce((a, b) => a + b) /
      dailyAverages.length;

  // Encontrar melhor e pior dia (por média diária)
  final bestDay = dailyAverages.reduce((a, b) => a.value > b.value ? a : b);
  final worstDay = dailyAverages.reduce((a, b) => a.value < b.value ? a : b);

  // Calcular tendência (primeira vs última média diária)
  dailyAverages.sort((a, b) => a.key.compareTo(b.key));
  final trend =
      dailyAverages.length >= 2
          ? dailyAverages.last.value - dailyAverages.first.value
          : 0.0;

  // Formatar datas para exibição
  final bestParts = bestDay.key.split('-');
  final bestDayMonth = '${bestParts[2]}/${bestParts[1]}';

  final worstParts = worstDay.key.split('-');
  final worstDayMonth = '${worstParts[2]}/${worstParts[1]}';

  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
        width: 1,
      ),
    ),
    child: Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildSummaryItem(
                context.l10n.overallAverage,
                '${overallAverage.toStringAsFixed(1)}/5',
                Icons.analytics,
                Colors.blue.shade600,
                context,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildSummaryItem(
                context.l10n.bestDay,
                '$bestDayMonth (${bestDay.value.toStringAsFixed(1)})',
                Icons.trending_up,
                Colors.green.shade600,
                context,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildSummaryItem(
                context.l10n.trend,
                trend > 0.3
                    ? context.l10n.improving
                    : trend < -0.3
                    ? context.l10n.declining
                    : context.l10n.stable,
                trend >= 0 ? Icons.trending_up : Icons.trending_down,
                trend >= 0 ? Colors.green.shade600 : Colors.red.shade600,
                context,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildSummaryItem(
                context.l10n.hardestDay,
                '$worstDayMonth (${worstDay.value.toStringAsFixed(1)})',
                Icons.trending_down,
                Colors.red.shade600,
                context,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

Widget _buildSummaryItem(
  String title,
  String value,
  IconData icon,
  Color color,
  BuildContext context,
) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 4),
          Text(
            title,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      Text(
        value,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    ],
  );
}
