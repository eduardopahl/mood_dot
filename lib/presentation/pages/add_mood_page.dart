import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/mood_entry.dart';
import '../providers/mood_providers.dart';
import '../widgets/mood_selector.dart';
import '../widgets/app_snackbar.dart';

class AddMoodPage extends ConsumerStatefulWidget {
  final MoodEntry? existingEntry;

  const AddMoodPage({super.key, this.existingEntry});

  @override
  ConsumerState<AddMoodPage> createState() => _AddMoodPageState();
}

class _AddMoodPageState extends ConsumerState<AddMoodPage> {
  late DateTime selectedDate;
  int selectedMoodLevel = 3;
  final TextEditingController noteController = TextEditingController();
  final FocusNode noteFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    if (widget.existingEntry != null) {
      selectedDate = widget.existingEntry!.date;
      selectedMoodLevel = widget.existingEntry!.moodLevel;
      noteController.text = widget.existingEntry!.note ?? '';
    } else {
      selectedDate = DateTime.now();
    }
  }

  @override
  void dispose() {
    noteController.dispose();
    noteFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final moodNotifier = ref.watch(moodEntryProvider);
    final isEditing = widget.existingEntry != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Humor' : 'Como você está?'),
        actions: [
          TextButton(
            onPressed: moodNotifier.isLoading ? null : _saveMoodEntry,
            child: Text(
              isEditing ? 'Atualizar' : 'Salvar',
              style: TextStyle(
                color:
                    moodNotifier.isLoading
                        ? Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.4)
                        : Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),

      body:
          moodNotifier.isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Informações do registro existente (se editando)
                    if (isEditing && widget.existingEntry != null) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Theme.of(
                              context,
                            ).colorScheme.primary.withOpacity(0.3),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Editando registro',
                              style: Theme.of(
                                context,
                              ).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color:
                                    Theme.of(
                                      context,
                                    ).colorScheme.onPrimaryContainer,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Criado em ${DateFormat('dd/MM/yyyy \'às\' HH:mm').format(widget.existingEntry!.createdAt)}',
                              style: Theme.of(
                                context,
                              ).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onPrimaryContainer
                                    .withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Seleção de data
                    _buildDateSelector(),

                    const SizedBox(height: 32),

                    // Seletor de humor
                    Text(
                      'Como você está se sentindo?',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),

                    const SizedBox(height: 16),

                    MoodSelector(
                      selectedMoodLevel: selectedMoodLevel,
                      onMoodSelected: (level) {
                        setState(() {
                          selectedMoodLevel = level;
                        });
                      },
                    ),

                    const SizedBox(height: 32),

                    // Campo de nota
                    Text(
                      'Adicione uma nota (opcional)',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),

                    const SizedBox(height: 12),

                    TextField(
                      controller: noteController,
                      focusNode: noteFocusNode,
                      maxLines: 4,
                      maxLength: 200,
                      decoration: const InputDecoration(
                        hintText: 'Como foi o seu dia? O que aconteceu?',
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Botão de salvar (full width)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed:
                            moodNotifier.isLoading ? null : _saveMoodEntry,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child:
                            moodNotifier.isLoading
                                ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                                : Text(
                                  isEditing
                                      ? 'Atualizar Humor'
                                      : 'Salvar Humor',
                                  style: const TextStyle(fontSize: 16),
                                ),
                      ),
                    ),
                  ],
                ),
              ),
    );
  }

  Widget _buildDateSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildDateTimeCard(
              icon: Icons.calendar_today_outlined,
              label: 'Data',
              value: DateFormat('dd/MM/yyyy').format(selectedDate),
              subtitle: DateFormat('EEEE', 'pt_BR').format(selectedDate),
              onTap: _selectDate,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(width: 16),
          Container(
            width: 1,
            height: 60,
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildDateTimeCard(
              icon: Icons.access_time_outlined,
              label: 'Hora',
              value: DateFormat('HH:mm').format(selectedDate),
              subtitle: 'Horário',
              onTap: _selectTime,
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateTimeCard({
    required IconData icon,
    required String label,
    required String value,
    required String subtitle,
    required VoidCallback onTap,
    required Color color,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: color.withOpacity(0.05),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: color),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.edit_outlined,
                  size: 16,
                  color: color.withOpacity(0.7),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      locale: const Locale('pt', 'BR'),
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        // Manter a hora atual ao alterar apenas a data
        selectedDate = DateTime(
          picked.year,
          picked.month,
          picked.day,
          selectedDate.hour,
          selectedDate.minute,
        );
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(selectedDate),
    );

    if (picked != null) {
      setState(() {
        // Manter a data atual ao alterar apenas a hora
        selectedDate = DateTime(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day,
          picked.hour,
          picked.minute,
        );
      });
    }
  }

  Future<void> _saveMoodEntry() async {
    // Dismissar o teclado
    noteFocusNode.unfocus();

    final moodNotifier = ref.read(moodEntryProvider.notifier);

    try {
      if (widget.existingEntry != null) {
        // Atualizar entrada existente
        final updatedEntry = widget.existingEntry!.copyWith(
          date: selectedDate,
          moodLevel: selectedMoodLevel,
          note:
              noteController.text.trim().isEmpty
                  ? null
                  : noteController.text.trim(),
        );

        await moodNotifier.updateMoodEntry(updatedEntry);
      } else {
        // Criar nova entrada
        await moodNotifier.addMoodEntry(
          date: selectedDate,
          moodLevel: selectedMoodLevel,
          note:
              noteController.text.trim().isEmpty
                  ? null
                  : noteController.text.trim(),
        );
      }

      // Invalidar os providers para recarregar os dados
      ref.invalidate(moodEntriesProvider);
      ref.invalidate(recentMoodEntriesProvider);
      ref.invalidate(moodStatisticsProvider);

      if (mounted) {
        // Mostrar feedback de sucesso
        AppSnackBar.showMoodSuccess(
          context,
          widget.existingEntry != null
              ? 'Humor atualizado com sucesso!'
              : 'Humor registrado com sucesso!',
        );

        // Voltar para a tela anterior
        Navigator.of(context).pop(true);
      }
    } catch (error) {
      if (mounted) {
        AppSnackBar.showError(context, 'Erro ao salvar: $error');
      }
    }
  }
}
