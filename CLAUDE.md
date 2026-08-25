# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
flutter pub get                                          # install dependencies
flutter pub run build_runner build --delete-conflicting-outputs   # regenerate lib/models/todo.g.dart after editing todo.dart
flutter analyze                                           # static analysis (must be clean before considering a change done)
flutter run -d chrome --web-port=8765                     # run in Chrome (see Windows desktop note below)
flutter test                                               # run tests — see Known issues, the default test is currently broken
```

There is no `-d windows` run available in this environment unless Developer Mode is enabled (`start ms-settings:developers`), because Windows desktop builds require symlink support for plugin native code. Chrome is the practical way to run/test this app here.

## Architecture

Standard layered Flutter structure, `provider`-based state management, `hive`/`hive_flutter` for local persistence (no backend).

```
lib/
  models/todo.dart          Todo (HiveObject, typeId 0) + todo.g.dart (generated adapter, DO NOT hand-edit)
  services/todo_repository.dart   Wraps the single Hive Box<Todo> ('todos'); CRUD + toggleDone
  providers/todo_provider.dart    ChangeNotifier wrapping TodoRepository; UI depends on this, not the repository directly
  screens/home_screen.dart        List screen: overall + per-category progress, category filter, swipe-to-delete
  screens/add_edit_todo_screen.dart  Single screen for both add and edit, keyed by `Todo? todo` constructor param
  utils/category_style.dart       Single source of truth for category -> color (imported by both screens)
  utils/category_classifier.dart  Keyword -> category map + `suggestCategory(text)`; used by add_edit_todo_screen for auto-classification
  main.dart                       Hive init + adapter registration + Provider wiring; error fallback UI if init fails
```

**Data flow**: screens call `context.read<TodoProvider>()` for mutations and `context.watch<TodoProvider>()` for the `todos` list; `TodoProvider` calls into `TodoRepository`, which is a thin wrapper around `Hive.box<Todo>('todos')` keyed by `Todo.id` (uuid v4, generated in the `Todo` constructor). `Todo` fields are mutated in place and persisted via `box.put`/`HiveObject.save()`, so objects read from `provider.todos` are live references into the box.

**Categories**: `todoCategories` (`업무`/`개인`/`공부`) lives in `models/todo.dart`; category -> color mapping lives in `utils/category_style.dart`. Both the home screen's filter chips and the add/edit screen's category picker read from these — add a new category in exactly these two places, nowhere else. A new category also needs a keyword list added to `categoryKeywords` in `utils/category_classifier.dart` if it should be auto-detected.

**Auto-classification**: `add_edit_todo_screen.dart` (add mode only) listens to the title field and calls `suggestCategory` on every keystroke, auto-selecting a matching category chip and showing a "(자동 분류됨)" hint. It stops overriding the selection the moment the user manually taps a chip (tracked via `_categoryAutoSelected`), and is disabled entirely in edit mode so it never clobbers an existing todo's category.

**Navigation**: no named routes; `home_screen.dart` uses plain `Navigator.push(MaterialPageRoute(...))` to reach `AddEditTodoScreen()` (add) or `AddEditTodoScreen(todo: todo)` (edit, pre-filled). Tapping a list row (outside the checkbox hit area) opens edit mode; the checkbox's own gesture handling takes priority so it doesn't also trigger navigation.

**Schema changes**: any change to `Todo`'s fields requires re-running the `build_runner` command above to regenerate `todo.g.dart`, and bumping `@HiveField` indices carefully — existing indices are load-bearing for already-persisted data.

## Known issues / gotchas

- `test/widget_test.dart` is the unmodified Flutter template test (asserts on a counter UI that no longer exists in `MyApp`) — it will fail if run. It hasn't been updated to test the real app yet.
- Material `ChoiceChip` clips its label to a single character when given unbounded width (e.g. inside a horizontal `SingleChildScrollView`/`Row` without a fixed extent) on this project's Flutter/CanvasKit web setup. `home_screen.dart`'s category filter works around this with a hand-rolled `Material` + `InkWell` pill instead of `ChoiceChip`. `add_edit_todo_screen.dart` uses the real `ChoiceChip` safely inside a `Wrap`, which is bounded-width and unaffected — prefer that pattern (`Wrap`, not a horizontal scroller) if adding more `ChoiceChip` UI.
- The bundled `analyzer` version (pulled in by `build_runner`/`hive_generator`) doesn't parse newer Dart dot-shorthand syntax (e.g. `.fromSeed(...)`, `.center`) — write fully-qualified names (`ColorScheme.fromSeed(...)`, `MainAxisAlignment.center`) or `build_runner` will fail to parse the file.
