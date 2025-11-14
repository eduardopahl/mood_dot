import 'package:flutter_test/flutter_test.dart';
import 'package:mooddot/domain/entities/mood_entry.dart';

void main() {
  test('MoodEntry getters return expected values for each mood level', () {
    final now = DateTime.now();

    final entry1 = MoodEntry(date: now, moodLevel: 1, createdAt: now);
    final entry2 = MoodEntry(date: now, moodLevel: 2, createdAt: now);
    final entry3 = MoodEntry(date: now, moodLevel: 3, createdAt: now);
    final entry4 = MoodEntry(date: now, moodLevel: 4, createdAt: now);
    final entry5 = MoodEntry(date: now, moodLevel: 5, createdAt: now);

    expect(entry1.emoji, '😢');
    expect(entry2.emoji, '😕');
    expect(entry3.emoji, '😐');
    expect(entry4.emoji, '😊');
    expect(entry5.emoji, '😁');

    expect(entry1.iconPath.endsWith('mood_1.png'), isTrue);
    expect(entry2.iconPath.endsWith('mood_2.png'), isTrue);
    expect(entry3.iconPath.endsWith('mood_3.png'), isTrue);
    expect(entry4.iconPath.endsWith('mood_4.png'), isTrue);
    expect(entry5.iconPath.endsWith('mood_5.png'), isTrue);

    expect(entry1.moodDescription.isNotEmpty, isTrue);
    expect(entry5.moodDescription.isNotEmpty, isTrue);

    // A cor deve ser diferente entre os tipos de humor
    expect(entry1.color, isNot(entry3.color));
    expect(entry5.color, isNot(entry2.color));
  });
}
