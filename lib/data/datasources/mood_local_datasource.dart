import 'package:hive_flutter/hive_flutter.dart';
import '../../domain/entities/mood_entry.dart';

abstract class MoodLocalDataSource {
  Future<int> insertMoodEntry(MoodEntry entry);
  Future<List<MoodEntry>> getAllMoodEntries();
  Future<List<MoodEntry>> getMoodEntriesByDateRange(
    DateTime startDate,
    DateTime endDate,
  );
  Future<MoodEntry?> getMoodEntryByDate(DateTime date);
  Future<void> updateMoodEntry(MoodEntry entry);
  Future<void> deleteMoodEntry(String key);
  Future<Map<String, dynamic>> getMoodStatistics();
  Future<void> clearAllData();
}

class MoodLocalDataSourceImpl implements MoodLocalDataSource {
  static const String _boxName = 'mood_entries';
  Box<MoodEntry>? _box;

  MoodLocalDataSourceImpl._privateConstructor();
  static final MoodLocalDataSourceImpl instance =
      MoodLocalDataSourceImpl._privateConstructor();

  Future<void> init() async {
    await Hive.initFlutter();

    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(MoodEntryAdapter());
    }

    _box = await Hive.openBox<MoodEntry>(_boxName);
  }

  Box<MoodEntry> get box {
    if (_box == null || !_box!.isOpen) {
      throw Exception('Hive box não foi inicializado. Chame init() primeiro.');
    }
    return _box!;
  }

  @override
  Future<int> insertMoodEntry(MoodEntry entry) async {
    final key = DateTime.now().millisecondsSinceEpoch.toString();
    await box.put(key, entry);

    return DateTime.now().millisecondsSinceEpoch;
  }

  @override
  Future<List<MoodEntry>> getAllMoodEntries() async {
    final entries = box.values.toList();

    entries.sort((a, b) => b.date.compareTo(a.date));

    return entries;
  }

  @override
  Future<List<MoodEntry>> getMoodEntriesByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final allEntries = await getAllMoodEntries();

    return allEntries.where((entry) {
      return entry.date.isAfter(startDate.subtract(const Duration(days: 1))) &&
          entry.date.isBefore(endDate.add(const Duration(days: 1)));
    }).toList();
  }

  @override
  Future<MoodEntry?> getMoodEntryByDate(DateTime date) async {
    final allEntries = await getAllMoodEntries();

    final targetDate = DateTime(date.year, date.month, date.day);

    for (final entry in allEntries) {
      final entryDate = DateTime(
        entry.date.year,
        entry.date.month,
        entry.date.day,
      );
      if (entryDate.isAtSameMomentAs(targetDate)) {
        return entry;
      }
    }

    return null;
  }

  @override
  Future<void> updateMoodEntry(MoodEntry entry) async {
    String? keyToUpdate;

    for (final key in box.keys) {
      final existingEntry = box.get(key);
      if (existingEntry?.id == entry.id) {
        keyToUpdate = key as String;
        break;
      }
    }

    if (keyToUpdate != null) {
      await box.put(keyToUpdate, entry);
    } else {
      await insertMoodEntry(entry);
    }
  }

  @override
  Future<void> deleteMoodEntry(String key) async {
    await box.delete(key);
  }

  Future<void> deleteMoodEntryById(int id) async {
    String? keyToDelete;

    for (final key in box.keys) {
      final entry = box.get(key);
      if (entry?.id == id) {
        keyToDelete = key as String;
        break;
      }
    }

    if (keyToDelete != null) {
      await deleteMoodEntry(keyToDelete);
    }
  }

  @override
  Future<Map<String, dynamic>> getMoodStatistics() async {
    final entries = await getAllMoodEntries();

    if (entries.isEmpty) {
      return {
        'average': 0.0,
        'countByLevel': <Map<String, dynamic>>[],
        'lastEntry': null,
        'totalEntries': 0,
      };
    }

    final totalMood = entries.fold<int>(
      0,
      (sum, entry) => sum + entry.moodLevel,
    );
    final average = totalMood / entries.length;

    final Map<int, int> countMap = {};
    for (final entry in entries) {
      countMap[entry.moodLevel] = (countMap[entry.moodLevel] ?? 0) + 1;
    }

    final countByLevel =
        countMap.entries
            .map(
              (e) => <String, dynamic>{'mood_level': e.key, 'count': e.value},
            )
            .toList();

    final lastEntry = entries.isNotEmpty ? entries.first : null;

    return {
      'average': average,
      'countByLevel': countByLevel,
      'lastEntry': lastEntry,
      'totalEntries': entries.length,
    };
  }

  @override
  Future<void> clearAllData() async {
    await box.clear();
  }

  Future<void> close() async {
    await _box?.close();
  }

  List<String> getAllKeys() {
    return box.keys.cast<String>().toList();
  }

  Map<String, MoodEntry> exportData() {
    final Map<String, MoodEntry> data = {};
    for (final key in box.keys) {
      final entry = box.get(key);
      if (entry != null) {
        data[key as String] = entry;
      }
    }
    return data;
  }

  Future<void> importData(Map<String, MoodEntry> data) async {
    await box.clear();
    await box.putAll(data);
  }
}
