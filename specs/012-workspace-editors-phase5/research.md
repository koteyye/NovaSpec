# Research Results: File Format Support and Viewers

**Date**: 2025-11-01  
**Feature**: File Format Support and Viewers  
**Research Focus**: Flutter desktop file viewers implementation

## Markdown Rendering

**Decision**: Использовать flutter_markdown_plus (вместо устаревшего flutter_markdown)  
**Rationale**: flutter_markdown discontinued, flutter_markdown_plus поддерживает актуальную версию Flutter и имеет дополнительные возможности  
**Alternatives considered**: 
- flutter_markdown (discontinued)
- custom markdown parser (слишком сложно)
- webview для markdown (избыточно)

**Implementation Notes**:
- Включить `selectable: true` для desktop
- Использовать кастомный `MarkdownStyleSheet` для соответствия дизайну
- Поддержка GitHub flavored markdown через extension set
- Ограничение размера документов до 1MB для производительности

## HTML Rendering

**Decision**: Использовать flutter_html с белым списком безопасных тегов  
**Rationale**: Безопасность и контроль над отображением контента  
**Alternatives considered**:
- webview для HTML (избыточно и медленно)
- flutter_html без ограничений (небезопасно)
- custom HTML parser (слишком сложно)

**Implementation Notes**:
- Белый список тегов: p, h1-h6, strong, em, u, code, pre, blockquote, ul, ol, li, a, img, table, tr, td, th
- Безопасный переход по ссылкам через url_launcher
- Кастомные стили для соответствия дизайну приложения

## Audio Player

**Decision**: Использовать audioplayers с Provider для управления состоянием  
**Rationale**: Надежность, кроссплатформенность, простота управления  
**Alternatives considered**:
- just_audio (больше возможностей, но сложнее)
- custom audio implementation (избыточно)
- webview для аудио (плохая производительность)

**Implementation Notes**:
- Минималистичный UI с play/pause и seek controls
- Provider для глобального управления состоянием
- Поддержка MP3/WAV форматов
- Обработка состояний воспроизведения и ошибок

## Monaco Editor Integration

**Decision**: Использовать webview_flutter с локальной загрузкой Monaco Editor  
**Rationale**: Полноценный редактор кода с подсветкой синтаксиса  
**Alternatives considered**:
- flutter_code_editor (ограниченные возможности)
- custom code editor (слишком сложно)
- text field без подсветки (плохой UX)

**Implementation Notes**:
- Локальная загрузка Monaco Editor ресурсов
- JavaScript каналы для двусторонней связи
- Debounce изменений для оптимизации
- Поддержка различных языков программирования

## Swagger UI

**Decision**: Использовать webview_flutter + shelf HTTP сервер  
**Rationale**: Интерактивная документация с полным функционалом Swagger UI  
**Alternatives considered**:
- custom OpenAPI viewer (ограниченный функционал)
- внешние сервисы (требует интернет)
- статическая генерация (неинтерактивно)

**Implementation Notes**:
- Фоновый HTTP сервер запускается при старте приложения
- Использует случайный свободный порт
- Отдача swagger.json и Swagger UI HTML
- Автоматическая остановка сервера при закрытии приложения
- Пользователь не знает о работе сервера - просто видит WebView

## YAML/JSON Validation

**Decision**: Использовать yaml пакет + dart:convert с кастомной валидацией OpenAPI  
**Rationale**: Простота и надежность парсинга  
**Alternatives considered**:
- custom parsers (избыточно)
- webview для валидации (медленно)
- без валидации (плохой UX)

**Implementation Notes**:
- Валидация синтаксиса YAML/JSON
- Проверка структуры OpenAPI (openapi, info, paths)
- Детальные сообщения об ошибках
- Подсветка ошибок в редакторе

## Performance Considerations

**Decision**: Ленивая загрузка и кэширование для всех компонентов  
**Rationale**: Оптимальная производительность для desktop приложения  
**Implementation Strategy**:
- Кэширование отрендеренных документов
- Потоковая обработка больших файлов
- Регулярная очистка неиспользуемых ресурсов
- Асинхронные операции с файлами
- Индикаторы загрузки для длительных операций

## Security Considerations

**Decision**: Белые списки и валидация для всех внешних данных  
**Rationale**: Защита от XSS и уязвимостей  
**Implementation Strategy**:
- Белый список HTML тегов
- Валидация YAML/JSON перед обработкой
- Безопасный переход по ссылкам
- Ограничение доступа к локальным ресурсам

## Conclusion

Все выбранные решения соответствуют Flutter экосистеме, обеспечивают необходимую функциональность и производительность для desktop приложения. Решения основаны на проверенных библиотеках и лучших практиках Flutter разработки.