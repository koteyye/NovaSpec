# Implementation Plan: Настройки и интеграции

**Branch**: `006-settings-integrations` | **Date**: 2025-10-23 | **Spec**: requirements.md
**Input**: Feature specification from requirements.md - окно настроек с провайдерами, Confluence, музикацией

**Note**: This template is filled in by the `/speckit.plan` command. See `.specify/templates/commands/plan.md` for the execution workflow.

## Summary

Реализация окна настроек (Настройки -> Параметры) с конфигурацией AI-провайдеров, интеграцией Confluence, генерацией музыки через gen-api.ru, управлением языком интерфейса. Использование Provider паттерна для управления состоянием, flutter_secure_storage для API ключей, dio для HTTP запросов, и кастомных UI компонентов (ModernButton, ModernToast, CustomStyledDropdown) в соответствии с TypeScript референсом.

## Technical Context

**Language/Version**: Dart 3.x / Flutter 3.x  
**Primary Dependencies**: Provider, dio, flutter_secure_storage, shared_preferences, get_it, file_picker, flutter_svg, webview_flutter, audioplayers, flutter_markdown, flutter_html, eventsource  
**Storage**: SharedPreferences (общие настройки), flutter_secure_storage (API ключи), файловая система (проекты, шаблоны)  
**Testing**: Ручное тестирование через UI (автоматические тесты запрещены)  
**Target Platform**: Windows, macOS, Linux (Desktop приложение)  
**Project Type**: Single Flutter проект с feature-based структурой  
**Performance Goals**: <200ms загрузка настроек, <1сек переключение языка, <2сек валидация API  
**Constraints**: Офлайн-работа для настроек, шифрование чувствительных данных, валидация перед сохранением  
**Scale/Scope**: 9 AI провайдеров, 2 типа Confluence, 8 жанров музыки, 2 языка интерфейса

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- [x] UI-идентичность: Соответствие TypeScript референсу в nova-spec-ide-studio-main
- [x] Flutter/Dart экосистема: Использование Flutter паттернов и Provider
- [x] MVVM архитектура: Четкое разделение View/ViewModel/Model с DI
- [x] Локализация: Поддержка русского и английского языков
- [x] Интеграции через API: Использование dio для всех внешних сервисов
- [x] Ручное тестирование: Никаких автоматических тестов, только ручная проверка
- [x] UI-компоненты: Обязательное использование ModernButton, ModernToast, CustomStyledDropdown

**Phase 1 Design Review**: All requirements satisfied with proper Flutter/Dart patterns, comprehensive API integration design, and full localization support.

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
│   └── settings/
│       ├── screens/
│       │   └── settings_screen.dart
│       ├── widgets/
│       │   ├── api_key_section.dart
│       │   ├── ai_provider_card.dart
│       │   ├── confluence_config_widget.dart
│       │   └── music_config_widget.dart
│       ├── providers/
│       │   └── settings_provider.dart
│       └── models/
│           ├── settings_model.dart
│           ├── ai_provider_config.dart
│           ├── confluence_config.dart
│           └── music_config.dart
├── core/
│   ├── services/
│   │   ├── api_service.dart
│   │   ├── confluence_service.dart
│   │   ├── secure_storage_service.dart
│   │   └── validation_service.dart
│   └── di/
│       └── service_locator.dart
└── shared/
    └── widgets/
        ├── modern_button.dart
        ├── modern_toast.dart
        ├── custom_styled_dropdown.dart
        └── custom_text_field.dart
```

**Structure Decision**: Feature-based структура с MVVM паттерном. Settings feature в lib/features/settings/ с выделением screens, widgets, providers, models. Core сервисы в lib/core/, переиспользуемые UI компоненты в lib/shared/widgets/.

## Complexity Tracking

*No constitution violations - all requirements satisfied with standard Flutter patterns*

## Статус

**Текущая фаза**: Планирование завершено, готовность к реализации  
**Прогресс**: 15% - Фаза планирования завершена  
**Следующий шаг**: Начало Фазы 1 - Подготовка архитектуры (создание структуры проекта)

### Важное замечание:
**ИСПОЛЬЗОВАТЬ СУЩЕСТВУЮЩИЙ ЭКРАН**: `lib/features/settings/screens/settings_screen.dart` уже существует с базовой структурой из 3 вкладок (AI Провайдеры, Интеграции, Общие). Нужно расширить его функционал, а не создавать новый.

### Завершенные этапы:
- [x] Анализ требований и исследование
- [x] Проектирование архитектуры  
- [x] Создание моделей данных
- [x] Определение API контрактов
- [x] Создание задач реализации (tasks.md)
- [x] Подготовка чеклиста (checklists/implementation.md)
- [x] Анализ существующего кода (SettingsScreen, SettingsProvider, виджеты)

### Следующие этапы:
- [ ] Фаза 1: Расширение существующего SettingsProvider + настройка DI (1 день)
- [ ] Фаза 2: Реализация сервисов валидации (2-3 дня)
- [ ] Фаза 3: Обновление существующих виджетов (2-3 дня)
- [ ] Фаза 4: Добавление новой функциональности + конституционные компоненты (3-4 дня)
- [ ] Фаза 5: Интеграция и навигация (1 день)
- [ ] Фаза 6: Ручное тестирование + кросплатформа (2-3 дня)
- [ ] Фаза 7: Финализация (1 день)

