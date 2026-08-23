import 'package:hive/hive.dart';

import '../models/todo.dart';

class TodoRepository {
  static const String boxName = 'todos';

  late final Box<Todo> _box;

  Future<void> init() async {
    _box = await Hive.openBox<Todo>(boxName);
  }

  List<Todo> getAll() => _box.values.toList();

  Future<void> add(Todo todo) => _box.put(todo.id, todo);

  Future<void> update(Todo todo) => _box.put(todo.id, todo);

  Future<void> delete(String id) => _box.delete(id);

  Future<void> toggleDone(String id) async {
    final todo = _box.get(id);
    if (todo == null) return;
    todo.isDone = !todo.isDone;
    await todo.save();
  }
}
