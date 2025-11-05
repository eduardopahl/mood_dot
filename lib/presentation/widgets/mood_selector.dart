import 'package:flutter/material.dart';
import '../../domain/entities/mood_entry.dart';

class MoodSelector extends StatelessWidget {
  final int selectedMoodLevel;
  final Function(int) onMoodSelected;

  const MoodSelector({
    super.key,
    required this.selectedMoodLevel,
    required this.onMoodSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Indicadores visuais dos humores
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(5, (index) {
            final moodLevel = index + 1;
            final isSelected = moodLevel == selectedMoodLevel;
            final tempEntry = MoodEntry(
              date: DateTime.now(),
              moodLevel: moodLevel,
              createdAt: DateTime.now(),
            );

            return GestureDetector(
              onTap: () => onMoodSelected(moodLevel),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: isSelected ? 70 : 60,
                height: isSelected ? 70 : 60,
                decoration: BoxDecoration(
                  color:
                      isSelected
                          ? tempEntry.color.withOpacity(0.2)
                          : Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? tempEntry.color : Colors.grey.shade300,
                    width: isSelected ? 3 : 1,
                  ),
                ),
                child: Center(
                  child: Text(
                    tempEntry.emoji,
                    style: TextStyle(fontSize: isSelected ? 36 : 30),
                  ),
                ),
              ),
            );
          }),
        ),

        const SizedBox(height: 16),

        // Slider para seleção mais precisa
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: _getMoodColor(selectedMoodLevel),
            thumbColor: _getMoodColor(selectedMoodLevel),
            inactiveTrackColor: Colors.grey.shade300,
            overlayColor: _getMoodColor(selectedMoodLevel).withOpacity(0.1),
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
            trackHeight: 6,
          ),
          child: Slider(
            value: selectedMoodLevel.toDouble(),
            min: 1,
            max: 5,
            divisions: 4,
            onChanged: (value) => onMoodSelected(value.round()),
          ),
        ),

        const SizedBox(height: 12),

        // Texto descritivo do humor selecionado
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Container(
            key: ValueKey(selectedMoodLevel),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: _getMoodColor(selectedMoodLevel).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _getMoodColor(selectedMoodLevel).withOpacity(0.3),
              ),
            ),
            child: Text(
              _getMoodDescription(selectedMoodLevel),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: _getMoodColor(selectedMoodLevel),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Labels dos extremos
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Muito triste',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
            ),
            Text(
              'Muito feliz',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
            ),
          ],
        ),
      ],
    );
  }

  Color _getMoodColor(int moodLevel) {
    final tempEntry = MoodEntry(
      date: DateTime.now(),
      moodLevel: moodLevel,
      createdAt: DateTime.now(),
    );
    return tempEntry.color;
  }

  String _getMoodDescription(int moodLevel) {
    final tempEntry = MoodEntry(
      date: DateTime.now(),
      moodLevel: moodLevel,
      createdAt: DateTime.now(),
    );
    return tempEntry.moodDescription;
  }
}
