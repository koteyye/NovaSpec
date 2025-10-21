# Data Model: Фаза 2 - Базовая архитектура и ядро

**Created**: 2025-10-19  
**Purpose**: Определение моделей данных для базовой архитектуры приложения

## Core Entities

### AppConfiguration

Модель для хранения настроек приложения.

```dart
class AppConfiguration {
  final String language;           // 'ru' | 'en'
  final String theme;              // 'light' | 'dark' | 'system'
  final bool autoSave;             // Автосохранение настроек
  final bool notificationsEnabled; // Уведомления
  final String lastOpenedProject;  // Путь к последнему проекту
  
  const AppConfiguration({
    required this.language,
    required this.theme,
    required this.autoSave,
    required this.notificationsEnabled,
    this.lastOpenedProject,
  });
}
```

**Validation Rules**:
- language: должен быть 'ru' или 'en'
- theme: должен быть 'light', 'dark' или 'system'
- lastOpenedProject: опциональный, должен быть валидным путем если указан

### NavigationState

Модель для управления состоянием навигации.

```dart
class NavigationState {
  final String currentRoute;       // Текущий маршрут
  final List<String> history;      // История навигации
  final Map<String, dynamic> parameters; // Параметры маршрута
  
  const NavigationState({
    required this.currentRoute,
    required this.history,
    required this.parameters,
  });
}
```

**Validation Rules**:
- currentRoute: не должен быть пустым
- history: не должен содержать дубликатов
- parameters: может быть пустым

### UIComponentState

Базовая модель для состояния UI компонентов.

```dart
class UIComponentState {
  final bool isLoading;           // Состояние загрузки
  final bool isEnabled;           // Активность компонента
  final String? error;            // Текст ошибки
  final Map<String, dynamic> data; // Данные компонента
  
  const UIComponentState({
    this.isLoading = false,
    this.isEnabled = true,
    this.error,
    this.data = const {},
  });
}
```

**Validation Rules**:
- error: опциональный, если указан не должен быть пустым
- data: может быть пустым

## Service Models

### StorageResult

Результат операции хранения данных.

```dart
class StorageResult<T> {
  final bool success;             // Успешность операции
  final T? data;                  // Данные если успешно
  final String? error;            // Ошибка если неуспешно
  
  const StorageResult({
    required this.success,
    this.data,
    this.error,
  });
}
```

### FileOperationResult

Результат файловой операции.

```dart
class FileOperationResult {
  final bool success;             // Успешность операции
  final String? filePath;         // Путь к файлу если успешно
  final String? error;            // Ошибка если неуспешно
  final int? fileSize;            // Размер файла если применимо
  
  const FileOperationResult({
    required this.success,
    this.filePath,
    this.error,
    this.fileSize,
  });
}
```

## Error Models

### AppError

Базовая модель ошибок приложения.

```dart
class AppError {
  final String code;              // Код ошибки
  final String message;           // Сообщение для пользователя
  final String? technicalDetails; // Технические детали
  final ErrorSeverity severity;   // Уровень критичности
  final DateTime timestamp;       // Время возникновения
  
  const AppError({
    required this.code,
    required this.message,
    this.technicalDetails,
    required this.severity,
    required this.timestamp,
  });
}

enum ErrorSeverity {
  info,     // Информационное сообщение
  warning,  // Предупреждение
  error,    // Ошибка
  critical  // Критическая ошибка
}
```

### ValidationError

Модель ошибок валидации.

```dart
class ValidationError {
  final String field;             // Поле с ошибкой
  final String message;           // Сообщение об ошибке
  final dynamic value;            // Значение вызвавшее ошибку
  
  const ValidationError({
    required this.field,
    required this.message,
    required this.value,
  });
}
```

## Configuration Models

### ApiConfiguration

Модель конфигурации API.

```dart
class ApiConfiguration {
  final String baseUrl;           // Базовый URL
  final Duration timeout;         // Таймаут запросов
  final Map<String, String> headers; // Заголовки по умолчанию
  final bool enableLogging;       // Включить логирование
  
  const ApiConfiguration({
    required this.baseUrl,
    this.timeout = const Duration(seconds: 30),
    this.headers = const {},
    this.enableLogging = false,
  });
}
```

### ThemeConfiguration

Модель конфигурации темы.

```dart
class ThemeConfiguration {
  final String primaryColor;      // Основной цвет
  final String secondaryColor;    // Вторичный цвет
  final String backgroundColor;   // Цвет фона
  final String surfaceColor;      // Цвет поверхности
  final String errorColor;        // Цвет ошибки
  final double borderRadius;      // Радиус скругления
  final String fontFamily;        // Шрифт
  
  const ThemeConfiguration({
    required this.primaryColor,
    required this.secondaryColor,
    required this.backgroundColor,
    required this.surfaceColor,
    required this.errorColor,
    this.borderRadius = 8.0,
    this.fontFamily = 'Roboto',
  });
}
```

## State Management Models

### ViewState

Модель состояния представления.

```dart
class ViewState<T> {
  final ViewStateStatus status;   // Статус состояния
  final T? data;                  // Данные
  final String? error;            // Ошибка
  final bool isLoading;           // Флаг загрузки
  
  const ViewState({
    this.status = ViewStateStatus.idle,
    this.data,
    this.error,
    this.isLoading = false,
  });
}

enum ViewStateStatus {
  idle,      // Бездействие
  loading,   // Загрузка
  success,   // Успех
  error,     // Ошибка
}
```

## Data Relationships

```
AppConfiguration
├── ThemeConfiguration (вложенная)
├── ApiConfiguration (вложенная)
└── StorageResult (результат сохранения)

NavigationState
├── UIComponentState (для каждого экрана)
└── ViewState (для управления состоянием)

AppError
├── ValidationError (наследуется)
└── FileOperationResult (использует)
```

## Data Flow

1. **Initialization**: AppConfiguration загружается из хранилища
2. **Navigation**: NavigationState обновляется при переходах
3. **UI Updates**: UIComponentState управляет состоянием компонентов
4. **Error Handling**: AppError централизованно обрабатывает ошибки
5. **Persistence**: StorageResult возвращает результат сохранения

## Validation Strategy

1. **Input Validation**: Проверка данных перед сохранением
2. **State Validation**: Валидация состояния перед обновлением UI
3. **Configuration Validation**: Проверка конфигурации при загрузке
4. **Error Validation**: Валидация ошибок перед отображением

## Serialization

Все модели поддерживают сериализацию/десериализацию:
- JSON для хранения в SharedPreferences
- Map для передачи между слоями
- String для логирования и отладки