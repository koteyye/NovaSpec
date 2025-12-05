# Implementation Plan: File Format Support and Viewers

**Branch**: `012-workspace-editors-phase5` | **Date**: 2025-11-01 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/specs/012-workspace-editors-phase5/spec.md`

**Note**: This template is filled in by `/speckit.plan` command. See `.specify/templates/commands/plan.md` for execution workflow.

## Summary

Реализация поддержки форматов файлов для рабочей зоны NovaSpec: Markdown/HTML рендеринг и редактирование, аудиоплеер для MP3/WAV, Swagger UI для OpenAPI спецификаций, универсальный редактор кода на базе Monaco Editor. Фокус на просмотре и базовом редактировании файлов без учета уже реализованного управления вкладками.

## Technical Context

**Language/Version**: Dart 3.x  
**Primary Dependencies**: flutter_markdown, flutter_html, audioplayers, webview_flutter, yaml, shelf  
**Storage**: Файловая система (dart:io) + SharedPreferences для настроек  
**Testing**: Ручное тестирование (автоматические тесты запрещены конституцией)  
**Target Platform**: Windows, macOS, Linux (Flutter desktop)  
**Project Type**: Desktop приложение (Flutter)  
**Performance Goals**: <1сек для рендеринга .md/.html, <2сек для загрузки аудио, <3сек для Swagger UI  
**Constraints**: <200мс переключение режимов, <10MB лимит для больших файлов, офлайн-работа  
**Scale/Scope**: Поддержка 5 основных форматов файлов, до 10 одновременных вкладок

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- [x] UI-идентичность: Соответствие TypeScript референсу в nova-spec-ide-studio-main
- [x] Flutter/Dart экосистема: Использование Flutter паттернов и Provider
- [x] Flutter архитектура: Widget/State/Provider разделение с DI
- [x] Локализация: Поддержка русского и английского языков
- [x] Интеграции через API: Использование dio для всех внешних сервисов
- [x] Ручное тестирование: Никаких автоматических тестов, только ручная проверка
- [x] UI-компоненты: Обязательное использование ModernButton, ModernToast, CustomStyledDropdown

## Project Structure

### Documentation (this feature)

```
specs/012-workspace-editors-phase5/
├── plan.md              # Этот файл (результат команды /speckit.plan)
├── research.md          # Результат Phase 0 (команда /speckit.plan)
├── data-model.md        # Результат Phase 1 (команда /speckit.plan)
├── quickstart.md        # Результат Phase 1 (команда /speckit.plan)
├── contracts/           # Результат Phase 1 (команда /speckit.plan)
└── tasks.md             # Результат Phase 2 (команда /speckit.tasks - НЕ создается /speckit.plan)
```

### Source Code (repository root)

```
lib/
├── features/
│   └── workspace/
│       ├── viewers/              # Новые компоненты просмотра файлов
│       │   ├── markdown_viewer.dart
│       │   ├── html_viewer.dart
│       │   ├── audio_player.dart
│       │   ├── swagger_viewer.dart
│       │   └── code_editor.dart
│       ├── services/             # Сервисы для обработки файлов
│       │   ├── markdown_service.dart
│       │   ├── audio_service.dart
│       │   ├── openapi_service.dart
│       │   └── swagger_server_service.dart
│       └── models/               # Модели данных для файлов
│           ├── workspace_file.dart
│           ├── audio_player_state.dart
│           └── openapi_spec.dart
├── shared/
│   ├── widgets/                 # Общие UI компоненты (уже существуют)
│   │   ├── modern_button.dart
│   │   ├── modern_toast.dart
│   │   └── custom_styled_dropdown.dart
│   └── services/               # Общие сервисы
│       └── file_service.dart     # Уже существует
└── core/
    ├── constants/               # Константы приложения
    └── utils/                  # Утилиты
