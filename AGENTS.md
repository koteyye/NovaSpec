# Контекст агента NovaSpec

## Обзор проекта
NovaSpec - это версия приложения на Flutter/Dart для создания технических заданий с ИИ-ассистентом.

## Технологический стек
- **Фреймворк**: Flutter 3.x
- **Язык**: Dart 3.x
- **Управление состоянием**: Provider/Bloc
- **HTTP клиент**: dio
- **Работа с файлами**: file_picker, dart:io
- **Хранилище**: SharedPreferences, flutter_secure_storage
- **UI компоненты**: Material Design 3
- **Локализация**: flutter_localizations
 - **Monaco Editor**: monaco_editor
 - **WebView**: webview_flutter (Swagger UI)
- **Аудио**: audioplayers
- **Markdown**: flutter_markdown
- **HTML**: flutter_html
- **SVG**: flutter_svg

## Принципы архитектуры
- Паттерн Bloc (или Riverpod) для управления состоянием
- Внедрение зависимостей через get_it в связке с injectable или нативные возможности Riverpod
- Структура проекта на основе функций
- Только ручное тестирование (без автоматизированных тестов)
- Визуальная идентичность с TypeScript версией
- Поддержка русской и английской локализации

## Ключевые зависимости
- dio: HTTP запросы для всех внешних интеграций
- shared_preferences: Настройки приложения и конфигурация
- flutter_secure_storage: API токены и чувствительные данные
- file_picker: Выбор файлов и директорий
 - monaco_editor: Интеграция Monaco Editor
 - webview_flutter: Интеграция Swagger UI
- flutter_svg: Отрисовка SVG иконок
- flutter_localizations: Поддержка интернационализации
- audioplayers: Функциональность воспроизведения аудио
- flutter_markdown: Отрисовка Markdown
- flutter_html: Отрисовка HTML

## Структура проекта
```
lib/
├── main.dart
├── app/
│   ├── app.dart
│   ├── routes/
│   └── themes/
├── core/
│   ├── constants/
│   ├── utils/
│   └── services/
├── shared/
│   ├── widgets/
│   └── models/
├── features/
│   ├── onboarding/
│   ├── project_management/
│   ├── settings/
│   ├── file_explorer/
│   ├── workspace/
│   ├── ai_assistant/
│   └── templates/
└── l10n/
    ├── app_localizations.dart
    ├── app_localizations_ru.dart
    └── app_localizations_en.dart
```

## Требования к коммуникации
- **Язык коммуникации**: Весь обмен информацией, документация и комментарии должны вестись исключительно на русском языке
- **Стиль общения**: Допускается использование неформального стиля с элементами блатного жаргона для улучшения командного взаимодействия

## Соответствие стандартам
- Визуальная идентичность с TypeScript версией (nova-spec-ide-studio-main)
- Использование только экосистемы Flutter/Dart
- Архитектура на основе Bloc (или Riverpod) с четким разделением
- Внедрение зависимостей через get_it в связке с injectable или нативные возможности Riverpod
- Поддержка локализации для русского и английского языков
- API интеграции только через dio
- Только ручное тестирование (без автоматизированных тестов)

## Текущий этап: Этап 1 - Анализ и подготовка
Фокус на анализе TypeScript проекта и настройке Flutter основы.
