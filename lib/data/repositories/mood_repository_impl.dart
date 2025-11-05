import '../../domain/entities/mood_entry.dart';
import '../../domain/repositories/mood_repository.dart';
import '../datasources/mood_local_datasource.dart';

class MoodRepositoryImpl implements MoodRepository {
  final MoodLocalDataSource localDataSource;

  MoodRepositoryImpl({required this.localDataSource});

  @override
  Future<int> addMoodEntry(MoodEntry entry) async {
    return await localDataSource.insertMoodEntry(entry);
  }

  @override
  Future<List<MoodEntry>> getAllMoodEntries() async {
    return await localDataSource.getAllMoodEntries();
  }

  @override
  Future<List<MoodEntry>> getMoodEntriesByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    return await localDataSource.getMoodEntriesByDateRange(startDate, endDate);
  }

  @override
  Future<MoodEntry?> getMoodEntryByDate(DateTime date) async {
    return await localDataSource.getMoodEntryByDate(date);
  }

  @override
  Future<int> updateMoodEntry(MoodEntry entry) async {
    await localDataSource.updateMoodEntry(entry);
    return 1;
  }

  @override
  Future<int> deleteMoodEntry(int id) async {
    if (localDataSource is MoodLocalDataSourceImpl) {
      await (localDataSource as MoodLocalDataSourceImpl).deleteMoodEntryById(
        id,
      );
    }
    return 1;
  }

  @override
  Future<Map<String, dynamic>> getMoodStatistics() async {
    return await localDataSource.getMoodStatistics();
  }
}
