import 'package:flutter/material.dart';

class MoodEntry {
  final int? id;
  final DateTime date;
  final int moodLevel; // 1-5 (1 = muito triste, 5 = muito feliz)
  final String? note;
  final DateTime createdAt;

  const MoodEntry({
    this.id,
    required this.date,
    required this.moodLevel,
    this.note,
    required this.createdAt,
  });

  // Getters para cores e emojis baseados no mood level
  Color get color {
    switch (moodLevel) {
      case 1:
        return const Color(0xFF8B0000); // Vermelho escuro
      case 2:
        return const Color(0xFFFF4500); // Laranja avermelhado
      case 3:
        return const Color(0xFFFFD700); // Amarelo
      case 4:
        return const Color(0xFF90EE90); // Verde claro
      case 5:
        return const Color(0xFF228B22); // Verde
      default:
        return Colors.grey;
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
        return 'Muito triste';
      case 2:
        return 'Triste';
      case 3:
        return 'Neutro';
      case 4:
        return 'Feliz';
      case 5:
        return 'Muito feliz';
      default:
        return 'Neutro';
    }
  }

  // Método copyWith para atualizações
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
