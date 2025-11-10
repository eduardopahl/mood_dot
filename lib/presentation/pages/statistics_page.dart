import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/mood_providers.dart';
import '../../domain/entities/mood_entry.dart';
import '../theme/app_theme.dart';

enum StatisticsPeriod {
  week7Days('Últimos 7 dias'),
  month30Days('Últimos 30 dias'),
  month90Days('Últimos 90 dias'),
  allTime('Todo período');

  const StatisticsPeriod(this.label);
  final String label;
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
    // Usar o provider filtrado baseado no período selecionado
    final filteredStatsAsync = ref.watch(
      filteredStatisticsProvider(selectedPeriod.name),
    );
    final advancedStatsAsync = ref.watch(advancedStatsProvider);
    final moodEntriesAsync = ref.watch(moodEntriesProvider);

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
                  'Estatísticas',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // Seletor de período
                _buildPeriodSelector(ref),
                const SizedBox(height: 24),

                // Cards de métricas principais
                _buildMetricsCards(
                  context,
                  filteredStatsAsync,
                  advancedStatsAsync,
                ),

                const SizedBox(height: 24),

                // Gráfico de distribuição por humor
                _buildMoodDistribution(context, filteredStatsAsync),

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

  Widget _buildPeriodSelector(WidgetRef ref) {
    final selectedPeriod = ref.watch(selectedPeriodProvider);

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300, width: 1),
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
                              ? Colors.blue.shade600
                              : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      period.label,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.grey.shade700,
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
    return filteredStatsAsync.when(
      data:
          (stats) => advancedStatsAsync.when(
            data: (advancedStats) {
              final average = stats['average'] as double;
              final totalEntries = stats['totalEntries'] as int;
              final streak =
                  stats['streak'] as int; // Agora vem das stats filtradas
              final bestTimeOfDay = stats['bestTimeOfDay'] as String?;
              return Column(
                children: [
                  // Primeira linha de cards
                  Row(
                    children: [
                      Expanded(
                        child: _buildMetricCard(
                          context,
                          'Humor Médio',
                          '${average.toStringAsFixed(1)}/5',
                          _getAverageEmoji(average),
                          _getAverageColor(average),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildMetricCard(
                          context,
                          'Sequência',
                          '$streak dias',
                          '🔥',
                          streak >= 7
                              ? Colors.deepOrange.shade500
                              : Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Segunda linha de cards
                  Row(
                    children: [
                      Expanded(
                        child: _buildMetricCard(
                          context,
                          'Total Registros',
                          totalEntries.toString(),
                          '📊',
                          Colors.indigo.shade500,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildMetricCard(
                          context,
                          'Período Mais Ativo',
                          bestTimeOfDay ?? 'N/A',
                          '⭐',
                          Colors.amber.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Text('Erro: $error'),
          ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Text('Erro: $error'),
    );
  }

  Widget _buildMetricCard(
    BuildContext context,
    String title,
    String value,
    String emoji,
    Color color,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
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
              color: isDark ? Colors.grey[400] : Colors.grey[600],
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
              color: isDark ? Colors.white : Colors.grey[800],
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
    switch (title) {
      case 'Humor Médio':
        return Icons.sentiment_satisfied_rounded;
      case 'Sequência':
        return Icons.local_fire_department_rounded;
      case 'Total Registros':
        return Icons.analytics_rounded;
      case 'Período Mais Ativo':
        return Icons.access_time_rounded;
      default:
        return Icons.info_rounded;
    }
  }

  Widget _buildMoodDistribution(
    BuildContext context,
    AsyncValue<Map<String, dynamic>> filteredStatsAsync,
  ) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, Colors.purple.shade50],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
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
                      colors: [Colors.purple.shade400, Colors.purple.shade600],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.pie_chart,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Distribuição de Humores',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            filteredStatsAsync.when(
              data: (stats) {
                final countByLevel =
                    stats['countByLevel'] as List<Map<String, dynamic>>;

                if (countByLevel.isEmpty) {
                  return _buildEmptyState('Sem dados para exibir');
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
                    SizedBox(
                      height: 240,
                      child: Stack(
                        children: [
                          PieChart(
                            PieChartData(
                              sections:
                                  countByLevel.map((item) {
                                    final moodLevel = item['mood_level'] as int;
                                    final count = item['count'] as int;
                                    final percentage =
                                        (count / total * 100).round();

                                    return PieChartSectionData(
                                      value: count.toDouble(),
                                      title: '$percentage%',
                                      color: _getModernMoodColor(
                                        moodLevel,
                                        context,
                                      ),
                                      radius: 70,
                                      titleStyle: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                      borderSide: BorderSide(
                                        color: Colors.white,
                                        width: 3,
                                      ),
                                    );
                                  }).toList(),
                              centerSpaceRadius: 50,
                              sectionsSpace: 4,
                            ),
                          ),
                          Center(
                            child: Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 10,
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '$total',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.headlineSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey[800],
                                    ),
                                  ),
                                  Text(
                                    'registros',
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(color: Colors.grey[600]),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildMoodLegend(countByLevel, total, context),
                  ],
                );
              },
              loading: () => _buildLoadingState(),
              error:
                  (error, stack) => _buildErrorState('Erro ao carregar dados'),
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
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, Colors.blue.shade50],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
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
                      colors: [Colors.blue.shade400, Colors.blue.shade600],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.calendar_view_week,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Semana atual',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            advancedStatsAsync.when(
              data: (stats) {
                final weeklyPattern =
                    stats['weeklyPattern'] as Map<String, double>;

                if (weeklyPattern.isEmpty) {
                  return _buildEmptyState('Sem dados para exibir');
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
                              tooltipBgColor: Colors.black87,
                              tooltipRoundedRadius: 8,
                              getTooltipItem: (
                                group,
                                groupIndex,
                                rod,
                                rodIndex,
                              ) {
                                final day =
                                    weeklyPattern.keys.toList()[group.x
                                        .toInt()];
                                final originalValue =
                                    weeklyPattern.values.toList()[group.x
                                        .toInt()];
                                final displayText =
                                    originalValue < 0
                                        ? '$day\nNão lançado'
                                        : '$day\n${originalValue.toStringAsFixed(1)}';
                                return BarTooltipItem(
                                  displayText,
                                  const TextStyle(
                                    color: Colors.white,
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
                                  if (value.toInt() < days.length) {
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Text(
                                        days[value.toInt()],
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.grey[700],
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
                                          color: Colors.grey[600],
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
                              left: BorderSide(color: Colors.grey.shade300),
                              bottom: BorderSide(color: Colors.grey.shade300),
                            ),
                          ),
                          gridData: FlGridData(
                            show: true,
                            drawHorizontalLine: true,
                            drawVerticalLine: false,
                            horizontalInterval: 1,
                            getDrawingHorizontalLine: (value) {
                              return FlLine(
                                color: Colors.grey.shade200,
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
                                                      Colors.grey[300]!,
                                                      Colors.grey[400]!,
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
                                                color: Colors.grey.shade100,
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
              loading: () => _buildLoadingState(),
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
          colors: [Colors.white, Colors.green.shade50],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
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
                  child: const Icon(
                    Icons.timeline,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Últimos 30 dias',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
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
                  return _buildEmptyState('Sem dados dos últimos 30 dias');
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
                                color: Colors.grey.shade200,
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
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    );
                                  } else if (value >= 1 && value <= 5) {
                                    return Padding(
                                      padding: const EdgeInsets.only(
                                        right: 8.0,
                                      ),
                                      child: Text(
                                        '${_getMoodEmoji(value.toInt())} ${value.toInt()}',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey[600],
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
                                          color: Colors.grey[600],
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
                              left: BorderSide(color: Colors.grey.shade300),
                              bottom: BorderSide(color: Colors.grey.shade300),
                            ),
                          ),
                          minX: 0,
                          maxX: (dailyAverages.length - 1).toDouble(),
                          minY: 0,
                          maxY: 5,
                          lineTouchData: LineTouchData(
                            enabled: true,
                            touchTooltipData: LineTouchTooltipData(
                              tooltipBgColor: Colors.black87,
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
                                    '$day/$month\n${_getMoodEmoji(avgValue.round())} Média: ${avgValue.toStringAsFixed(1)}',
                                    const TextStyle(
                                      color: Colors.white,
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
                    _buildTimelineSummary(recentEntries),
                  ],
                );
              },
              loading: () => _buildLoadingState(),
              error:
                  (error, stack) => _buildErrorState('Erro ao carregar dados'),
            ),
          ],
        ),
      ),
    );
  }

  // Métodos auxiliares
  String _getMoodDescription(int moodLevel) {
    switch (moodLevel) {
      case 1:
        return 'Muito Triste';
      case 2:
        return 'Triste';
      case 3:
        return 'Neutro';
      case 4:
        return 'Feliz';
      case 5:
        return 'Muito Feliz';
      default:
        return 'Desconhecido';
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

  String _getAverageEmoji(double average) {
    if (average <= 1.5) return '😢';
    if (average <= 2.5) return '😕';
    if (average <= 3.5) return '😐';
    if (average <= 4.5) return '😊';
    return '😁';
  }

  Color _getAverageColor(double average) {
    if (average <= 1.5) return Colors.red.shade400;
    if (average <= 2.5) return Colors.orange.shade400;
    if (average <= 3.5) return Colors.amber.shade500;
    if (average <= 4.5) return Colors.lightGreen.shade500;
    return Colors.green.shade500;
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

  Widget _buildLoadingState() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Colors.purple.shade400,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Carregando dados...',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
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
  ) {
    return Column(
      children:
          countByLevel.map((item) {
            final moodLevel = item['mood_level'] as int;
            final count = item['count'] as int;
            final percentage = (count / total * 100);

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _getModernMoodColor(moodLevel, context).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _getModernMoodColor(
                    moodLevel,
                    context,
                  ).withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: _getModernMoodColor(moodLevel, context),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _getMoodEmoji(moodLevel),
                    style: const TextStyle(fontSize: 20),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _getMoodDescription(moodLevel),
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Text(
                    '$count registros',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getModernMoodColor(moodLevel, context),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${percentage.toStringAsFixed(1)}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
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
                  'Humor consistente nos últimos 30 dias. Variação: ${(bestDay.value - worstDay.value).abs().toStringAsFixed(1)}',
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
            final bestDayName =
                [
                  '',
                  'Segunda',
                  'Terça',
                  'Quarta',
                  'Quinta',
                  'Sexta',
                  'Sábado',
                  'Domingo',
                ][bestDate.weekday];

            final worstParts = worstDay.key.split('-');
            final worstDate = DateTime(
              int.parse(worstParts[0]),
              int.parse(worstParts[1]),
              int.parse(worstParts[2]),
            );
            final worstDayName =
                [
                  '',
                  'Segunda',
                  'Terça',
                  'Quarta',
                  'Quinta',
                  'Sexta',
                  'Sábado',
                  'Domingo',
                ][worstDate.weekday];

            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200, width: 1),
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
                              'Melhor dia',
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
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(width: 1, height: 30, color: Colors.blue.shade300),
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
                              'Dia mais difícil',
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
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
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
                child: const Text(
                  'Carregando insights...',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
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

Widget _buildTimelineSummary(List<MoodEntry> entries) {
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
      color: Colors.green.shade50,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.green.shade200, width: 1),
    ),
    child: Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildSummaryItem(
                'Média Geral',
                '${overallAverage.toStringAsFixed(1)}/5',
                Icons.analytics,
                Colors.blue.shade600,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildSummaryItem(
                'Melhor Dia',
                '$bestDayMonth (${bestDay.value.toStringAsFixed(1)})',
                Icons.trending_up,
                Colors.green.shade600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildSummaryItem(
                'Tendência',
                trend > 0.3
                    ? 'Melhorando'
                    : trend < -0.3
                    ? 'Declinando'
                    : 'Estável',
                trend >= 0 ? Icons.trending_up : Icons.trending_down,
                trend >= 0 ? Colors.green.shade600 : Colors.red.shade600,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildSummaryItem(
                'Dia Mais Difícil',
                '$worstDayMonth (${worstDay.value.toStringAsFixed(1)})',
                Icons.trending_down,
                Colors.red.shade600,
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
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
      ),
    ],
  );
}
