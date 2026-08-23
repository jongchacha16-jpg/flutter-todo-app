import 'package:flutter/foundation.dart';

import '../models/todo.dart';
import '../services/todo_repository.dart';

class TodoProvider extends ChangeNotifier {
  final TodoRepository _repository;

  TodoProvider(this._repository);

  List<Todo> get todos => _repository.getAll();

  Future<void> addTodo(Todo todo) async {
    await _repository.add(todo);
    notifyListeners();
  }

  Future<void> updateTodo(Todo todo) async {
    await _repository.update(todo);
    notifyListeners();
  }

  Future<void> deleteTodo(String id) async {
    await _repository.delete(id);
    notifyListeners();
  }

  Future<void> toggleDone(String id) async {
    await _repository.toggleDone(id);
    notifyListeners();
  }
}
