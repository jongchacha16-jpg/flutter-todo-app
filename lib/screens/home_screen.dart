import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/todo.dart';
import '../providers/todo_provider.dart';
import '../utils/category_style.dart';
import 'add_edit_todo_screen.dart';

const String _allCategoriesLabel = '전체';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedCategory = _allCategoriesLabel;

  Future<bool> _confirmDelete(BuildContext context, Todo todo) {
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('할 일 삭제'),
        content: Text('"${todo.title}"을(를) 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('삭제'),
          ),
        ],
      ),
    ).then((confirmed) => confirmed ?? false);
  }

  @override
  Widget build(BuildContext context) {
    final todoProvider = context.watch<TodoProvider>();
    final allTodos = todoProvider.todos;

    final totalCount = allTodos.length;
    final doneCount = allTodos.where((todo) => todo.isDone).length;
    final progress = totalCount == 0 ? 0.0 : doneCount / totalCount;

    final filteredTodos = _selectedCategory == _allCategoriesLabel
        ? allTodos
        : allTodos.where((todo) => todo.category == _selectedCategory).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('할 일 관리')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$doneCount / $totalCount 완료'),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                  ),
                ),
                const SizedBox(height: 12),
                ...todoCategories.map((category) {
                  final categoryTodos =
                      allTodos.where((todo) => todo.category == category).toList();
                  final categoryTotal = categoryTodos.length;
                  final categoryDone = categoryTodos.where((todo) => todo.isDone).length;
                  final categoryProgress =
                      categoryTotal == 0 ? 0.0 : categoryDone / categoryTotal;
                  final color = categoryColor(category);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 36,
                          child: Text(
                            category,
                            style: TextStyle(fontSize: 12, color: color),
                          ),
                        ),
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: categoryProgress,
                              minHeight: 4,
                              color: color,
                              backgroundColor: color.withValues(alpha: 0.15),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '$categoryDone/$categoryTotal',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _allCategoriesLabel,
                  ...todoCategories,
                ].map((category) {
                  final isSelected = category == _selectedCategory;
                  final color = categoryColor(category);
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Material(
                      color: isSelected ? color.withValues(alpha: 0.2) : Colors.transparent,
                      shape: StadiumBorder(
                        side: BorderSide(color: isSelected ? color : Colors.grey.shade400),
                      ),
                      child: InkWell(
                        customBorder: const StadiumBorder(),
                        onTap: () => setState(() => _selectedCategory = category),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          child: Text(
                            category,
                            style: TextStyle(
                              color: isSelected ? color : Colors.black87,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: filteredTodos.isEmpty
                ? const Center(child: Text('할 일이 없습니다'))
                : ListView.builder(
                    itemCount: filteredTodos.length,
                    itemBuilder: (context, index) {
                      final todo = filteredTodos[index];
                      final color = categoryColor(todo.category);
                      return Dismissible(
                        key: ValueKey(todo.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        confirmDismiss: (_) => _confirmDelete(context, todo),
                        onDismissed: (_) {
                          context.read<TodoProvider>().deleteTodo(todo.id);
                        },
                        child: ListTile(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AddEditTodoScreen(todo: todo),
                              ),
                            );
                          },
                          leading: Checkbox(
                            value: todo.isDone,
                            onChanged: (_) {
                              context.read<TodoProvider>().toggleDone(todo.id);
                            },
                          ),
                          title: Text(
                            todo.title,
                            style: TextStyle(
                              decoration: todo.isDone ? TextDecoration.lineThrough : null,
                              color: todo.isDone ? Colors.grey : null,
                            ),
                          ),
                          trailing: Chip(
                            label: Text(
                              todo.category,
                              style: TextStyle(color: color, fontSize: 12),
                            ),
                            backgroundColor: color.withValues(alpha: 0.12),
                            side: BorderSide(color: color.withValues(alpha: 0.4)),
                            visualDensity: VisualDensity.compact,
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddEditTodoScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
