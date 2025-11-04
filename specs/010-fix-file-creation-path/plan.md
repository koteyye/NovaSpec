# Implementation Plan: Исправление пути создания файлов

**Branch**: `010-fix-file-creation-path` | **Date**: 31.10.2025 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/specs/010-fix-file-creation-path/spec.md`

## Summary

Исправление критической проблемы с созданием файлов в неверной директории. Система должна создавать файлы в текущей активной директории проводника файлов, а не в корне репозитория. Решение включает обновление CreateFileDialog для использования FileExplorerProvider.currentDirectory и добавление валидации пути.

## Technical Context

**Language/Version**: Dart 3.x  
**Primary Dependencies**: Flutter 3.x, Provider, file_picker, dio  
**Storage**: Файловая система (проекты и файлы)  
**Testing**: Ручное тестирование через UI (автоматические тесты запрещены)  
**Target Platform**: Flutter (Windows, macOS, Linux)  
**Project Type**: Single Flutter application  
**Performance Goals**: Создание файла не более 2 секунд, мгновенное обновление UI  
**Constraints**: <100MB memory, offline-capable, соответствие TypeScript референсу  
**Scale/Scope**: Одиночные файлы, поддержка до 10 уровней вложенности директорий

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- [x] UI-идентичность: Соответствие TypeScript референсу в nova-spec-ide-studio-main
- [x] Flutter/Dart экосистема: Использование Flutter паттернов и Provider
- [x] Flutter архитектура: Widget/State/Provider разделение с DI
- [x] Локализация: Поддержка русского и английского языков
- [x] Интеграции через API: Использование dio для всех внешних сервисов
- [x] Ручное тестирование: Никаких автоматических тестов, только ручная проверка
- [x] UI-компоненты: Обязательное использование ModernButton, ModernToast, CustomStyledDropdown

**Phase 1 Re-check Status**: ✅ All requirements satisfied
- Data model designed with proper Flutter patterns
- API contracts follow established conventions
- Localization support included
- Custom UI components specified
- Manual testing approach maintained

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
│   ├── workspace/
│   │   ├── widgets/
│   │   │   ├── create_file_dialog.dart    # Основной файл для исправления
│   │   │   └── file_explorer_tree.dart   # Текущая директория
│   │   └── providers/
│   │       ├── file_explorer_provider.dart # Источник текущей директории
│   │       └── workspace_provider.dart     # Управление рабочим пространством
│   └── project/
│       └── providers/
│           └── project_provider.dart       # Контекст проекта
├── shared/
│   ├── services/
│   │   ├── workspace_file_service.dart     # Файловые операции
│   │   └── toast_service.dart               # Уведомления
│   └── widgets/
│       ├── modern_button.dart               # Кастомные кнопки
│       ├── modern_toast.dart                # Система уведомлений
│       └── custom_dialog.dart               # Диалоговые окна
└── core/
    ├── services/
    │   └── get_it.dart                       # DI контейнер
    └── utils/
        └── app_logger.dart                   # Логирование
```

**Structure Decision**: Используется существующая структура Flutter проекта с функциональной организацией. Основные изменения будут в CreateFileDialog и интеграции с FileExplorerProvider.

## Complexity Tracking

*No Constitution violations - all requirements align with established architecture principles.*

