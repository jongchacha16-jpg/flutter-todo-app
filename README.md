# flutter-todo-app — 할 일 관리 앱

Flutter로 만든 할 일 관리 앱입니다. 로컬 영속성과 상태관리를 갖춘 앱을
처음부터 끝까지 완성해보는 것이 목표였습니다.

> **성격**: 학습 목적 프로젝트입니다. 배포하거나 사용자를 받은 앱은 아닙니다.

## 기능

- 할 일 추가 · 수정 · 삭제 · 완료 처리
- **키워드 기반 카테고리 자동 분류** (아래 참고)
- 앱을 껐다 켜도 유지되는 로컬 저장

## 키워드 기반 자동 카테고리 분류

할 일 제목을 입력하면 카테고리를 자동으로 제안합니다.
머신러닝이 아니라 **규칙 기반 분류기**입니다 — 카테고리별 키워드 사전을 두고
제목에 포함된 키워드를 찾아 매칭합니다.

| 카테고리 | 키워드 수 | 예시 |
| --- | --- | --- |
| 업무 | 17개 | 회의, 보고서, 발표, 출장, 결재 … |
| 개인 | 15개 | 운동, 병원, 약속, 쇼핑, 여행 … |
| 공부 | 15개 | 시험, 과제, 강의, 스터디, 자격증 … |

```dart
String? suggestCategory(String text) {
  final normalized = text.trim().toLowerCase();
  if (normalized.isEmpty) return null;

  for (final entry in categoryKeywords.entries) {
    for (final keyword in entry.value) {
      if (normalized.contains(keyword.toLowerCase())) {
        return entry.key;      // 처음 매칭된 카테고리를 반환
      }
    }
  }
  return null;                 // 매칭 없으면 사용자가 직접 선택
}
```

**알려진 한계** — 규칙 기반이라 그대로입니다.

- 사전에 등록된 47개 키워드만 인식합니다.
- 여러 카테고리에 걸치는 제목(예: "회사 헬스장 가기")은 **먼저 순회되는 카테고리**로 분류됩니다.
- 매칭이 없으면 `null`을 반환하고 사용자가 직접 선택하도록 했습니다.

## 구조

역할별로 계층을 나눴습니다.

```
lib/
├── models/       todo.dart              Hive 어댑터 포함 데이터 모델
├── providers/    todo_provider.dart     상태 관리
├── screens/      home_screen.dart       목록 화면
│                 add_edit_todo_screen.dart  추가·수정 화면
├── services/     todo_repository.dart   저장소 접근 추상화
└── utils/        category_classifier.dart  자동 분류 로직
                  category_style.dart       카테고리별 스타일
```

`services/todo_repository.dart`로 저장소 접근을 감싸서, 상태관리 코드가
Hive에 직접 의존하지 않도록 했습니다.

## 기술 스택

| 영역 | 사용 기술 |
| --- | --- |
| 로컬 영속성 | `hive` ^2.2 + `hive_flutter` ^1.1 |
| 상태 관리 | `provider` ^6.1 |
| 기타 | `uuid` ^4.6 (식별자), `path_provider` ^2.1 (저장 경로) |

**데이터 모델** (`Todo`) — `id`, `title`, `category`, `isDone`, `createdAt` 등을
`@HiveField`로 직렬화합니다.

## 실행

```bash
flutter pub get
dart run build_runner build    # Hive 어댑터 생성 (todo.g.dart)
flutter run
```
