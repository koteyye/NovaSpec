---
description: "Task list template for feature implementation"
---

# Tasks: WebView2 SwaggerUI Integration

**Input**: Design documents from `/specs/013-webview2-swagger/`
**Prerequisites**: plan.md (required), spec.md (required for user stories), research.md, data-model.md, contracts/

**Tests**: Manual testing only - automated tests are prohibited per Constitution

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

- [X] T001 Проверить наличие webview_windows зависимости в pubspec.yaml
- [X] T002 [P] Добавить win32 зависимость в pubspec.yaml для проверки реестра
- [X] T003 [P] Создать структуру директорий для WebView2 компонентов в lib/features/workspace/
- [X] T004 [P] Обновить анализ опций для поддержки новых пакетов

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core infrastructure that MUST be complete before ANY user story can be implemented

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

- [X] T005 Создать WebViewState модель в lib/features/workspace/models/webview_state.dart
- [X] T006 [P] Создать WebViewWindowState модель в lib/features/workspace/models/webview_window_state.dart
- [X] T007 [P] Создать OpenAPIFileInfo модель в lib/features/workspace/models/openapi_file_info.dart
- [X] T008 [P] Создать WebView2Status модель в lib/features/workspace/models/webview2_status.dart
- [X] T009 Создать WebView2CheckerService в lib/features/workspace/services/webview2_checker_service.dart
- [X] T010 [P] Обновить существующий PlatformDetector для поддержки WebView2 в lib/core/utils/platform_detector.dart
- [X] T011 [P] Добавить WebView2 константы в lib/core/constants/app_constants.dart
- [X] T012 Создать WebViewProvider в lib/features/workspace/providers/webview_provider.dart
- [ ] T013 Обновить DI контейнер для регистрации новых сервисов в lib/shared/services/di_container.dart

**Checkpoint**: Foundation ready - user story implementation can now begin in parallel

---

## Phase 3: User Story 1 - Автоматическое открытие OpenAPI в SwaggerUI (Priority: P1) 🎯 MVP

**Goal**: Пользователь открывает файл OpenAPI (yaml/json) и он автоматически отображается в SwaggerUI во встроенном компоненте

**Independent Test**: Открыть OpenAPI файл и проверить что SwaggerUI открывается во встроенном WebView2 компоненте на Windows

### Manual Testing for User Story 1 (REQUIRED) ⚠️

**NOTE: All functionality MUST be tested manually by user through UI**

- [ ] T014 [US1] Ручное тест: Проверить открытие YAML файла в WebView2 на Windows
- [ ] T015 [US1] Ручное тест: Проверить открытие JSON файла в WebView2 на Windows
- [ ] T016 [US1] Ручное тест: Проверить что функции SwaggerUI работают (развертывание эндпоинтов, отправка запросов)
- [ ] T017 [US1] Ручное тест: Проверить работу на не-Windows платформах с текущей реализацией

### Implementation for User Story 1

- [ ] T018 [P] [US1] Создать WebView2Container виджет в lib/features/workspace/widgets/webview2_container.dart
- [ ] T019 [US1] Интегрировать WebView2Container с существующим файловым обработчиком
- [ ] T020 [US1] Реализовать загрузку URL в WebView2 через существующий SwaggerServerService
- [ ] T021 [US1] Добавить обработку ошибок загрузки WebView2
- [ ] T022 [US1] Добавить логирование операций WebView2 через AppLogger

**Checkpoint**: At this point, User Story 1 should be fully functional and testable independently

---

## Phase 4: User Story 2 - Управление окном SwaggerUI (Priority: P2)

**Goal**: Пользователь может управлять размером и положением окна SwaggerUI с сохранением состояния между сессиями

**Independent Test**: Открыть OpenAPI файл, изменить размер окна, закрыть и снова открыть - проверить что размеры сохранились

### Manual Testing for User Story 2 (REQUIRED) ⚠️

- [ ] T023 [US2] Ручное тест: Проверить изменение размера окна WebView2
- [ ] T024 [US2] Ручное тест: Проверить изменение положения окна WebView2
- [ ] T025 [US2] Ручное тест: Проверить сохранение состояния окна между сессиями
- [ ] T026 [US2] Ручное тест: Проверить максимизацию и восстановление окна

### Implementation for User Story 2

- [ ] T027 [P] [US2] Реализовать сохранение состояния окна в SharedPreferences
- [ ] T028 [US2] Реализовать восстановление состояния окна при запуске
- [ ] T029 [US2] Добавить обработку изменения размера окна в WebView2Container
- [ ] T030 [US2] Добавить обработку изменения положения окна в WebView2Container
- [ ] T031 [US2] Интегрировать управление состоянием окна с WebViewProvider

**Checkpoint**: At this point, User Stories 1 AND 2 should both work independently

---

## Phase 5: User Story 3 - Проверка наличия WebView2 при запуске (Priority: P3)

**Goal**: При запуске приложения проверяется наличие WebView2 и предоставляется соответствующий интерфейс

**Independent Test**: Запустить приложение на Windows с WebView2 и без WebView2, проверить правильное поведение

