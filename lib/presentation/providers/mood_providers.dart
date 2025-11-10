import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import '../../domain/entities/mood_entry.dart';
import '../../domain/repositories/mood_repository.dart';
import '../../data/repositories/mood_repository_impl.dart';
import '../../data/datasources/mood_local_datasource.dart';

final moodLocalDataSourceProvider = Provider<MoodLocalDataSource>((ref) {
  return MoodLocalDataSourceImpl.instance;
});

final moodRepositoryProvider = Provider<MoodRepository>((ref) {
  final localDataSource = ref.watch(moodLocalDataSourceProvider);
  return MoodRepositoryImpl(localDataSource: localDataSource);
});

final moodEntriesProvider = FutureProvider<List<MoodEntry>>((ref) async {
  final repository = ref.watch(moodRepositoryProvider);
  return await repository.getAllMoodEntries();
});

// Provider para home page com paginação - carrega apenas registros recentes
final recentMoodEntriesProvider = FutureProvider<List<MoodEntry>>((ref) async {
  final repository = ref.watch(moodRepositoryProvider);

  // Carrega apenas os últimos 30 dias inicialmente
  final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
  final now = DateTime.now();

  return await repository.getMoodEntriesByDateRange(thirtyDaysAgo, now);
});

final moodStatisticsProvider = FutureProvider<Map<String, dynamic>>((
  ref,
) async {
  final repository = ref.watch(moodRepositoryProvider);
  return await repository.getMoodStatistics();
});

// Provider para estatísticas avançadas
final advancedStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final repository = ref.watch(moodRepositoryProvider);
  final entries = await repository.getAllMoodEntries();

  if (entries.isEmpty) {
    return {
      'streak': 0,
      'weeklyPattern': <String, double>{},
      'hourlyPattern': <int, double>{},
      'monthlyTrend': <String, double>{},
      'insights': <String>[],
      'bestTimeOfDay': null,
      'mostCommonMood': null,
    };
  }

  // Calcular streak (dias consecutivos)
  final streak = _calculateStreak(entries);

  // Padrão semanal (por dia da semana)
  final weeklyPattern = _calculateWeeklyPattern(entries);

  // Padrão por hora do dia
  final hourlyPattern = _calculateHourlyPattern(entries);

  // Tendência mensal
  final monthlyTrend = _calculateMonthlyTrend(entries);

  // Melhor horário do dia
  final bestTimeOfDay = _getBestTimeOfDay(hourlyPattern);

  // Calcular variação do humor (desvio padrão)
  final variation = _calculateMoodVariation(entries);

  // Insights automáticos
  final insights = _generateInsights(weeklyPattern, hourlyPattern, entries);

  return {
    'streak': streak,
    'weeklyPattern': weeklyPattern,
    'hourlyPattern': hourlyPattern,
    'monthlyTrend': monthlyTrend,
    'insights': insights,
    'bestTimeOfDay': bestTimeOfDay,
    'variation': variation,
  };
});

// Funções auxiliares para cálculos estatísticos
int _calculateStreak(List<MoodEntry> entries) {
  if (entries.isEmpty) return 0;

  entries.sort((a, b) => b.date.compareTo(a.date));

  int streak = 1;
  DateTime lastDate = DateTime(
    entries.first.date.year,
    entries.first.date.month,
    entries.first.date.day,
  );

  for (int i = 1; i < entries.length; i++) {
    final currentDate = DateTime(
      entries[i].date.year,
      entries[i].date.month,
      entries[i].date.day,
    );

    final difference = lastDate.difference(currentDate).inDays;

    if (difference == 1) {
      streak++;
      lastDate = currentDate;
    } else {
      break;
    }
  }

  return streak;
}

Map<String, double> _calculateWeeklyPattern(List<MoodEntry> entries) {
  final weekdays = ['Dom', 'Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb'];

  // Filtrar apenas entradas da semana atual (domingo até hoje)
  final now = DateTime.now();
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

  final Map<int, List<int>> weekdayMoods = {};

  for (final entry in weekEntries) {
    final weekday = entry.date.weekday % 7; // 0 = domingo
    weekdayMoods[weekday] = (weekdayMoods[weekday] ?? [])..add(entry.moodLevel);
  }

  // Mostrar todos os 7 dias da semana
  final Map<String, double> result = {};
  final todayWeekday = now.weekday == 7 ? 0 : now.weekday;

  for (int i = 0; i < 7; i++) {
    final moods = weekdayMoods[i] ?? [];
    double average;

    if (i > todayWeekday) {
      // Dias futuros: mostrar como vazio (0.0)
      average = 0.0;
    } else {
      // Dias passados ou hoje: calcular média ou 0 se não houver dados
      average =
          moods.isEmpty ? 0.0 : moods.reduce((a, b) => a + b) / moods.length;
    }

    result[weekdays[i]] = average;
  }

  return result;
}

Map<int, double> _calculateHourlyPattern(List<MoodEntry> entries) {
  final Map<int, List<int>> hourlyMoods = {};

  for (final entry in entries) {
    final hour = entry.date.hour;
    hourlyMoods[hour] = (hourlyMoods[hour] ?? [])..add(entry.moodLevel);
  }

  final Map<int, double> result = {};
  for (int hour = 0; hour < 24; hour++) {
    final moods = hourlyMoods[hour] ?? [];
    final average =
        moods.isEmpty ? 0.0 : moods.reduce((a, b) => a + b) / moods.length;
    result[hour] = average;
  }

  return result;
}

