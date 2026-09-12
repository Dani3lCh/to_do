import 'package:flutter/material.dart';

import '../models/todo.dart';

class EditTodoResult {
  EditTodoResult(this.title, this.notes, this.priority);

  final String title;
  final String notes;
  final Priority priority;
}

Future<EditTodoResult?> showEditTodoSheet(
  BuildContext context, {
  Todo? existing,
}) {
  return showModalBottomSheet<EditTodoResult>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _EditTodoSheet(existing: existing),
  );
}

class _EditTodoSheet extends StatefulWidget {
  const _EditTodoSheet({this.existing});

  final Todo? existing;

  @override
  State<_EditTodoSheet> createState() => _EditTodoSheetState();
}

class _EditTodoSheetState extends State<_EditTodoSheet> {
  late final TextEditingController _titleController;
  late final TextEditingController _notesController;
  late Priority _priority;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.existing?.title);
    _notesController = TextEditingController(text: widget.existing?.notes);
    _priority = widget.existing?.priority ?? Priority.medium;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop(
      EditTodoResult(
        _titleController.text.trim(),
        _notesController.text.trim(),
        _priority,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEditing = widget.existing != null;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(28),
          ),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              Text(
                isEditing ? 'Editar tarea' : 'Nueva tarea',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titleController,
                autofocus: !isEditing,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Título',
                  hintText: '¿Qué hay que hacer?',
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Escribe un título' : null,
                onFieldSubmitted: (_) => _submit(),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _notesController,
                textCapitalization: TextCapitalization.sentences,
                minLines: 1,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Notas (opcional)',
                ),
              ),
              const SizedBox(height: 16),
              Text('Prioridad', style: theme.textTheme.labelLarge),
              const SizedBox(height: 8),
              SegmentedButton<Priority>(
                segments: const [
                  ButtonSegment(value: Priority.low, label: Text('Baja')),
                  ButtonSegment(value: Priority.medium, label: Text('Media')),
                  ButtonSegment(value: Priority.high, label: Text('Alta')),
                ],
                selected: {_priority},
                onSelectionChanged: (s) => setState(() => _priority = s.first),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _submit,
                child: Text(isEditing ? 'Guardar cambios' : 'Agregar tarea'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
