---
description: "Task list for feature implementation"
---

# Tasks: Fix Project Accessibility Error

**Input**: Design documents from `/specs/009-fix-project-accessibility/`
**Prerequisites**: plan.md (required), spec.md (required for user stories), research.md, data-model.md, contracts/

**Tests**: Manual testing only - automated tests are prohibited per NovaSpec constitution

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`
- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

## Path Conventions
- **Flutter project**: `lib/` at repository root
- Paths shown below follow Flutter project structure from plan.md

## Phase 1: Remove Old Logic & Create New Services

**Purpose**: Remove old accessibility checking logic and create new services

- [X] T001 Remove old 30-second timer logic from lib/features/project/providers/project_provider.dart
- [X] T002 Remove old accessibility checking methods from lib/features/project/services/project_service.dart
- [X] T003 [P] Create ProjectStatus enum in lib/shared/models/project_status.dart
- [X] T004 [P] Create ProjectSettings model in lib/shared/models/project_settings.dart
- [X] T005 [P] Create FileMonitorEvent model in lib/shared/models/file_monitor_event.dart
- [X] T006 [P] Create ProjectSyncInfo model in lib/shared/models/project_sync_info.dart
- [X] T007 Update Project model in lib/shared/models/project.dart with new fields and status
- [X] T008 [P] Create FileMonitorService interface in lib/core/services/file_monitor_service.dart
- [X] T009 [P] Create ProjectSyncService interface in lib/core/services/project_sync_service.dart
- [X] T010 Update ProjectService interface in lib/core/services/project_service.dart with new methods
- [X] T011 [P] Create ProjectError class in lib/core/models/project_error.dart
- [X] T012 Update service locator in lib/shared/services/di_container.dart to register new services

**Checkpoint**: Core models and services ready - user story implementation can now begin

---

## Phase 3: User Story 1 - Eliminate False Project Accessibility Notifications (Priority: P1) 🎯 MVP

**Goal**: Устранить ложные уведомления для папок-проектов через постоянный мониторинг

**Independent Test**: Создать папку-проект и работать с ним несколько минут - система не должна показывать уведомлений о доступности

### Manual Testing for User Story 1 (REQUIRED) ⚠️

**NOTE: All functionality MUST be tested manually by user through UI**

- [X] T021 [US1] Manual test: Create folder project and verify no accessibility notifications appear during normal work
- [X] T022 [US1] Manual test: Delete folder project and verify error notification only appears when attempting operations
- [X] T023 [US1] Manual test: Work with folder project for extended time (5+ minutes) to confirm no periodic notifications

### Implementation for User Story 1

- [X] T013 [P] [US1] Implement FileMonitorServiceImpl in lib/features/workspace/services/file_monitor_service_impl.dart
- [X] T014 [US1] Update ProjectService in lib/core/services/project_service.dart to use continuous monitoring for folder projects
- [X] T015 [US1] Implement project type detection in lib/core/services/project_service.dart
- [X] T016 [US1] Update ProjectProvider in lib/features/project/providers/project_provider.dart to use new monitoring logic
- [X] T017 [US1] Add accessibility check only on user actions in lib/features/project/providers/project_provider.dart
- [X] T018 [US1] Update error handling in lib/features/project/providers/project_provider.dart to use ModernToast instead of SnackBar
- [X] T019 [US1] Implement network path validation in lib/core/services/project_service.dart
- [X] T020 [US1] Add permission error handling in lib/features/project/providers/project_provider.dart

**Checkpoint**: At this point, User Story 1 should be fully functional and testable independently

---

## Phase 4: User Story 2 - File Project Accessibility Check (Priority: P1)

**Goal**: Обеспечить корректную проверку доступности для файловых проектов с 30-секундным интервалом

**Independent Test**: Создать файловый проект и проверить работу таймера доступности

### Manual Testing for User Story 2 (REQUIRED) ⚠️

- [X] T028 [US2] Manual test: Create file project and verify 30-second accessibility checks work
- [X] T029 [US2] Manual test: Delete file project externally and verify error notification appears
- [X] T030 [US2] Manual test: Move file project and verify accessibility error is detected

### Implementation for User Story 2

- [X] T024 [P] [US2] Implement 30-second timer for file projects in lib/features/project/providers/project_provider.dart
- [X] T025 [US2] Add file accessibility checking logic in lib/features/project/services/project_service_impl.dart
- [X] T026 [US2] Update ProjectProvider to maintain different behavior for file vs folder projects
- [X] T027 [US2] Add file project status updates in lib/features/project/providers/project_provider.dart

**Checkpoint**: At this point, User Stories 1 AND 2 should both work independently

---

## Phase 5: User Story 3 - Project Status Management (Priority: P2)

**Goal**: Корректное управление статусом проекта в UI для разных типов проектов

**Independent Test**: Проверить отображение статуса проекта в UI для разных типов и состояний

### Manual Testing for User Story 3 (REQUIRED) ⚠️

- [X] T031 [US3] Manual test: Verify project status displays correctly for accessible folder project
- [X] T032 [US3] Manual test: Verify project status displays correctly for accessible file project
- [X] T033 [US3] Manual test: Verify project status updates to inaccessible when project becomes unavailable

### Implementation for User Story 3

- [X] T031 [P] [US3] Implement ProjectSyncServiceImpl in lib/features/project/services/project_sync_service_impl.dart
- [X] T032 [US3] Add project status UI updates in lib/features/project/providers/project_provider.dart
- [X] T033 [US3] Implement multi-instance synchronization in lib/features/project/services/project_sync_service_impl.dart
- [X] T034 [US3] Add file locking mechanism in lib/features/project/services/project_sync_service_impl.dart
- [X] T035 [US3] Update UI components to display project status correctly

**Checkpoint**: All user stories should now be independently functional

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Improvements that affect multiple user stories

- [X] T036 [P] Update localization files in lib/l10n/ with new error messages and status text
- [X] T037 [P] Code cleanup and refactoring across all implemented services
- [X] T038 Performance optimization for file monitoring across all stories
- [X] T039 Manual testing validation across all user stories
- [X] T040 Update documentation in lib/README.md for new project accessibility features
- [X] T041 Run quickstart.md validation scenarios
- [X] T042 [P] Add comprehensive error logging in lib/core/utils/app_logger.dart

---

## Dependencies & Execution Order

### Phase Dependencies

- **Core Models & Services (Phase 1)**: No dependencies - can start immediately
- **User Stories (Phase 2-4)**: All depend on Core Models & Services completion
  - User stories can then proceed in parallel (if staffed)
  - Or sequentially in priority order (P1 → P2)
- **Polish (Phase 5)**: Depends on all desired user stories being complete

### User Story Dependencies

- **User Story 1 (P1)**: Can start after Core Models & Services (Phase 1) - No dependencies on other stories
- **User Story 2 (P1)**: Can start after Core Models & Services (Phase 1) - Shares ProjectProvider with US1 but should be independently testable
- **User Story 3 (P2)**: Can start after Core Models & Services (Phase 1) - Depends on both US1 and US2 for complete status management

### Within Each User Story

- Manual testing MUST be performed after implementation
- Models before services
- Services before providers
- Core implementation before integration
- Story complete before moving to next priority

### Parallel Opportunities

- All Core Models & Services tasks marked [P] can run in parallel (within Phase 1)
- Once Foundational phase completes, User Story 1 and User Story 2 can start in parallel (both P1)
- Models within a story marked [P] can run in parallel
- Different user stories can be worked on in parallel by different team members

---

## Parallel Example: User Story 1

```bash
# Create all models for User Story 1 together:
Task: "T019 Implement FileMonitorServiceImpl in lib/features/workspace/services/file_monitor_service_impl.dart"
Task: "T021 Implement project type detection in lib/features/project/services/project_service_impl.dart"

