import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'models/todo.dart';
import 'providers/todo_provider.dart';
import 'screens/home_screen.dart';
import 'services/todo_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  TodoRepository? repository;
  Object? initError;
  try {
    await Hive.initFlutter();
    Hive.registerAdapter(TodoAdapter());
    repository = TodoRepository();
    await repository.init();
  } catch (error) {
    initError = error;
  }

  runApp(
    repository == null
        ? _InitErrorApp(error: initError)
        : ChangeNotifierProvider(
            create: (_) => TodoProvider(repository!),
            child: const MyApp(),
          ),
  );
}

class _InitErrorApp extends StatelessWidget {
  final Object? error;

  const _InitErrorApp({required this.error});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  '앱을 시작하는 중 문제가 발생했습니다.\n앱을 완전히 종료했다가 다시 실행해주세요.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  '$error',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '할 일 관리',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const HomeScreen(),
    );
  }
}
