import '../entities/mood_entry.dart';

abstract class MoodRepository {
  Future<int> addMoodEntry(MoodEntry entry);
  Future<List<MoodEntry>> getAllMoodEntries();
  Future<List<MoodEntry>> getMoodEntriesByDateRange(
    DateTime startDate,
    DateTime endDate,
  );
  Future<MoodEntry?> getMoodEntryByDate(DateTime date);
  Future<int> updateMoodEntry(MoodEntry entry);
  Future<int> deleteMoodEntry(int id);
  Future<Map<String, dynamic>> getMoodStatistics();
}
