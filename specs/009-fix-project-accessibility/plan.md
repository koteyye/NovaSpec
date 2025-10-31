# Implementation Plan: Fix Project Accessibility Error

**Branch**: `009-fix-project-accessibility` | **Date**: 2025-10-29 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/specs/009-fix-project-accessibility/spec.md`

## Summary

Устранение ложных уведомлений о недоступности папок-проектов путем замены периодических проверок на постоянный мониторинг. Система будет проверять доступность только при реальных действиях пользователя, полностью исключив ложные срабатывания для папочных проектов.

## Technical Context

**Language/Version**: Dart 3.x  
**Primary Dependencies**: Flutter 3.x, Provider, dio, file_picker, flutter_secure_storage  
**Storage**: Файловая система, SharedPreferences, flutter_secure_storage  
**Testing**: Ручное тестирование через UI (автоматические тесты запрещены)  
**Target Platform**: Windows, Linux, macOS (Flutter desktop)  
**Project Type**: Single Flutter application  
**Performance Goals**: Проверка доступности <100ms при действиях пользователя  
**Constraints**: Офлайн-работоспособность, <200MB память, нулевые ложные уведомления  
**Scale/Scope**: Поддержка множественных экземпляров приложения с синхронизацией

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- [x] Flutter/Dart экосистема: Использование Flutter паттернов и Provider
- [x] Flutter архитектура: Widget/State/Provider разделение с DI
- [x] Локализация: Поддержка русского и английского языков
- [x] Интеграции через API: Использование dio для всех внешних сервисов
- [x] Ручное тестирование: Никаких автоматических тестов, только ручная проверка
- [x] UI-компоненты: Обязательное использование ModernButton, ModernToast, CustomStyledDropdown

## Project Structure

### Documentation (this feature)

```
specs/[###-feature]/
├── plan.md              # This file (/speckit.plan command output)
├── research.md          # Phase 0 output (/speckit.plan command)
├── data-model.md        # Phase 1 output (/speckit.plan command)
├── quickstart.md        # Phase 1 output (/speckit.plan command)
├── contracts/           # Phase 1 output (/speckit.plan command)
└── tasks.md             # Phase 2 output (/speckit.tasks command - NOT created by /speckit.plan)
```

### Source Code (repository root)

```
lib/
├── features/
│   ├── project/
│   │   ├── providers/
│   │   │   └── project_provider.dart          # Модификация логики проверок
│   │   └── services/
│   │       └── project_service.dart           # Обновление методов доступности
│   ├── workspace/
│   │   ├── providers/
│   │   │   └── file_explorer_provider.dart    # Интеграция с проектом
│   │   └── services/
│   │       └── workspace_file_service.dart    # Обновление путей файлов
│   └── shared/
│       └── services/
│           └── file_monitor_service.dart      # Новый сервис мониторинга
├── core/
│   ├── services/
│   │   ├── toast_service.dart                 # Использование вместо SnackBar
│   │   └── di/
│   │       └── service_locator.dart           # Регистрация новых сервисов
└── shared/
    ├── models/
    │   └── project.dart                        # Обновление модели проекта
    └── widgets/
        ├── modern_button.dart                  # Использование вместо стандартных
        ├── modern_toast.dart                   # Для уведомлений
        └── custom_styled_dropdown.dart         # Для выпадающих списков
```

**Structure Decision**: Используется существующая структура Flutter проекта с модификацией провайдеров и сервисов в соответствии с архитектурой Feature/Provider.

## Phase 0 Complete: Research

**Status**: ✅ Complete  
**Research File**: [research.md](research.md)

**Key Decisions**:
- Использовать `dart:io` FileSystemEvent streams для мониторинга
- Определить тип проекта через `project.settings['is_folder_project']`
- Синхронизация через файловую блокировку и watch-мониторинг
- Градуированная обработка ошибок по критичности

## Phase 1 Complete: Design & Contracts

**Status**: ✅ Complete  
**Data Model**: [data-model.md](data-model.md)  
**API Contracts**: [contracts/project-service-api.md](contracts/project-service-api.md)  
**Quickstart**: [quickstart.md](quickstart.md)

**Key Design Decisions**:
- Entity: Project с поддержкой файловых/папочных типов
- Services: ProjectService, FileMonitorService, ProjectSyncService
- Error handling: ProjectError с категоризацией по типам
- Event streams: ProjectStatus, FileMonitorEvent, ProjectSyncInfo

## Constitution Check (Post-Design)

*GATE: Must pass before proceeding to implementation*

- [x] Flutter/Dart экосистема: Использование Flutter паттернов и Provider
- [x] Flutter архитектура: Widget/State/Provider разделение с DI
- [x] Локализация: Поддержка русского и английского языков
- [x] Интеграции через API: Использование dio для всех внешних сервисов
- [x] Ручное тестирование: Никаких автоматических тестов, только ручная проверка
- [x] UI-компоненты: Обязательное использование ModernButton, ModernToast, CustomStyledDropdown

**Result**: ✅ All gates passed - ready for implementation phase

## Complexity Tracking

*No violations - all requirements align with NovaSpec constitution*

| Aspect | Complexity | Justification |
|--------|------------|---------------|
| File Monitoring | Medium | Использование нативных Dart streams |
| Multi-Instance Sync | Medium | File-based locking mechanism |
| Error Handling | Low-Medium | Категоризация по стандартным паттернам |
| UI Integration | Low | Использование существующих компонентов |

## Next Steps

**Phase 2**: Implementation Planning
- Run `/speckit.tasks` to generate detailed implementation tasks
- Focus on core monitoring functionality first
- Implement error handling and user notifications
- Add multi-instance synchronization
- Manual testing on all target platforms

