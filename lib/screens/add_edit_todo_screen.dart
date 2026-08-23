import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/todo.dart';
import '../providers/todo_provider.dart';
import '../utils/category_style.dart';

class AddEditTodoScreen extends StatefulWidget {
  final Todo? todo;

  const AddEditTodoScreen({super.key, this.todo});

  @override
  State<AddEditTodoScreen> createState() => _AddEditTodoScreenState();
}

class _AddEditTodoScreenState extends State<AddEditTodoScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _memoController;
  String? _selectedCategory;
  DateTime? _dueDate;
  bool _showCategoryError = false;

  bool get _isEditing => widget.todo != null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.todo?.title ?? '');
    _memoController = TextEditingController(text: widget.todo?.memo ?? '');
    _selectedCategory = widget.todo?.category;
    _dueDate = widget.todo?.dueDate;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _memoController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }

  Future<void> _pickDueDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) {
      setState(() => _dueDate = picked);
    }
  }

  Future<void> _save() async {
    final isValid = _formKey.currentState!.validate();
    final hasCategory = _selectedCategory != null;
    if (!hasCategory) {
      setState(() => _showCategoryError = true);
    }
    if (!isValid || !hasCategory) return;

    final title = _titleController.text.trim();
    final memo = _memoController.text.trim();
    final provider = context.read<TodoProvider>();

    if (_isEditing) {
      final todo = widget.todo!;
      todo.title = title;
      todo.category = _selectedCategory!;
      todo.memo = memo.isEmpty ? null : memo;
      todo.dueDate = _dueDate;
      await provider.updateTodo(todo);
    } else {
      await provider.addTodo(
        Todo(
          title: title,
          category: _selectedCategory!,
          memo: memo.isEmpty ? null : memo,
          dueDate: _dueDate,
        ),
      );
    }

    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    Navigator.of(context).pop();
    messenger.showSnackBar(const SnackBar(content: Text('저장되었습니다')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? '할 일 수정' : '새 할 일')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: '제목'),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return '제목을 입력해주세요';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            const Text('카테고리'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: todoCategories.map((category) {
                final isSelected = category == _selectedCategory;
                final color = categoryColor(category);
                return ChoiceChip(
                  label: Text(category),
                  selected: isSelected,
                  onSelected: (_) {
                    setState(() {
                      _selectedCategory = category;
                      _showCategoryError = false;
                    });
                  },
                  selectedColor: color.withValues(alpha: 0.2),
                  labelStyle: TextStyle(
                    color: isSelected ? color : null,
                    fontWeight: isSelected ? FontWeight.bold : null,
                  ),
                  side: BorderSide(color: isSelected ? color : Colors.grey.shade400),
                );
              }).toList(),
            ),
            if (_showCategoryError)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  '카테고리를 선택해주세요',
                  style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 12),
                ),
              ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _memoController,
              decoration: const InputDecoration(
                labelText: '메모',
                alignLabelWithHint: true,
              ),
              maxLines: 4,
            ),
            const SizedBox(height: 20),
            const Text('마감일'),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _dueDate == null ? '마감일 없음' : _formatDate(_dueDate!),
                  ),
                ),
                TextButton(
                  onPressed: _pickDueDate,
                  child: const Text('날짜 선택'),
                ),
                if (_dueDate != null)
                  IconButton(
                    onPressed: () => setState(() => _dueDate = null),
                    icon: const Icon(Icons.clear),
                    tooltip: '지우기',
                  ),
              ],
            ),
            const SizedBox(height: 32),
            FilledButton(
              onPressed: _save,
              child: Text(_isEditing ? '수정' : '저장'),
            ),
          ],
        ),
      ),
    );
  }
}
