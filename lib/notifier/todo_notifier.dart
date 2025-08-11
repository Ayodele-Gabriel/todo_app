import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/todo_model.dart';

class TodoListNotifier extends StateNotifier<List<Todo>> {
  static const _storageKey = 'todos';

  TodoListNotifier() : super([]);


  Future<void> loadTodos() async {
    final prefs = await SharedPreferences.getInstance();
    final todosJson = prefs.getString(_storageKey);
    if (todosJson != null) {
      final List decoded = jsonDecode(todosJson);
      if (!mounted) return;
      state = decoded.map((e) => Todo.fromMap(e)).toList();
    }
  }

  Future<void> _saveTodos() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(state.map((e) => e.toMap()).toList());
    await prefs.setString(_storageKey, encoded);
  }

  Future<void> addTodo(String title) async {
    if (title.trim().isEmpty) return;

    final newTodo = Todo(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title.trim(),
    );
    if (!mounted) return;
    state = [...state, newTodo];
    if (mounted) {
      await _saveTodos();
    }
  }

  Future<void> toggleTodo(String id) async {
    state = [
      for (final todo in state)
        if (todo.id == id)
          todo.copyWith(isCompleted: !todo.isCompleted)
        else
          todo,
    ];
    if (mounted) {
      await _saveTodos();
    }
  }

  Future<void> deleteTodo(String id) async {
    state = state.where((todo) => todo.id != id).toList();
    if (mounted) {
      await _saveTodos();
    }
  }

  Future<void> clearCompleted() async {
    state = state.where((todo) => !todo.isCompleted).toList();
    if (mounted) {
      await _saveTodos();
    }
  }
}

final searchQueryProvider = StateProvider<String>((ref) => '');

final searchedTodosProvider = Provider<List<Todo>>((ref) {
  final query = ref.watch(searchQueryProvider).toLowerCase();
  final todos = ref.watch(filteredTodosProvider);
  return todos.where((todo) => todo.title.toLowerCase().contains(query)).toList();
});

final todoListProvider = StateNotifierProvider<TodoListNotifier, List<Todo>>((ref) {
  return TodoListNotifier();
});

enum TodoFilter { all, active, completed }

final todoFilterProvider = StateProvider<TodoFilter>((ref) => TodoFilter.all);

final filteredTodosProvider = Provider<List<Todo>>((ref) {
  final todos = ref.watch(todoListProvider);
  final filter = ref.watch(todoFilterProvider);

  switch (filter) {
    case TodoFilter.all:
      return todos;
    case TodoFilter.active:

      return todos.where((todo) => !todo.isCompleted).toList();
    case TodoFilter.completed:
      return todos.where((todo) => todo.isCompleted).toList();
  }
});

final todoStatsProvider = Provider<_TodoStats>((ref) {
  final todos = ref.watch(todoListProvider);

  final total = todos.length;
  final completed = todos.where((todo) => todo.isCompleted).length;
  final active = total - completed;

  return _TodoStats(
    total: total,
    completed: completed,
    active: active,
  );
});


class _TodoStats {
  final int total;
  final int completed;
  final int active;

  _TodoStats({
    required this.total,
    required this.completed,
    required this.active,
  });
}
