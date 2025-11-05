import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/mood_entry.dart';
import '../providers/mood_providers.dart';
import '../widgets/mood_selector.dart';

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
    final moodNotifier = ref.watch(moodEntryNotifierProvider);
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
                        ? Colors.grey
                        : Theme.of(context).primaryColor,
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
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.blue.shade200),
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
                                color: Colors.blue.shade700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Criado em ${DateFormat('dd/MM/yyyy \'às\' HH:mm').format(widget.existingEntry!.createdAt)}',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: Colors.blue.shade600),
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
    return Card(
      child: ListTile(
        leading: const Icon(Icons.calendar_today),
        title: const Text('Data'),
        subtitle: Text(
          DateFormat('dd/MM/yyyy - EEEE', 'pt_BR').format(selectedDate),
        ),
        onTap: _selectDate,
        trailing: const Icon(Icons.chevron_right),
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
        selectedDate = picked;
      });
    }
  }

  Future<void> _saveMoodEntry() async {
    // Dismissar o teclado
    noteFocusNode.unfocus();

    final moodNotifier = ref.read(moodEntryNotifierProvider.notifier);

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
      ref.invalidate(todayMoodEntryProvider);
      ref.invalidate(moodStatisticsProvider);

      if (mounted) {
        // Mostrar feedback de sucesso
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.existingEntry != null
                  ? 'Humor atualizado com sucesso!'
                  : 'Humor registrado com sucesso!',
            ),
            backgroundColor: Colors.green,
          ),
        );

        // Voltar para a tela anterior
        Navigator.of(context).pop(true);
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