Map<String, double> _calculateMonthlyTrend(List<MoodEntry> entries) {
  final Map<String, List<int>> monthlyMoods = {};

  for (final entry in entries) {
    final monthKey =
        '${entry.date.year}-${entry.date.month.toString().padLeft(2, '0')}';
    monthlyMoods[monthKey] =
        (monthlyMoods[monthKey] ?? [])..add(entry.moodLevel);
  }

  final Map<String, double> result = {};
  monthlyMoods.forEach((month, moods) {
    final average = moods.reduce((a, b) => a + b) / moods.length;
    result[month] = average;
  });

  return result;
}

String? _getBestTimeOfDay(Map<int, double> hourlyPattern) {
  if (hourlyPattern.isEmpty) return null;

  double maxValue = 0;
  int? bestHour;

  hourlyPattern.forEach((hour, average) {
    if (average > maxValue) {
      maxValue = average;
      bestHour = hour;
    }
  });

  if (bestHour == null) return null;

  if (bestHour! >= 5 && bestHour! < 12) return 'Manhã';
  if (bestHour! >= 12 && bestHour! < 18) return 'Tarde';
  if (bestHour! >= 18 && bestHour! < 22) return 'Noite';
  return 'Madrugada';
}

int? _getMostCommonMood(List<MoodEntry> entries) {
  if (entries.isEmpty) return null;

  final Map<int, int> moodCounts = {};
  for (final entry in entries) {
    moodCounts[entry.moodLevel] = (moodCounts[entry.moodLevel] ?? 0) + 1;
  }

  int mostCommon = 1;
  int maxCount = 0;

  moodCounts.forEach((mood, count) {
    if (count > maxCount) {
      maxCount = count;
      mostCommon = mood;
    }
  });

  return mostCommon;
}

List<String> _generateInsights(
  Map<String, double> weeklyPattern,
  Map<int, double> hourlyPattern,
  List<MoodEntry> entries,
) {
  final List<String> insights = [];

  // Insight sobre dia da semana
  if (weeklyPattern.isNotEmpty) {
    final bestDay = weeklyPattern.entries.reduce(
      (a, b) => a.value > b.value ? a : b,
    );
    final worstDay = weeklyPattern.entries.reduce(
      (a, b) => a.value < b.value ? a : b,
    );

    if (bestDay.value > 3.5) {
      insights.add(
        'Seu humor é melhor nas ${bestDay.key}s (${bestDay.value.toStringAsFixed(1)}/5)',
      );
    }

    if (worstDay.value < 2.5) {
      insights.add(
        '${worstDay.key}s tendem a ser dias mais difíceis para você',
      );
    }
  }

  // Insight sobre registros recentes
  if (entries.length >= 7) {
    final recentEntries = entries.take(7).toList();
    final recentAverage =
        recentEntries.map((e) => e.moodLevel).reduce((a, b) => a + b) /
        recentEntries.length;
    final overallAverage =
        entries.map((e) => e.moodLevel).reduce((a, b) => a + b) /
        entries.length;

    if (recentAverage > overallAverage + 0.5) {
      insights.add('Seu humor está melhorando! Últimos 7 dias acima da média');
    } else if (recentAverage < overallAverage - 0.5) {
      insights.add(
        'Considere atividades que te fazem bem - últimos dias abaixo da média',
      );
    }
  }

  // Insight sobre consistência
  final streak = _calculateStreak(entries);
  if (streak >= 7) {
    insights.add(
      'Parabéns! Você está registrando seu humor há $streak dias seguidos',
    );
  }

  return insights;
}

double _calculateMoodVariation(List<MoodEntry> entries) {
  if (entries.isEmpty) return 0.0;

  final moods = entries.map((e) => e.moodLevel).toList();
  final average = moods.reduce((a, b) => a + b) / moods.length;

  final variance =
      moods
          .map((mood) => (mood - average) * (mood - average))
          .reduce((a, b) => a + b) /
      moods.length;

  return variance; // Retorna a variância como medida de variação
}

class MoodEntryNotifier extends StateNotifier<AsyncValue<void>> {
  MoodEntryNotifier(this._repository) : super(const AsyncValue.data(null));

  final MoodRepository _repository;

  Future<void> addMoodEntry({
    required DateTime date,
    required int moodLevel,
    String? note,
  }) async {
    state = const AsyncValue.loading();

    try {
      final entry = MoodEntry(
        id: DateTime.now().millisecondsSinceEpoch,
        date: date,
        moodLevel: moodLevel,
        note: note,
        createdAt: DateTime.now(),
      );

      await _repository.addMoodEntry(entry);
      state = const AsyncValue.data(null);

      // 🧠 Sistema inteligente será notificado através do mecanismo de aprendizado
      debugPrint('🎭 Mood salvo - dados disponíveis para sistema inteligente');
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> updateMoodEntry(MoodEntry entry) async {
    state = const AsyncValue.loading();

    try {
      await _repository.updateMoodEntry(entry);
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> deleteMoodEntry(int id) async {
    state = const AsyncValue.loading();

    try {
      await _repository.deleteMoodEntry(id);
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

final moodEntryProvider =
    StateNotifierProvider<MoodEntryNotifier, AsyncValue<void>>((ref) {
      final repository = ref.watch(moodRepositoryProvider);
      return MoodEntryNotifier(repository);
    });

final moodEntriesByDateRangeProvider =
    FutureProvider.family<List<MoodEntry>, DateRange>((ref, dateRange) async {
      final repository = ref.watch(moodRepositoryProvider);
      return await repository.getMoodEntriesByDateRange(
        dateRange.start,
        dateRange.end,
      );
    });

class DateRange {
  final DateTime start;
  final DateTime end;

  DateRange({required this.start, required this.end});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DateRange && other.start == start && other.end == end;
  }

  @override
  int get hashCode => start.hashCode ^ end.hashCode;
}
