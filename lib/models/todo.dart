import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'todo.g.dart';

const List<String> todoCategories = ['업무', '개인', '공부'];

@HiveType(typeId: 0)
class Todo extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String category;

  @HiveField(3)
  bool isDone;

  @HiveField(4)
  final DateTime createdAt;

  @HiveField(5)
  DateTime? dueDate;

  @HiveField(6)
  String? memo;

  Todo({
    String? id,
    required this.title,
    required this.category,
    this.isDone = false,
    DateTime? createdAt,
    this.dueDate,
    this.memo,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();
}