### Manual Testing for User Story 3 (REQUIRED) ⚠️

- [ ] T032 [US3] Ручное тест: Проверить работу на Windows с установленным WebView2
- [ ] T033 [US3] Ручное тест: Проверить работу на Windows без WebView2 (показ заглушки)
- [ ] T034 [US3] Ручное тест: Проверить работу на не-Windows платформах
- [ ] T035 [US3] Ручное тест: Проверить кэширование результата проверки WebView2

### Implementation for User Story 3

- [ ] T036 [P] [US3] Реализовать проверку WebView2 при запуске приложения
- [ ] T037 [US3] Добавить кэширование результата проверки на 24 часа
- [ ] T038 [US3] Обновить существующую заглушку для отображения при отсутствии WebView2
- [ ] T039 [US3] Интегрировать проверку WebView2 с процессом открытия файлов
- [ ] T040 [US3] Добавить обработку ошибок проверки WebView2

**Checkpoint**: All user stories should now be independently functional

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Improvements that affect multiple user stories

- [ ] T041 [P] Оптимизировать производительность загрузки WebView2
- [ ] T042 [P] Добавить обработку нехватки системных ресурсов
- [ ] T043 [P] Улучшить сообщения об ошибках для пользователя
- [ ] T044 [P] Обновить документацию компонентов
- [ ] T045 [P] Провести финальное ручное тестирование всех сценариев
- [ ] T046 [P] Проверить соответствие UI TypeScript референсу
- [ ] T047 [P] Валидировать локализацию сообщений об ошибках

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - can start immediately
- **Foundational (Phase 2)**: Depends on Setup completion - BLOCKS all user stories
- **User Stories (Phase 3+)**: All depend on Foundational phase completion
  - User stories can then proceed in parallel (if staffed)
  - Or sequentially in priority order (P1 → P2 → P3)
- **Polish (Final Phase)**: Depends on all desired user stories being complete

### User Story Dependencies

- **User Story 1 (P1)**: Can start after Foundational (Phase 2) - No dependencies on other stories
- **User Story 2 (P2)**: Can start after Foundational (Phase 2) - Depends on User Story 1 WebView2Container
- **User Story 3 (P3)**: Can start after Foundational (Phase 2) - Depends on WebView2CheckerService from Phase 2

### Within Each User Story

- Manual testing MUST be performed after implementation
- Models before services
- Services before widgets
- Core implementation before integration
- Story complete before moving to next priority

### Parallel Opportunities

- All Setup tasks marked [P] can run in parallel
- All Foundational tasks marked [P] can run in parallel (within Phase 2)
- Once Foundational phase completes, User Story 1 and User Story 3 can start in parallel
- User Story 2 depends on User Story 1 WebView2Container
- All manual testing for a user story can be performed in sequence
- Models within a story marked [P] can run in parallel
- Different user stories can be worked on in parallel by different team members

---

## Parallel Example: User Story 1

```bash
# Создать все модели для User Story 1 вместе:
Task: "Создать WebViewState модель в lib/features/workspace/models/webview_state.dart"
Task: "Создать WebViewWindowState модель в lib/features/workspace/models/webview_window_state.dart"
Task: "Создать OpenAPIFileInfo модель в lib/features/workspace/models/openapi_file_info.dart"

# Выполнить все ручные тесты для User Story 1:
Task: "Ручное тест: Проверить открытие YAML файла в WebView2 на Windows"
Task: "Ручное тест: Проверить открытие JSON файла в WebView2 на Windows"
Task: "Ручное тест: Проверить что функции SwaggerUI работают"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup
2. Complete Phase 2: Foundational (CRITICAL - blocks all stories)
3. Complete Phase 3: User Story 1
4. **STOP and VALIDATE**: Test User Story 1 independently
5. Deploy/demo if ready

### Incremental Delivery

1. Complete Setup + Foundational → Foundation ready
2. Add User Story 1 → Test independently → Deploy/Demo (MVP!)
3. Add User Story 2 → Test independently → Deploy/Demo
4. Add User Story 3 → Test independently → Deploy/Demo
5. Each story adds value without breaking previous stories

### Parallel Team Strategy

With multiple developers:

1. Team completes Setup + Foundational together
2. Once Foundational is done:
   - Developer A: User Story 1
   - Developer B: User Story 3 (can start in parallel)
   - Developer C: User Story 2 (waits for User Story 1 WebView2Container)
3. Stories complete and integrate independently

---

## Notes

- [P] tasks = different files, no dependencies
- [Story] label maps task to specific user story for traceability
- Each user story should be independently completable and testable
- Verify functionality works through manual testing after implementing
- Commit after each task or logical group
- Stop at any checkpoint to validate story independently
- Avoid: vague tasks, same file conflicts, cross-story dependencies that break independence
- **IMPORTANT**: No automated tests - all validation must be manual per Constitution
- **CRITICAL**: Use existing UI components (ModernButton, ModernToast, CustomStyledDropdown)
- **REQUIRED**: Follow Flutter Provider pattern with ChangeNotifier
- **MANDATORY**: Use get_it for dependency injection with singleton pattern