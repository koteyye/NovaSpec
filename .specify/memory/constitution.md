<!--
Sync Impact Report:
Version change: 1.1.0 → 1.2.0 (MINOR - corrected architecture principle from MVVM to proper Flutter architecture)

Modified principles:
- Principle III: Replaced MVVM with proper Flutter Widget/Provider architecture
- Principle II: Clarified Flutter ecosystem patterns

Removed sections:
- MVVM references (incorrect for Flutter)

Added sections:
- Proper Flutter Widget/State/Provider architecture guidance
- Widget composition patterns
- Provider usage best practices

Templates requiring updates:
✅ .specify/templates/plan-template.md - Constitution check updated
✅ .specify/templates/spec-template.md - Flutter/Dart requirements updated
✅ .specify/templates/tasks-template.md - Manual testing emphasis maintained

Follow-up TODOs: None - architecture correction completed
-->

# NovaSpec Конституция

## Основные принципы

### I. UI-идентичность (НЕПРИЕМЛЕМЫЙ КОМПРОМИСС)
Flutter/Dart версия приложения должна быть визуально идентична TypeScript референсу в nova-spec-ide-studio-main. Допускаются только минимальные отклонения, обусловленные техническими различиями рендера между платформами. Цветовая схема, стили кнопок, шрифты, расположение элементов должны точно соответствовать референсу.

### II. Flutter/Dart экосистема
Все компоненты должны использовать Flutter паттерны и экосистему. Применять стандартные Flutter виджеты, Stateful/Stateless компоненты, Provider для управления состоянием. Использовать flutter_svg для SVG иконок, file_picker для работы с файлами, dio для HTTP запросов, webview_flutter для Monaco Editor и Swagger UI.

### III. Flutter архитектура с Provider и Dependency Injection
Приложение должно следовать Flutter паттернам с четким разделением на Widget, State, Model слои. Использовать Provider (ChangeNotifier) для управления состоянием и реактивного обновления UI. Все сервисы регистрируются через DI контейнер get_it как singleton для предотвращения потери состояния. Виджеты должны быть переиспользуемыми и следовать принципам композиции.

### IV. Локализация и интернационализация
Поддержка русского и английского языков через flutter_localizations. Все текстовые элементы UI должны поддерживать локализацию. Сообщения об ошибках, диалоги, настройки - всё должно быть локализовано.

### V. Интеграции через API
Все внешние сервисы (AI провайдеры, Confluence, музикация) интегрируются исключительно через REST API с использованием dio. Токены и конфигурация хранятся в SharedPreferences, чувствительные данные в flutter_secure_storage.

### VI. Ручное тестирование (НЕПРИЕМЛЕМЫЙ КОМПРОМИСС)
Никаких автоматических тестов не пишется. Вся функциональность проверяется исключительно пользователем вручную через UI. Unit тесты, widget тесты, integration тесты - запрещены. Фокус на скорости разработки и ручной валидации функциональности.

### VII. Созданные UI-компоненты (ОБЯЗАТЕЛЬНОЕ ИСПОЛЬЗОВАНИЕ)
Все UI элементы должны использовать созданные компоненты из lib/shared/widgets/:
- **ModernButton**: Основной компонент кнопок с иерархией (primary, secondary, tertiary, success, warning, danger)
- **ModernToast**: Система уведомлений с анимацией и вариантами (info, success, warning, error)
- **CustomStyledDropdown**: Выпадающие списки с кастомным дизайном и анимацией
- **CustomTextField**: Поля ввода с валидацией и стилизацией
- **CustomDialog**: Диалоговые окна с единым дизайном

Запрещено создавать стандартные Flutter кнопки/ElevatedButton/TextButton напрямую - всегда использовать ModernButton.

## Технические требования

### Стек технологий
- **Framework**: Flutter 3.x
- **Language**: Dart 3.x  
- **State Management**: Provider (ChangeNotifierProvider)
- **Dependency Injection**: get_it (singleton pattern)
- **HTTP Client**: dio
- **File Operations**: file_picker, dart:io
- **Storage**: SharedPreferences, flutter_secure_storage
- **UI Components**: Material Design 3 + Custom Components
- **Localization**: flutter_localizationsФ
- **WebView**: webview_flutter (Monaco Editor, Swagger UI)
- **Audio**: audioplayers
- **Markdown**: flutter_markdown
- **HTML**: flutter_html
- **SVG**: flutter_svg
- **Caching**: CacheService (memory + file)
- **Toast System**: ModernToast + ToastService

### Обработка ошибок
- **ModernToast**: Для всех уведомлений об успехе/ошибке/предупреждениях
- **CustomDialog**: Для критических ошибок и подтверждений действий
- **Graceful shutdown**: Для длительных операций
- **AppError модель**: Структурированная обработка ошибок с типизацией
- **ErrorHandler**: Централизованная обработка исключений

### Хранение данных
- **SharedPreferences**: настройки приложения, конфигурации, навигационное состояние
- **flutter_secure_storage**: API токены, пароли, чувствительные данные
- **Файловая система**: проекты, шаблоны, кэш
- **CacheService**: кэширование данных в памяти и файлах с TTL
- **File locking**: Механизм блокировки для предотвращения гонок при записи конфигурации

## Процесс разработки

### Кодирование
- Следовать Flutter код стайл гайдам
- Использовать dart format для форматирования
- Все виджеты должны быть переиспользуемыми компонентами в lib/shared/widgets/
- Использовать созданные UI-компоненты вместо стандартных Flutter виджетов
- Provider паттерн (ChangeNotifier) для реактивного состояния
- Widget композиция вместо наследования где возможно
- Singleton DI для сервисов через get_it
- Разделение на StatelessWidget и StatefulWidget по необходимости
- Логирование операций через AppLogger

### Тестирование
Только ручное тестирование через UI. Никаких автоматических тестов не пишется.

### Релизный цикл
Каждый функциональный блок должен быть независимо тестируемым. MVP подход - сначала базовая функциональность, затем расширение.

## Управление

Эта конституция имеет приоритет над всеми другими практиками разработки. Изменения требуют документирования, согласования и плана миграции. Все PR и ревью должны проверять соответствие принципам. Сложность архитектурных решений должна быть обоснована.

**Version**: 1.2.0 | **Ratified**: 2025-10-18 | **Last Amended**: 2025-10-26
