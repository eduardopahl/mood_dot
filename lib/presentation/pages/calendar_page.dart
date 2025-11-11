import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/mood_providers.dart';
import '../theme/app_theme.dart';

// Provider para o mês/ano selecionado no calendário
final selectedCalendarDateProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, 1); // Primeiro dia do mês atual
});

// Provider para dados do calendário por mês
final calendarDataProvider = FutureProvider.family<Map<int, double>, DateTime>((
  ref,
  monthDate,
) async {
  final entries = await ref.watch(moodEntriesProvider.future);

  // Filtrar entradas do mês selecionado
  final monthEntries =
      entries.where((entry) {
        return entry.date.year == monthDate.year &&
            entry.date.month == monthDate.month;
      }).toList();

  // Agrupar por dia e calcular médias
  final Map<int, List<int>> dailyMoods = {};
  for (final entry in monthEntries) {
    final day = entry.date.day;
    dailyMoods[day] = (dailyMoods[day] ?? [])..add(entry.moodLevel);
  }

  // Calcular médias por dia
  final Map<int, double> dailyAverages = {};
  dailyMoods.forEach((day, moods) {
    dailyAverages[day] = moods.reduce((a, b) => a + b) / moods.length;
  });

  return dailyAverages;
});

class CalendarPage extends ConsumerWidget {
  const CalendarPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedCalendarDateProvider);
    final calendarDataAsync = ref.watch(calendarDataProvider(selectedDate));

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header com navegação
            _buildCalendarHeader(context, ref, selectedDate),

            // Calendário
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardTheme.color,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).shadowColor.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Dias da semana
                    _buildWeekdaysHeader(context),

                    // Grid do calendário
                    Expanded(
                      child: calendarDataAsync.when(
                        data:
                            (dailyAverages) => _buildCalendarGrid(
                              context,
                              selectedDate,
                              dailyAverages,
                            ),
                        loading:
                            () => const Center(
                              child: CircularProgressIndicator(),
                            ),
                        error:
                            (error, stack) => Center(
                              child: Text('Erro ao carregar dados: $error'),
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarHeader(
    BuildContext context,
    WidgetRef ref,
    DateTime selectedDate,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          // Botão mês anterior
          IconButton(
            onPressed: () {
              final prevMonth = DateTime(
                selectedDate.year,
                selectedDate.month - 1,
                1,
              );
              ref.read(selectedCalendarDateProvider.notifier).state = prevMonth;
            },
            icon: const Icon(Icons.chevron_left, size: 28),
            style: IconButton.styleFrom(
              backgroundColor: Theme.of(context).cardTheme.color,
              foregroundColor: Theme.of(context).colorScheme.onSurface,
              elevation: 2,
              shadowColor: Theme.of(context).shadowColor.withOpacity(0.1),
            ),
          ),

          // Título do mês/ano
          Expanded(
            child: Center(
              child: Column(
                children: [
                  Text(
                    DateFormat('MMMM', 'pt_BR').format(selectedDate),
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    selectedDate.year.toString(),
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Botão próximo mês (apenas se não for futuro)
          IconButton(
            onPressed: () {
              final nextMonth = DateTime(
                selectedDate.year,
                selectedDate.month + 1,
                1,
              );
              final now = DateTime.now();
              final currentMonth = DateTime(now.year, now.month, 1);

              // Só permite navegar até o mês atual
              if (nextMonth.isBefore(currentMonth) ||
                  nextMonth.isAtSameMomentAs(currentMonth)) {
                ref.read(selectedCalendarDateProvider.notifier).state =
                    nextMonth;
              }
            },
            icon: const Icon(Icons.chevron_right, size: 28),
            style: IconButton.styleFrom(
              backgroundColor: Theme.of(context).cardTheme.color,
              foregroundColor: Theme.of(context).colorScheme.onSurface,
              elevation: 2,
              shadowColor: Theme.of(context).shadowColor.withOpacity(0.1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekdaysHeader(BuildContext context) {
    const weekdays = ['Dom', 'Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb'];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      child: Row(
        children:
            weekdays.map((day) {
              return Expanded(
                child: Center(
                  child: Text(
                    day,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }

  Widget _buildCalendarGrid(
    BuildContext context,
    DateTime selectedDate,
    Map<int, double> dailyAverages,
  ) {
    final firstDayOfMonth = DateTime(selectedDate.year, selectedDate.month, 1);
    final lastDayOfMonth = DateTime(
      selectedDate.year,
      selectedDate.month + 1,
      0,
    );
    final firstWeekday = firstDayOfMonth.weekday % 7; // 0 = domingo
    final daysInMonth = lastDayOfMonth.day;

    // Total de células (pode incluir dias vazios no início)
    final totalCells = ((daysInMonth + firstWeekday - 1) / 7).ceil() * 7;

    return Flexible(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            childAspectRatio: 1,
            crossAxisSpacing: 2,
            mainAxisSpacing: 2,
          ),
          itemCount: totalCells,
          itemBuilder: (context, index) {
            final dayNumber = index - firstWeekday + 1;

            // Células vazias no início do mês
            if (dayNumber <= 0 || dayNumber > daysInMonth) {
              return Container();
            }

            final dayAverage = dailyAverages[dayNumber];
            final hasData = dayAverage != null;

            return _buildDayCell(
              context,
              dayNumber,
              dayAverage,
              hasData,
              selectedDate,
            );
          },
        ),
      ),
    );
  }

  Widget _buildDayCell(
    BuildContext context,
    int day,
    double? average,
    bool hasData,
    DateTime monthDate,
  ) {
    final isToday = _isToday(day, monthDate);
    final isFuture = _isFuture(day, monthDate);

    return Container(
      decoration: BoxDecoration(
        color: _getDayCellColor(context, average, hasData, isToday, isFuture),
        borderRadius: BorderRadius.circular(8),
        border:
            isToday
                ? Border.all(
                  color: Theme.of(context).colorScheme.primary,
                  width: 2,
                )
                : Border.all(color: Theme.of(context).dividerColor, width: 1),
        boxShadow:
            hasData
                ? [
                  BoxShadow(
                    color: _getMoodColor(context, average!).withOpacity(0.3),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ]
                : null,
      ),
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Número do dia
            Flexible(
              child: Center(
                child: FittedBox(
                  child: Text(
                    day.toString(),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isToday ? FontWeight.bold : FontWeight.w600,
                      color: _getDayTextColor(
                        context,
                        average,
                        hasData,
                        isToday,
                        isFuture,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Indicador de humor (valor numérico)
            if (hasData && !isFuture) ...[
              Flexible(
                child: Center(
                  child: FittedBox(
                    child: Text(
                      average!.toStringAsFixed(1),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: _getContrastingTextColor(
                          _getMoodColor(context, average),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],

            if (!hasData && !isFuture) ...[
              Flexible(
                child: Center(
                  child: Icon(
                    Icons.remove,
                    size: 10,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.4),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Métodos auxiliares
  bool _isToday(int day, DateTime monthDate) {
    final now = DateTime.now();
    return now.day == day &&
        now.month == monthDate.month &&
        now.year == monthDate.year;
  }

  bool _isFuture(int day, DateTime monthDate) {
    final dayDate = DateTime(monthDate.year, monthDate.month, day);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return dayDate.isAfter(today);
  }

  Color _getDayCellColor(
    BuildContext context,
    double? average,
    bool hasData,
    bool isToday,
    bool isFuture,
  ) {
    if (isFuture) return Theme.of(context).colorScheme.surface.withOpacity(0.5);
    if (!hasData) return Theme.of(context).colorScheme.surface.withOpacity(0.8);
    return _getMoodColor(context, average!);
  }

  Color _getDayTextColor(
    BuildContext context,
    double? average,
    bool hasData,
    bool isToday,
    bool isFuture,
  ) {
    if (isFuture)
      return Theme.of(context).colorScheme.onSurface.withOpacity(0.4);
    if (!hasData)
      return Theme.of(context).colorScheme.onSurface.withOpacity(0.7);

    // Para dias com dados, usar cor com bom contraste baseada no fundo
    if (hasData && average != null) {
      final backgroundColor = _getMoodColor(context, average);
      return _getContrastingTextColor(backgroundColor);
    }

    return Theme.of(context).colorScheme.onSurface;
  }

  // Função para calcular cor do texto com bom contraste
  Color _getContrastingTextColor(Color backgroundColor) {
    // Calcula a luminância da cor de fundo
    final luminance = backgroundColor.computeLuminance();

    // Se a cor de fundo for escura, usa texto branco
    // Se for clara, usa texto escuro
    return luminance < 0.5 ? Colors.white : Colors.black;
  }

  Color _getMoodColor(BuildContext context, double average) {
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
}
