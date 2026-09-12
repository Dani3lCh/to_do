import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/todo.dart';

class TodoStorage {
  static const _key = 'todos_v1';

  Future<List<Todo>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => Todo.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> save(List<Todo> todos) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(todos.map((t) => t.toJson()).toList());
    await prefs.setString(_key, raw);
  }
}
