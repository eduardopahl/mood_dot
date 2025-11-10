import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../../presentation/theme/app_theme.dart';

part 'mood_entry.g.dart';

@HiveType(typeId: 0)
class MoodEntry {
  @HiveField(0)
  final int? id;

  @HiveField(1)
  final DateTime date;

  @HiveField(2)
  final int moodLevel;

  @HiveField(3)
  final String? note;

  @HiveField(4)
  final DateTime createdAt;

  const MoodEntry({
    this.id,
    required this.date,
    required this.moodLevel,
    this.note,
    required this.createdAt,
  });

  Color get color {
    switch (moodLevel) {
      case 1:
        return const Color(0xFF8B0000);
      case 2:
        return const Color(0xFFFF4500);
      case 3:
        return const Color(0xFFFFD700);
      case 4:
        return const Color(0xFF90EE90);
      case 5:
        return const Color(0xFF228B22);
      default:
        return Colors.grey;
    }
  }

  // Método para obter cor baseada no contexto (tema atual)
  Color getColorFromContext(BuildContext context) {
    return AppTheme.getMoodColorFromContext(context, moodLevel);
  }

  String get iconPath {
    switch (moodLevel) {
      case 1:
        return 'assets/images/moods/mood_1.png';
      case 2:
        return 'assets/images/moods/mood_2.png';
      case 3:
        return 'assets/images/moods/mood_3.png';
      case 4:
        return 'assets/images/moods/mood_4.png';
      case 5:
        return 'assets/images/moods/mood_5.png';
      default:
        return 'assets/images/moods/mood_3.png';
    }
  }

  String get emoji {
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

  String get moodDescription {
    switch (moodLevel) {
      case 1:
        return 'Muito ruim';
      case 2:
        return 'Ruim';
      case 3:
        return 'Neutro';
      case 4:
        return 'Bem';
      case 5:
        return 'Muito bem';
      default:
        return 'Neutro';
    }
  }

  MoodEntry copyWith({
    int? id,
    DateTime? date,
    int? moodLevel,
    String? note,
    DateTime? createdAt,
  }) {
    return MoodEntry(
      id: id ?? this.id,
      date: date ?? this.date,
      moodLevel: moodLevel ?? this.moodLevel,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MoodEntry &&
        other.id == id &&
        other.date == date &&
        other.moodLevel == moodLevel &&
        other.note == note &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        date.hashCode ^
        moodLevel.hashCode ^
        note.hashCode ^
        createdAt.hashCode;
  }

  @override
  String toString() {
    return 'MoodEntry(id: $id, date: $date, moodLevel: $moodLevel, note: $note, createdAt: $createdAt)';
  }
}