# Update providers in parallel:
Task: "T022 Update ProjectProvider in lib/features/project/providers/project_provider.dart"
Task: "T024 Update error handling in lib/features/project/providers/project_provider.dart"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Core Models & Services
2. Complete Phase 2: User Story 1
3. **STOP and VALIDATE**: Test User Story 1 independently
4. Deploy/demo if ready

### Incremental Delivery

1. Complete Core Models & Services → Foundation ready
2. Add User Story 1 → Test independently → Deploy/Demo (MVP!)
3. Add User Story 2 → Test independently → Deploy/Demo
4. Add User Story 3 → Test independently → Deploy/Demo
5. Each story adds value without breaking previous stories

### Parallel Team Strategy

With multiple developers:

1. Team completes Core Models & Services together
2. Once Core is done:
   - Developer A: User Story 1
   - Developer B: User Story 2 (can start in parallel)
3. After US1+US2 complete:
   - Developer A or B: User Story 3
4. Stories complete and integrate independently

---

## Notes

- [P] tasks = different files, no dependencies
- [Story] label maps task to specific user story for traceability
- Each user story should be independently completable and testable
- Verify functionality works through manual testing after implementing
- Commit after each task or logical group
- Stop at any checkpoint to validate story independently
- Avoid: vague tasks, same file conflicts, cross-story dependencies that break independence
- All UI components must use ModernButton, ModernToast, CustomStyledDropdown - NO standard Flutter components
- All text must support flutter_localizations for Russian/English
- NO automated tests - all validation must be manual through UI