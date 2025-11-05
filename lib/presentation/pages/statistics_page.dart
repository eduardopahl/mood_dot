import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../providers/mood_providers.dart';
import '../../domain/entities/mood_entry.dart';

class StatisticsPage extends ConsumerWidget {
  const StatisticsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statisticsAsync = ref.watch(moodStatisticsProvider);
    final moodEntriesAsync = ref.watch(moodEntriesProvider);

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(moodStatisticsProvider);
            ref.invalidate(moodEntriesProvider);
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Text(
                      'Estatísticas',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.refresh),
                        onPressed: () async {
                          ref.invalidate(moodStatisticsProvider);
                          ref.invalidate(moodEntriesProvider);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Resumo geral
                _buildGeneralStats(context, statisticsAsync),

                const SizedBox(height: 24),

                // Gráfico de distribuição por humor
                _buildMoodDistribution(context, statisticsAsync),

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

  Widget _buildGeneralStats(
    BuildContext context,
    AsyncValue<Map<String, dynamic>> statisticsAsync,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Resumo Geral', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            statisticsAsync.when(
              data: (stats) {
                final average = stats['average'] as double;
                final totalEntries = stats['totalEntries'] as int;
                final lastEntry = stats['lastEntry'] as MoodEntry?;

                return Column(
                  children: [
                    _buildStatItem(
                      context,
                      'Humor Médio',
                      '${average.toStringAsFixed(1)}/5.0',
                      _getAverageEmoji(average),
                      _getAverageColor(average),
                    ),
                    const Divider(),
                    _buildStatItem(
                      context,
                      'Total de Registros',
                      totalEntries.toString(),
                      '📊',
                      Colors.blue,
                    ),
                    if (lastEntry != null) ...[
                      const Divider(),
                      _buildStatItem(
                        context,
                        'Último Registro',
                        '${lastEntry.moodDescription} • ${DateFormat('dd/MM HH:mm').format(lastEntry.createdAt)}',
                        lastEntry.emoji,
                        lastEntry.color,
                      ),
                    ],
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Text('Erro: $error'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String title,
    String value,
    String emoji,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(emoji, style: const TextStyle(fontSize: 20)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.bodyMedium),
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoodDistribution(
    BuildContext context,
    AsyncValue<Map<String, dynamic>> statisticsAsync,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Distribuição de Humores',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            statisticsAsync.when(
              data: (stats) {
                final countByLevel =
                    stats['countByLevel'] as List<Map<String, dynamic>>;

                if (countByLevel.isEmpty) {
                  return const Center(child: Text('Sem dados para exibir'));
                }

                return SizedBox(
                  height: 200,
                  child: PieChart(
                    PieChartData(
                      sections:
                          countByLevel.map((item) {
                            final moodLevel = item['mood_level'] as int;
                            final count = item['count'] as int;
                            final tempEntry = MoodEntry(
                              date: DateTime.now(),
                              moodLevel: moodLevel,
                              createdAt: DateTime.now(),
                            );

                            return PieChartSectionData(
                              value: count.toDouble(),
                              title: '${tempEntry.emoji}\n$count',
                              color: tempEntry.color,
                              radius: 60,
                              titleStyle: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            );
                          }).toList(),
                      centerSpaceRadius: 40,
                      sectionsSpace: 2,
                    ),
                  ),
                );
              },
              loading:
                  () => const SizedBox(
                    height: 200,
                    child: Center(child: CircularProgressIndicator()),
                  ),
              error:
                  (error, stack) => SizedBox(
                    height: 200,
                    child: Center(child: Text('Erro: $error')),
                  ),
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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Evolução do Humor (Últimos 30 dias)',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            moodEntriesAsync.when(
              data: (entries) {
                if (entries.isEmpty) {
                  return const SizedBox(
                    height: 200,
                    child: Center(child: Text('Sem dados para exibir')),
                  );
                }

                // Filtrar últimos 30 dias
                final thirtyDaysAgo = DateTime.now().subtract(
                  const Duration(days: 30),
                );
                final recentEntries =
                    entries
                        .where((entry) => entry.date.isAfter(thirtyDaysAgo))
                        .toList();

                if (recentEntries.isEmpty) {
                  return const SizedBox(
                    height: 200,
                    child: Center(child: Text('Sem dados dos últimos 30 dias')),
                  );
                }

                // Preparar dados para o gráfico
                final spots =
                    recentEntries.asMap().entries.map((entry) {
                      return FlSpot(
                        entry.key.toDouble(),
                        entry.value.moodLevel.toDouble(),
                      );
                    }).toList();

                return SizedBox(
                  height: 200,
                  child: LineChart(
                    LineChartData(
                      gridData: const FlGridData(show: true),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                value.toInt().toString(),
                                style: const TextStyle(fontSize: 12),
                              );
                            },
                          ),
                        ),
                        bottomTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      borderData: FlBorderData(show: true),
                      minX: 0,
                      maxX: (recentEntries.length - 1).toDouble(),
                      minY: 1,
                      maxY: 5,
                      lineBarsData: [
                        LineChartBarData(
                          spots: spots,
                          isCurved: true,
                          color: Theme.of(context).primaryColor,
                          barWidth: 3,
                          dotData: const FlDotData(show: true),
                          belowBarData: BarAreaData(
                            show: true,
                            color: Theme.of(
                              context,
                            ).primaryColor.withOpacity(0.1),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
              loading:
                  () => const SizedBox(
                    height: 200,
                    child: Center(child: CircularProgressIndicator()),
                  ),
              error:
                  (error, stack) => SizedBox(
                    height: 200,
                    child: Center(child: Text('Erro: $error')),
                  ),
            ),
          ],
        ),
      ),
    );
  }

  String _getAverageEmoji(double average) {
    if (average <= 1.5) return '😢';
    if (average <= 2.5) return '😕';
    if (average <= 3.5) return '😐';
    if (average <= 4.5) return '😊';
    return '😁';
  }

  Color _getAverageColor(double average) {
    if (average <= 1.5) return const Color(0xFF8B0000);
    if (average <= 2.5) return const Color(0xFFFF4500);
    if (average <= 3.5) return const Color(0xFFFFD700);
    if (average <= 4.5) return const Color(0xFF90EE90);
    return const Color(0xFF228B22);
  }
}
