# План реализации: Workspace and Editors Phase 5.1

**Branch**: `008-workspace-editors-phase5` | **Date**: 2025-10-26 | **Spec**: `specs/008-workspace-editors-phase5/spec.md`
**Input**: Спецификация функционала из `/specs/008-workspace-editors-phase5/spec.md`

**Note**: Этот шаблон заполняется командой `/speckit.plan`. См. `.specify/templates/commands/plan.md` для процесса выполнения.

## Summary

Реализация рабочего пространства с тремя панелями: файловый проводник, рабочая область с вкладками, и AI чат заглушка. Поддержка различных типов файлов (markdown, HTML, аудио, OpenAPI, код), операции управления файлами, и визуальное соответствие TypeScript референсу.

## Технический контекст

**Язык/Версия**: Dart 3.x с Flutter 3.x  
**Основные зависимости**: Provider, dio, file_picker, flutter_svg, webview_flutter, monaco_editor, audioplayers, flutter_markdown, flutter_html  
**Хранение**: Файловая система, SharedPreferences для настроек, flutter_secure_storage для токенов  
**Тестирование**: Ручное тестирование через UI (автоматические тесты запрещены)  
**Целевая платформа**: Desktop (Windows, macOS, Linux)  
**Тип проекта**: Desktop приложение на Flutter  
**Цели производительности**: Открытие файлов <1сек, поддержка до 20 вкладок, рендеринг markdown <2сек  
**Ограничения**: Плавная работа на 4GB RAM, минимальная ширина окна как в референсе  
**Масштаб**: Рабочее пространство для проектов с файловой структурой

## Проверка конституции

*GATE: Должно быть пройдено перед Phase 0 исследованием. Повторная проверка после Phase 1 дизайна.*

- [x] UI-идентичность: Соответствие TypeScript референсу в nova-spec-ide-studio-main
- [x] Flutter/Dart экосистема: Использование Flutter паттернов и Provider
- [x] Flutter архитектура: Widget/State/Provider разделение с DI
- [x] Локализация: Поддержка русского и английского языков
- [x] Интеграции через API: Использование dio для всех внешних сервисов
- [x] Ручное тестирование: Никаких автоматических тестов, только ручная проверка
- [x] UI-компоненты: Обязательное использование ModernButton, ModernToast, CustomStyledDropdown

## Project Structure

### Документация (этот функционал)

```
specs/008-workspace-editors-phase5/
├── plan.md              # Этот файл (output команды /speckit.plan)
├── research.md          # Phase 0 output (команда /speckit.plan)
├── data-model.md        # Phase 1 output (команда /speckit.plan)
├── quickstart.md        # Phase 1 output (команда /speckit.plan)
├── contracts/           # Phase 1 output (команда /speckit.plan)
└── tasks.md             # Phase 2 output (команда /speckit.tasks - НЕ создается /speckit.plan)
```

### Исходный код (корень репозитория)

```
lib/
├── features/
│   └── workspace/
│       ├── models/
│       │   ├── workspace_tab.dart
│       │   ├── file_explorer_node.dart
│       │   ├── workspace_panel.dart
│       │   ├── open_file.dart
│       │   ├── context_menu_action.dart
│       │   └── file_operation.dart
│       ├── providers/
│       │   ├── workspace_provider.dart
│       │   ├── file_explorer_provider.dart
│       │   └── tab_provider.dart
│       ├── services/
│       │   ├── file_service.dart
│       │   ├── workspace_service.dart
│       │   └── clipboard_service.dart
│       ├── widgets/
│       │   ├── workspace_screen.dart
│       │   ├── file_explorer.dart
│       │   ├── work_area.dart
│       │   ├── tab_bar.dart
│       │   ├── ai_chat_placeholder.dart
│       │   ├── file_renderers/
│       │   │   ├── markdown_renderer.dart
│       │   │   ├── html_renderer.dart
│       │   │   ├── audio_player.dart
│       │   │   ├── swagger_viewer.dart
│       │   │   └── code_editor.dart
│       │   └── context_menu.dart
│       └── screens/
│           └── workspace_screen.dart
├── shared/
│   ├── widgets/
│   │   ├── modern_button.dart
│   │   ├── modern_toast.dart
│   │   └── custom_styled_dropdown.dart
│   └── services/
│       └── di_container.dart
└── core/
    ├── constants/
    └── utils/
```

**Решение по структуре**: Flutter приложение с feature-based архитектурой. Рабочее пространство реализовано как отдельный feature в lib/features/workspace/ с четким разделением на models, providers, services, widgets.

## Отслеживание сложности

*Заполнять ТОЛЬКО если есть нарушения в конституции, которые должны быть обоснованы*

| Нарушение | Почему необходимо | Более простая альтернатива отклонена потому что |
|-----------|------------------|-----------------------------------------------|
| Нет нарушений | Все требования соответствуют конституции | N/A |

