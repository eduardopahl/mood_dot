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
