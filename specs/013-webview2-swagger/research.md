# Research: WebView2 SwaggerUI Integration

**Date**: 02.11.2025  
**Feature**: WebView2 SwaggerUI Integration  
**Research Focus**: WebView2 integration in Flutter for Windows

## Decision: Use webview_windows package for native WebView2 integration

**Rationale**: 
- Проект уже имеет `webview_windows` как зависимость
- Предоставляет нативную поддержку WebView2 на Windows
- Лучше интегрируется с Windows ecosystem чем webview_flutter
- Позволяет более тонкую настройку и обработку ошибок

**Alternatives considered**:
- `webview_flutter` - текущий выбор, но ограничен на Windows
- `flutter_inappwebview` - альтернативный вариант, но более сложный
- Внешний браузер - текущий fallback, но плохой UX

## Technical Findings

### 1. WebView2 Detection
- **Primary method**: `WebviewController.getWebViewVersion()` из `webview_windows`
- **Fallback method**: Проверка реестра Windows через `win32` пакет
- **Implementation**: Создать `WebView2CheckerService` с комплексной проверкой

### 2. Package Architecture
- **Windows**: `webview_windows` для нативного WebView2
- **Other platforms**: `webview_flutter` (текущая реализация)
- **Abstraction**: Создать интерфейс `IWebViewContainer` с платформенными реализациями

### 3. SwaggerUI Integration
- **Existing infrastructure**: `SwaggerServerService` уже существует
- **File handling**: Использовать существующую логику для OpenAPI файлов
- **Virtual host mapping**: Настроить для локальных файлов в WebView2

### 4. Lifecycle Management
- **Provider pattern**: Создать `WebViewProvider` с ChangeNotifier
- **Resource management**: Правильный dispose() в StatefulWidget
- **State persistence**: Сохранение состояния окна в SharedPreferences

### 5. Error Handling & Fallback
- **Pre-flight checks**: Проверка WebView2 перед открытием файлов
- **Graceful degradation**: Fallback на внешний браузер при отсутствии WebView2
- **User communication**: ModernToast для уведомлений об ошибках

## Implementation Strategy

### Phase 1: Infrastructure
1. Создать `WebView2CheckerService` для проверки наличия WebView2
2. Создать абстракцию `IWebViewContainer` с двумя реализациями
3. Обновить DI контейнер с новыми сервисами

### Phase 2: UI Components
1. Создать `WebView2Container` для Windows
2. Обновить `WebViewContainer` для других платформ
3. Создать `FallbackWebViewWidget` для отсутствия WebView2

### Phase 3: Integration
1. Интегрировать с существующим `OpenAPIFileHandler`
2. Обновить провайдеры для управления состоянием
3. Настроить сохранение состояния между сессиями

## Dependencies Analysis

### Current Dependencies
- `webview_windows: ^0.2.2` - уже добавлен в pubspec.yaml
- `webview_flutter: ^4.4.2` - используется для других платформ
- `provider: ^6.0.5` - для управления состоянием
- `get_it: ^7.2.0` - для dependency injection

### Additional Requirements
- `win32: ^5.0.6` - для проверки реестра Windows (fallback)
- Нет дополнительных зависимостей для базовой функциональности

## Risk Assessment

### Low Risk
- WebView2 detection (well-documented APIs)
- Integration with existing SwaggerServerService
- Provider pattern implementation

### Medium Risk
- Cross-platform abstraction complexity
- State management between sessions
- Error handling edge cases

### Mitigation Strategy
- Поэтапная реализация с тестированием каждого компонента
- Использование существующих паттернов из проекта
- Обширное ручное тестирование на разных Windows конфигурациях

## Performance Considerations

- **Startup time**: Проверка WebView2 добавляет ~100ms
- **Memory usage**: WebView2 более эффективен чем внешний браузер
- **Loading time**: Должен быть быстрее чем внешний браузер
- **Resource management**: Правильный dispose для предотвращения утечек

## Conclusion

Рекомендуется использовать `webview_windows` для нативной интеграции WebView2 на Windows с сохранением текущей реализации для других платформ. Это обеспечит лучший пользовательский опыт и соответствие требованиям спецификации.