```

**Structure Decision**: Выбрана структура Flutter проекта с разделением на features. Компоненты просмотра файлов размещены в lib/features/workspace/viewers/, сервисы в lib/features/workspace/services/, модели в lib/features/workspace/models/. Используется существующая архитектура с shared widgets и core utilities.

## Complexity Tracking

*Все требования конституции выполнены, нарушений нет*

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| Нет нарушений | - | - |

## Implementation Phases

### Phase 1: Foundation (Day 1-2)
**Goal**: Создать базовые модели и сервисы
- [x] Создать модели данных (WorkspaceFile, AudioPlayerState, OpenAPISpec)
- [x] Реализовать базовые сервисы (MarkdownService, AudioService, OpenAPIService)
- [x] Создать контракты и API интерфейсы
- [x] Настроить зависимости в pubspec.yaml

### Phase 2: Viewer Components (Day 3-4)
**Goal**: Реализовать компоненты просмотра файлов
- [ ] MarkdownViewer с поддержкой редактирования
- [ ] HtmlViewer для HTML файлов
- [ ] AudioPlayer для MP3/WAV с элементами управления
- [ ] SwaggerViewer для OpenAPI спецификаций
- [ ] CodeEditor на базе Monaco Editor

### Phase 3: Integration (Day 5)
**Goal**: Интегрировать компоненты в существующую рабочую зону
- [ ] Обновить WorkspaceProvider для поддержки новых viewers
- [ ] Реализовать определение типа файла и выбор viewer
- [ ] Добавить обработку ошибок через ModernToast
- [ ] Настроить переключение между режимами просмотра

### Phase 4: Testing & Polish (Day 6)
**Goal**: Ручное тестирование и финализация
- [ ] Протестировать все форматы файлов
- [ ] Проверить производительность
- [ ] Исправить баги и оптимизировать
- [ ] Обновить документацию

## Dependencies Analysis

### Required Dependencies
```yaml
dependencies:
  flutter_markdown: ^0.6.18      # Markdown rendering
  flutter_html: ^3.0.0-beta.2    # HTML rendering  
  audioplayers: ^5.2.1           # Audio playback
  webview_flutter: ^4.4.2        # Monaco Editor & Swagger UI
  yaml: ^3.1.2                   # OpenAPI spec parsing
  shelf: ^1.4.1                  # Local server for Swagger
  shelf_static: ^1.1.2           # Static file serving
```

### Existing Dependencies to Use
- `provider` - State management
- `dio` - HTTP requests (if needed)
- `file_picker` - File operations
- `shared_preferences` - Settings
- `flutter_secure_storage` - Sensitive data

## Risk Assessment

### High Risk
- **Monaco Editor Integration**: WebView может быть сложным в настройке
- **Audio Performance**: Большие аудиофайлы могут тормозить UI

### Medium Risk  
- **HTML Security**: Нужно санитизировать HTML контент
- **Memory Management**: Множественные viewers могут потреблять много памяти
- **File Type Detection**: Корректное определение форматов файлов
- **Swagger Server Integration**: Локальный сервер должен запускаться фоново при старте приложения

### Low Risk
- **Markdown Rendering**: Хорошо поддерживается flutter_markdown
- **Basic UI Integration**: Использование существующих компонентов

## Success Metrics

### Functional Metrics
- [ ] Поддержка 5 форматов файлов (Markdown, HTML, Audio, OpenAPI, Code)
- [ ] Успешная загрузка и отображение тестовых файлов
- [ ] Работающие элементы управления для каждого типа
- [ ] Корректная обработка ошибок

### Performance Metrics
- [ ] Markdown (<1MB): <500ms загрузка
- [ ] HTML (<2MB): <750ms загрузка
- [ ] Audio (<50MB): <2сек начало воспроизведения
- [ ] Swagger UI (<5MB): <3сек загрузка
- [ ] Memory usage: <200MB для всех viewers

### User Experience Metrics
- [ ] Плавные переключения между файлами
- [ ] Интуитивные элементы управления
- [ ] Правильные сообщения об ошибках на русском языке
- [ ] Соответствие TypeScript референсу

## Phase 1 Completion Checklist

### Documentation ✅
- [x] spec.md - Feature specification
- [x] research.md - Technical research results  
- [x] data-model.md - Data models specification
- [x] plan.md - Implementation plan (этот файл)
- [x] contracts/ - API contracts and interfaces
- [x] quickstart.md - Quick start guide

### Ready for Phase 2
- [x] All research completed
- [x] Data models defined
- [x] API contracts created
- [x] Implementation plan ready
- [x] Dependencies identified
- [x] Risks assessed

---

**Phase 1 Status**: ✅ COMPLETED  
**Next Action**: Execute `/speckit.tasks` to generate task breakdown  
**Constitution Check**: ✅ PASSED - No violations detected

