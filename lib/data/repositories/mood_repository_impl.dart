import '../../domain/entities/mood_entry.dart';
import '../../domain/repositories/mood_repository.dart';
import '../datasources/mood_local_datasource.dart';
import '../models/mood_entry_model.dart';

class MoodRepositoryImpl implements MoodRepository {
  final MoodLocalDataSource localDataSource;

  MoodRepositoryImpl({required this.localDataSource});

  @override
  Future<int> addMoodEntry(MoodEntry entry) async {
    final model = MoodEntryModel.fromEntity(entry);
    return await localDataSource.insertMoodEntry(model);
  }

  @override
  Future<List<MoodEntry>> getAllMoodEntries() async {
    final models = await localDataSource.getAllMoodEntries();
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<List<MoodEntry>> getMoodEntriesByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final models = await localDataSource.getMoodEntriesByDateRange(
      startDate,
      endDate,
    );
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<MoodEntry?> getMoodEntryByDate(DateTime date) async {
    final model = await localDataSource.getMoodEntryByDate(date);
    return model?.toEntity();
  }

  @override
  Future<int> updateMoodEntry(MoodEntry entry) async {
    final model = MoodEntryModel.fromEntity(entry);
    return await localDataSource.updateMoodEntry(model);
  }

  @override
  Future<int> deleteMoodEntry(int id) async {
    return await localDataSource.deleteMoodEntry(id);
  }

  @override
  Future<Map<String, dynamic>> getMoodStatistics() async {
    final stats = await localDataSource.getMoodStatistics();

    // Converter o lastEntry de model para entity se existir
    if (stats['lastEntry'] != null && stats['lastEntry'] is MoodEntryModel) {
      final model = stats['lastEntry'] as MoodEntryModel;
      stats['lastEntry'] = model.toEntity();
    }

    return stats;
  }
}
