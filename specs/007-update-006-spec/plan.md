# Implementation Plan: Обновление 006 - Корректировка Z.AI и редизайн Top Bar

**Branch**: `007-update-006-spec` | **Date**: 2025-10-26 | **Spec**: specs/007-update-006-spec/spec.md
**Input**: Feature specification from `/specs/007-update-006-spec/spec.md`

**Note**: This template is filled in by the `/speckit.plan` command. See `.specify/templates/commands/plan.md` for the execution workflow.

## Summary

Корректировка существующей некорректной реализации Z.AI AI провайдера в настройках и редизайн Top Bar для соответствия TypeScript референсу. Основные задачи: исправить неправильную реализацию Z.AI (уже добавлен в список провайдеров, но работает некорректно), добавить правильную модель доступа (Coding Plan/API), исправить валидацию API, обновить Top Bar с новым расположением кнопок и индикаторов.

## Technical Context

**Language/Version**: Dart 3.x, Flutter 3.x  
**Primary Dependencies**: Provider, dio, flutter_secure_storage, flutter_svg, file_picker  
**Storage**: SharedPreferences (настройки), flutter_secure_storage (API ключи)  
**Testing**: Ручное тестирование (автоматические тесты запрещены)  
**Target Platform**: Windows, macOS, Linux (Desktop приложение)  
**Project Type**: Single Flutter проект  
**Performance Goals**: <5 секунд проверка подключения API, <1 секунда сохранение настроек  
**Constraints**: Соответствие TypeScript референсу на 100%, использование только созданных UI компонентов  
**Scale/Scope**: 3 основных экрана (Settings, TopBar, AI Provider), поддержка 2 языков

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
<!--
  ACTION REQUIRED: Replace the placeholder tree below with the concrete layout
  for this feature. Delete unused options and expand the chosen structure with
  real paths (e.g., apps/admin, packages/something). The delivered plan must
  not include Option labels.
-->

```
lib/
├── features/
│   ├── settings/
│   │   ├── widgets/
│   │   │   ├── settings_dialog_content.dart # Исправить Z.AI реализацию
│   │   │   └── settings_dialog.dart
│   └── topbar/
│       └── widgets/
│           └── top_bar.dart                # Редизайн по TypeScript референсу
├── core/
│   ├── providers/
│   │   └── settings_provider.dart         # Исправить Z.AI логику
│   └── services/
│       └── ai_validation_service.dart      # Исправить эндпоинт валидации Z.AI
├── shared/
│   ├── widgets/
│   │   ├── modern_button.dart
│   │   ├── modern_toast.dart
│   │   ├── custom_styled_dropdown.dart
│   │   ├── custom_text_field.dart
│   │   └── custom_dialog.dart
└── l10n/
    ├── app_localizations.dart
    ├── app_localizations_ru.dart
    └── app_localizations_en.dart
```

**Structure Decision**: Single Flutter проект с функциональной архитектурой. Корректировка существующей некорректной реализации Z.AI в settings_provider.dart и ai_validation_service.dart, редизайн top_bar.dart. Z.AI уже добавлен в список провайдеров, но работает неправильно.

## Phase 1 Completion

### Generated Artifacts

✅ **research.md** - Анализ текущей некорректной реализации Z.AI и требований к Top Bar  
✅ **data-model.md** - Модели данных для AI конфигурации (включая Z.AI поля) и Top Bar состояния  
✅ **contracts/zai-api.yaml** - OpenAPI спецификация Z.AI интеграции  
✅ **quickstart.md** - Руководство по корректировке существующего кода  
✅ **Agent context updated** - Обновлен AGENTS.md с новой архитектурой  

### Key Decisions

1. **Z.AI Correction**: Исправить существующую некорректную реализацию (не создавать новую)
2. **Top Bar Redesign**: Обновить структуру для соответствия TypeScript референсу (кнопки слева, индикаторы справа)
3. **Architecture**: Использовать существующую AI конфигурацию с добавлением `zaiAccessType`
4. **UI Components**: Обязательное использование созданных компонентов (ModernButton, ModernToast, CustomStyledDropdown)

### Next Steps

Phase 2: Implementation tasks generation via `/speckit.tasks` command

## Complexity Tracking

*Fill ONLY if Constitution Check has violations that must be justified*

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| Нет нарушений конституции | Все требования соответствуют принципам | Простота архитектуры соответствует требованиям |

