---
description: "Task list template for feature implementation"
---

# Tasks: File Format Support and Viewers

**Input**: Design documents from `/specs/012-workspace-editors-phase5/`
**Prerequisites**: plan.md (required), spec.md (required for user stories), research.md, data-model.md, contracts/

**Tests**: Manual testing only (automatic tests are forbidden by constitution)

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`
- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

## Path Conventions
- **Flutter project**: `lib/` at repository root
- **Features**: `lib/features/workspace/`
- **Shared**: `lib/shared/`
- **Core**: `lib/core/`

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Project initialization and basic structure

- [x] T001 Создать структуру директорий для компонентов просмотра файлов в lib/features/workspace/viewers/
- [x] T002 Создать структуру директорий для сервисов в lib/features/workspace/services/
- [x] T003 Создать структуру директорий для моделей в lib/features/workspace/models/
- [x] T004 Добавить зависимости в pubspec.yaml: flutter_markdown, flutter_html, audioplayers, webview_flutter, yaml, shelf, shelf_static
- [x] T005 Выполнить flutter pub get для установки новых зависимостей

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core models and services needed by all user stories

- [x] T006 Создать модель WorkspaceFile в lib/features/workspace/models/workspace_file.dart
- [x] T007 Создать модель AudioPlayerState в lib/features/workspace/models/audio_player_state.dart
- [x] T008 Создать модель OpenAPISpec в lib/features/workspace/models/openapi_spec.dart
- [x] T009 Создать перечисление FileExtension в lib/features/workspace/models/file_extension.dart
- [x] T010 Создать перечисление FileViewMode в lib/features/workspace/models/file_view_mode.dart
- [x] T011 Создать MarkdownService в lib/features/workspace/services/markdown_service.dart
- [x] T012 Создать AudioService в lib/features/workspace/services/audio_service.dart
- [x] T013 Создать OpenAPIService в lib/features/workspace/services/openapi_service.dart
- [x] T014 Создать SwaggerServerService в lib/features/workspace/services/swagger_server_service.dart
- [x] T015 [P] Создать базовый интерфейс FileViewer в lib/features/workspace/viewers/file_viewer_interface.dart

## Phase 3: User Story 1 - Markdown and HTML File Viewing and Editing (P1)

**Purpose**: Render .md/.html files and provide editing mode
**Independent Test**: Open .md/.html files and verify rendering and mode switching

- [ ] T016 [US1] Создать MarkdownViewer в lib/features/workspace/viewers/markdown_viewer.dart
- [ ] T017 [US1] Создать HtmlViewer в lib/features/workspace/viewers/html_viewer.dart
- [ ] T018 [P] [US1] Реализовать рендеринг Markdown в MarkdownViewer через flutter_markdown
- [ ] T019 [P] [US1] Реализовать рендеринг HTML в HtmlViewer через flutter_html
- [ ] T020 [US1] Добавить переключатель режимов просмотра/редактирования в MarkdownViewer
- [ ] T021 [US1] Добавить переключатель режимов просмотра/редактирования в HtmlViewer
- [ ] T022 [US1] Интегрировать Monaco Editor для режима редактирования в MarkdownViewer
- [ ] T023 [US1] Интегрировать Monaco Editor для режима редактирования в HtmlViewer
- [ ] T024 [US1] Реализовать сохранение изменений через File.writeAsString в MarkdownViewer
- [ ] T025 [US1] Реализовать сохранение изменений через File.writeAsString в HtmlViewer
- [ ] T026 [US1] Добавить обработку ошибок с ModernToast для MarkdownViewer
- [ ] T027 [US1] Добавить обработку ошибок с ModernToast для HtmlViewer

## Phase 4: User Story 2 - Audio File Playback (P1)

**Purpose**: Play .mp3/.wav files with minimal audio player
**Independent Test**: Open .mp3/.wav files and verify playback controls

- [x] T028 [US2] Создать AudioPlayer в lib/features/workspace/viewers/audio_player.dart
- [x] T029 [US2] Реализовать базовый UI аудиоплеера с ModernButton элементами
- [x] T030 [US2] Интегрировать audioplayers для воспроизведения .mp3 файлов
- [x] T031 [US2] Интегрировать audioplayers для воспроизведения .wav файлов
- [x] T032 [US2] Реализовать элементы управления play/pause через ModernButton
- [x] T033 [US2] Реализовать ползунок прогресса воспроизведения
- [x] T034 [US2] Реализовать перемотку через ползунок прогресса
- [x] T035 [US2] Добавить обработку завершения воспроизведения
- [x] T036 [US2] Реализовать отображение длительности и текущей позиции
- [x] T037 [US2] Добавить обработку ошибок загрузки аудиофайлов через ModernToast

## Phase 5: User Story 3 - YAML/JSON OpenAPI Documentation (P2)

**Purpose**: Display OpenAPI specs as interactive Swagger UI
**Independent Test**: Open valid OpenAPI files and verify Swagger UI

- [x] T038 [US3] Создать SwaggerViewer в lib/features/workspace/viewers/swagger_viewer.dart
- [x] T039 [US3] Реализовать валидацию YAML/JSON для синтаксиса OpenAPI в OpenAPIService
- [x] T040 [US3] Реализовать запуск фонового HTTP сервера в SwaggerServerService
- [x] T041 [US3] Настроить автоматический запуск сервера при открытии OpenAPI файла
- [x] T042 [US3] Интегрировать webview_flutter для отображения Swagger UI
- [x] T043 [US3] Реализовать передачу OpenAPI спецификации в Swagger UI
- [x] T044 [US3] Добавить обработку невалидных OpenAPI файлов (открывать в кодовом редакторе)
- [x] T045 [US3] Реализовать автоматическую остановку сервера при закрытии файла
- [x] T046 [US3] Добавить обработку ошибок сервера через ModernToast

## Phase 6: User Story 4 - Universal Code Editor (P2)

**Purpose**: Open unsupported file formats in Monaco Editor
**Independent Test**: Open various file formats and verify editing

- [x] T047 [US4] Создать CodeEditor в lib/features/workspace/viewers/code_editor.dart
- [x] T048 [US4] Реализовать универсальный редактор на базе Monaco Editor
- [x] T049 [US4] Добавить поддержку подсветки синтаксиса для различных языков
- [x] T050 [US4] Реализовать сохранение изменений через File.writeAsString
- [x] T051 [US4] Добавить определение типа файла для подсветки синтаксиса
- [x] T052 [US4] Реализовать кэширование содержимого файла для производительности
- [x] T053 [US4] Добавить обработку ошибок сохранения через ModernToast

## Phase 7: Integration and Polish

**Purpose**: Integrate all viewers with existing workspace system

- [ ] T054 Обновить WorkspaceProvider для поддержки новых viewers
- [ ] T055 Реализовать определение типа файла и выбор соответствующего viewer
- [ ] T056 Интегрировать новые viewers в существующую систему вкладок
- [ ] T057 Добавить локализацию для всех новых UI элементов
- [ ] T058 Реализовать плавные переключения между файлами
- [ ] T059 Оптимизировать производительность для больших файлов
- [ ] T060 Добавить валидацию размера файлов (>10MB предупреждение)
- [ ] T061 Реализовать управление памятью для множественных viewers
- [ ] T062 Добавить финальную обработку ошибок через ModernToast
- [ ] T063 Обновить документацию и комментарии

## Dependencies

### Story Completion Order
1. **Phase 1-2** (Setup & Foundational) - MUST complete first
2. **US1 & US2** (P1 stories) - Can be developed in parallel after Phase 2
3. **US3 & US4** (P2 stories) - Can be developed in parallel after Phase 2
4. **Phase 7** (Integration) - MUST complete after all user stories

### Critical Dependencies
- T006-T015 (Models & Services) → All user stories
- T016-T027 (US1) → Independent of US2
- T028-T037 (US2) → Independent of US1
- T038-T046 (US3) → Independent of US1, US2, US4
- T047-T053 (US4) → Independent of US1, US2, US3
- T054-T063 (Integration) → Depends on all user stories

## Parallel Execution Examples

### After Phase 2 Completion:
```
Parallel Stream 1: T016-T027 (US1 - Markdown/HTML)
Parallel Stream 2: T028-T037 (US2 - Audio)
Parallel Stream 3: T038-T046 (US3 - OpenAPI)
Parallel Stream 4: T047-T053 (US4 - Code Editor)
```

### Within User Stories:
- **US1**: T018, T019 can run in parallel (Markdown/HTML rendering)
- **US2**: T030, T031 can run in parallel (MP3/WAV support)
- **US3**: T040, T041 can run in parallel (Server + WebView setup)

## Implementation Strategy

### MVP Scope (First Delivery)
**Target**: User Stories 1 & 2 (P1 stories only)
- Phase 1-2: Setup and Foundational
- Phase 3: Markdown/HTML viewing and editing
- Phase 4: Audio playback
- Phase 7: Basic integration

### Incremental Delivery
1. **Week 1**: Phase 1-2 (Setup, Models, Services)
2. **Week 2**: Phase 3 (Markdown/HTML viewers)
3. **Week 3**: Phase 4 (Audio player) + Phase 7 integration
4. **Week 4**: Phase 5-6 (OpenAPI + Code Editor) + Final polish

### Risk Mitigation
- Start with simpler viewers (Markdown/HTML) before complex ones (Swagger)
- Implement error handling early with ModernToast
- Test performance with large files during development
- Use existing UI components (ModernButton, etc.) consistently

---

**Total Tasks**: 63
**Tasks per Story**: 
- Setup: 5 tasks
- Foundational: 10 tasks  
- US1 (Markdown/HTML): 12 tasks
- US2 (Audio): 10 tasks
- US3 (OpenAPI): 9 tasks
- US4 (Code Editor): 7 tasks
- Integration: 10 tasks

**Parallel Opportunities**: 15+ tasks can be parallelized across different files
**MVP Tasks**: 37 tasks (Setup + Foundational + US1 + US2 + Basic Integration)