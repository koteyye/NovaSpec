# Implementation Plan: WebView2 SwaggerUI Integration

**Branch**: `013-webview2-swagger` | **Date**: 02.11.2025 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/specs/013-webview2-swagger/spec.md`

## Summary

Интеграция WebView2 для отображения SwaggerUI с OpenAPI файлами в Windows версии приложения. При открытии файлов yaml/json автоматически открывается SwaggerUI во встроенном компоненте. На других платформах сохраняется текущая реализация. При отсутствии WebView2 показывается заглушка с кнопкой "Открыть в браузере".

## Technical Context

**Language/Version**: Dart 3.x  
**Primary Dependencies**: webview_flutter, dio, Provider, get_it, flutter_localizations  
**Storage**: SharedPreferences для настроек окна, flutter_secure_storage для конфигурации  
**Testing**: Ручное тестирование (автоматические тесты запрещены)  
**Target Platform**: Windows (WebView2), macOS, Linux (стандартный WebView)  
**Project Type**: Mobile/Desktop Flutter приложение  
**Performance Goals**: Открытие SwaggerUI < 2 секунд, загрузка не дольше внешнего браузера +20%  
**Constraints**: Только Flutter экосистема, UI идентичность TypeScript референсу, ручное тестирование  
**Scale/Scope**: Компонент для работы с OpenAPI файлами в рамках существующего приложения

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
│   └── workspace/
│       ├── providers/
│       │   ├── webview_provider.dart          # Новый: управление состоянием WebView
│       │   └── openapi_file_provider.dart     # Новый: обработка OpenAPI файлов
│   ├── services/
│   │   ├── webview2_checker_service.dart  # Новый: проверка наличия WebView2
│   │   └── swagger_server_service.dart    # Существующий: сервер SwaggerUI
│       ├── widgets/
│       │   ├── webview2_container.dart        # Новый: контейнер для WebView2
│       │   ├── webview_container.dart         # Обновление: универсальный контейнер
│       │   └── fallback_webview_widget.dart   # Обновление: существующая заглушка (изменить текст)
│       └── models/
│           ├── webview_state.dart             # Новый: модель состояния WebView
│           └── openapi_file_info.dart         # Новый: модель информации о файле
├── shared/
│   ├── services/
│   │   └── di_container.dart                  # Обновление: регистрация новых сервисов
│   └── widgets/
│       ├── modern_button.dart                 # Существующий: используется для кнопок
│       ├── modern_toast.dart                  # Существующий: для уведомлений
│       └── custom_styled_dropdown.dart        # Существующий: если потребуется
└── core/
    ├── utils/
    │   └── platform_detector.dart             # Обновление: определение платформы
    └── constants/
        └── app_constants.dart                 # Обновление: константы для WebView
```

**Structure Decision**: Используется существующая структура Flutter проекта с добавлением новых компонентов в features/workspace для интеграции WebView2 functionality

## Phase 0: Research Complete ✅

**Research Output**: [research.md](research.md)
- **Decision**: Use `webview_windows` package for native WebView2 integration
- **Key Findings**: WebView2 detection, package architecture, lifecycle management
- **Risk Assessment**: Low-Medium complexity with mitigation strategy

## Phase 1: Design Complete ✅

**Data Model**: [data-model.md](data-model.md)
- Core entities: WebViewState, WebViewWindowState, OpenAPIFileInfo, WebView2Status
- State transitions and persistence strategy defined
- Error handling contracts established

**API Contracts**: [contracts/webview-api.md](contracts/webview-api.md)
- Service interfaces: IWebView2CheckerService, IWebViewContainer (используется существующий SwaggerServerService)
- Event contracts and DTOs defined
- Platform integration points specified

**Quick Start**: [quickstart.md](quickstart.md)
- Step-by-step implementation guide
- Code examples for core components
- Testing checklist and common issues

**Agent Context Updated**: Added WebView2, webview_windows to AGENTS.md

**Correction Applied**: Убрал создание нового SwaggerUIService, используется существующий SwaggerServerService
**Correction Applied**: Заглушка для WebView2 уже существует, нужно только обновить текст

## Complexity Tracking

*No Constitution violations - all requirements align with established principles*

