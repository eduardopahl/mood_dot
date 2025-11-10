import 'package:flutter/material.dart';
import '../../domain/entities/mood_entry.dart';
import '../theme/app_theme.dart';

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
        // Indicadores visuais dos humores - container fixo com animações internas
        SizedBox(
          height: 80, // Altura fixa para evitar movimento da tela
          child: Row(
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
                child: SizedBox(
                  width: 70, // Container fixo para não afetar outros elementos
                  height: 70,
                  child: Center(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeInOut,
                      width:
                          isSelected
                              ? 65
                              : 55, // Animação dentro do espaço fixo
                      height: isSelected ? 65 : 55,
                      decoration: BoxDecoration(
                        color:
                            isSelected
                                ? tempEntry.color.withOpacity(0.2)
                                : Colors.transparent,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color:
                              isSelected
                                  ? tempEntry.color
                                  : Colors.grey.shade300,
                          width: isSelected ? 3 : 1,
                        ),
                        boxShadow:
                            isSelected
                                ? [
                                  BoxShadow(
                                    color: tempEntry.color.withOpacity(0.3),
                                    blurRadius: 8,
                                    spreadRadius: 1,
                                  ),
                                ]
                                : null,
                      ),
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: Center(
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                curve: Curves.easeInOut,
                                width: isSelected ? 58 : 48,
                                height: isSelected ? 58 : 48,
                                child: Image.asset(
                                  tempEntry.iconPath,
                                  fit: BoxFit.contain,
                                  errorBuilder:
                                      (context, error, stackTrace) => Center(
                                        child: AnimatedDefaultTextStyle(
                                          duration: const Duration(
                                            milliseconds: 200,
                                          ),
                                          style: TextStyle(
                                            fontSize: isSelected ? 50 : 42,
                                          ),
                                          child: Text(tempEntry.emoji),
                                        ),
                                      ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),

        const SizedBox(height: 16),

        // Slider para seleção mais precisa
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: AppTheme.getMoodColorFromContext(
              context,
              selectedMoodLevel,
            ),
            thumbColor: AppTheme.getMoodColorFromContext(
              context,
              selectedMoodLevel,
            ),
            inactiveTrackColor: Colors.grey.shade300,
            overlayColor: AppTheme.getMoodColorFromContext(
              context,
              selectedMoodLevel,
            ).withOpacity(0.1),
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

        // Texto descritivo do humor selecionado com altura fixa e animação suave
        SizedBox(
          height: 50, // Altura fixa para evitar movimento
          child: Center(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.0, 0.3),
                      end: Offset.zero,
                    ).animate(
                      CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeInOut,
                      ),
                    ),
                    child: child,
                  ),
                );
              },
              child: Container(
                key: ValueKey(selectedMoodLevel),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.getMoodColorFromContext(
                    context,
                    selectedMoodLevel,
                  ).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppTheme.getMoodColorFromContext(
                      context,
                      selectedMoodLevel,
                    ).withOpacity(0.3),
                  ),
                ),
                child: Text(
                  _getMoodDescription(selectedMoodLevel),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppTheme.getMoodColorFromContext(
                      context,
                      selectedMoodLevel,
                    ),
                    fontWeight: FontWeight.w600,
                  ),
                ),
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
              'Muito ruim',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
            ),
            Text(
              'Muito bem',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
            ),
          ],
        ),
      ],
    );
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
