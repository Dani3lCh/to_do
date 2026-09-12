import 'package:flutter/material.dart';

import '../models/todo.dart';
import '../services/todo_storage.dart';
import '../widgets/edit_todo_sheet.dart';
import '../widgets/todo_tile.dart';

enum TodoFilter { all, active, done }

class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  final _storage = TodoStorage();
  final List<Todo> _todos = [];
  TodoFilter _filter = TodoFilter.all;
  bool _loading = true;
  int _idCounter = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final loaded = await _storage.load();
    setState(() {
      _todos.addAll(loaded);
      _loading = false;
    });
  }

  void _persist() => _storage.save(_todos);

  String _newId() => '${DateTime.now().microsecondsSinceEpoch}_${_idCounter++}';

  List<Todo> get _visibleTodos {
    switch (_filter) {
      case TodoFilter.all:
        return _todos;
      case TodoFilter.active:
        return _todos.where((t) => !t.done).toList();
      case TodoFilter.done:
        return _todos.where((t) => t.done).toList();
    }
  }

  Future<void> _addTodo() async {
    final result = await showEditTodoSheet(context);
    if (result == null) return;
    setState(() {
      _todos.insert(
        0,
        Todo(
          id: _newId(),
          title: result.title,
          notes: result.notes,
          priority: result.priority,
        ),
      );
    });
    _persist();
  }

  Future<void> _editTodo(Todo todo) async {
    final result = await showEditTodoSheet(context, existing: todo);
    if (result == null) return;
    setState(() {
      todo.title = result.title;
      todo.notes = result.notes;
      todo.priority = result.priority;
    });
    _persist();
  }

  void _toggleTodo(Todo todo, bool value) {
    setState(() => todo.done = value);
    _persist();
  }

  void _removeTodo(Todo todo) {
    final index = _todos.indexOf(todo);
    setState(() => _todos.remove(todo));
    _persist();
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('"${todo.title}" eliminada'),
        action: SnackBarAction(
          label: 'Deshacer',
          onPressed: () {
            setState(() => _todos.insert(index.clamp(0, _todos.length), todo));
            _persist();
          },
        ),
      ),
    );
  }

  void _clearDone() {
    setState(() => _todos.removeWhere((t) => t.done));
    _persist();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final total = _todos.length;
    final doneCount = _todos.where((t) => t.done).length;
    final progress = total == 0 ? 0.0 : doneCount / total;
    final visible = _visibleTodos;

    return Scaffold(
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                    sliver: SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Mis tareas',
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            total == 0
                                ? 'Empieza agregando tu primera tarea'
                                : '$doneCount de $total completadas',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(999),
                            child: TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0, end: progress),
                              duration: const Duration(milliseconds: 400),
                              curve: Curves.easeOut,
                              builder: (context, value, _) => LinearProgressIndicator(
                                value: value,
                                minHeight: 8,
                                backgroundColor:
                                    theme.colorScheme.surfaceContainerHigh,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                _FilterChip(
                                  label: 'Todas',
                                  selected: _filter == TodoFilter.all,
                                  onTap: () =>
                                      setState(() => _filter = TodoFilter.all),
                                ),
                                const SizedBox(width: 8),
                                _FilterChip(
                                  label: 'Pendientes',
                                  selected: _filter == TodoFilter.active,
                                  onTap: () => setState(
                                    () => _filter = TodoFilter.active,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                _FilterChip(
                                  label: 'Completadas',
                                  selected: _filter == TodoFilter.done,
                                  onTap: () =>
                                      setState(() => _filter = TodoFilter.done),
                                ),
                                if (doneCount > 0) ...[
                                  const SizedBox(width: 8),
                                  ActionChip(
                                    avatar: const Icon(
                                      Icons.delete_sweep_outlined,
                                      size: 18,
                                    ),
                                    label: const Text('Limpiar completadas'),
                                    onPressed: _clearDone,
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (visible.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: _EmptyState(filter: _filter),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
                      sliver: SliverList.builder(
                        itemCount: visible.length,
                        itemBuilder: (context, index) {
                          final todo = visible[index];
                          return TodoTile(
                            key: ValueKey(todo.id),
                            todo: todo,
                            onToggle: (v) => _toggleTodo(todo, v),
                            onDismissed: () => _removeTodo(todo),
                            onTap: () => _editTodo(todo),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addTodo,
        icon: const Icon(Icons.add),
        label: const Text('Nueva tarea'),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.filter});

  final TodoFilter filter;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (icon, message) = switch (filter) {
      TodoFilter.all => (
          Icons.checklist_rtl,
          'No tienes tareas todavía.\nToca "Nueva tarea" para empezar.',
        ),
      TodoFilter.active => (
          Icons.task_alt,
          '¡Nada pendiente!\nDisfruta tu tiempo libre.',
        ),
      TodoFilter.done => (
          Icons.hourglass_empty,
          'Aún no completas ninguna tarea.',
        ),
    };

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: theme.colorScheme.outline),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
