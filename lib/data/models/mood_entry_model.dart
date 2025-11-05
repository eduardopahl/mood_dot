import '../../domain/entities/mood_entry.dart';

class MoodEntryModel extends MoodEntry {
  const MoodEntryModel({
    super.id,
    required super.date,
    required super.moodLevel,
    super.note,
    required super.createdAt,
  });

  // Conversões para o banco de dados
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'mood_level': moodLevel,
      'note': note,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory MoodEntryModel.fromMap(Map<String, dynamic> map) {
    return MoodEntryModel(
      id: map['id'],
      date: DateTime.parse(map['date']),
      moodLevel: map['mood_level'],
      note: map['note'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  factory MoodEntryModel.fromEntity(MoodEntry entity) {
    return MoodEntryModel(
      id: entity.id,
      date: entity.date,
      moodLevel: entity.moodLevel,
      note: entity.note,
      createdAt: entity.createdAt,
    );
  }

  MoodEntry toEntity() {
    return MoodEntry(
      id: id,
      date: date,
      moodLevel: moodLevel,
      note: note,
      createdAt: createdAt,
    );
  }
}
