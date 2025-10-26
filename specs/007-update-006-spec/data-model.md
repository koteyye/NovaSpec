# Data Model: Обновление 006 - Корректировка Z.AI и редизайн Top Bar

**Date**: 2025-10-26  
**Feature**: Корректировка существующей Z.AI реализации и редизайн Top Bar

## Сущности

### AIProviderConfiguration (корректировка для Z.AI)

Представляет существующие настройки интеграции с AI провайдерами, требует корректировки для Z.AI.

**Существующие поля**:
- `provider: AIProvider` - Выбранный провайдер (openai, anthropic, zai, ...)
- `apiKey: String` - API ключ для аутентификации
- `baseUrl: String?` - Base URL (опционально)
- `isValid: bool` - Флаг валидности конфигурации
- `lastValidated: DateTime?` - Время последней валидации

**Добавляемые поля для Z.AI**:
- `zaiAccessType: ZAIAccessType?` - Тип доступа (только для Z.AI, уже существует в коде)

**Правила валидации (требуют корректировки)**:
- `apiKey` должен быть не менее 10 символов (уже работает)
- `zaiAccessType` обязателен если `provider == AIProvider.zai` (нужно исправить UI)
- `baseUrl` для Z.AI определяется автоматически на основе `zaiAccessType` (нужно исправить логику)
- `isValid` устанавливается только после успешной валидации API (нужно исправить эндпоинт)

**Переходы состояний**:
- `INVALID → VALID` при успешной проверке подключения (сломано из-за неверного эндпоинта `/user`)
- `VALID → INVALID` при ошибке валидации или изменении настроек (работает)

### TopBarState

Представляет состояние верхней панели приложения.

**Поля**:
- `activeProvider: AIProvider?` - Текущий активный AI провайдер
- `confluenceConnected: bool` - Статус подключения Confluence
- `musicConnected: bool` - Статус подключения музикации
- `musicBalance: double?` - Баланс музикации
- `musicGenre: String?` - Текущий жанр музыки

**Правила обновления**:
- `activeProvider` обновляется при смене провайдера в настройках
- `confluenceConnected` зависит от валидности Confluence конфигурации
- `musicConnected` зависит от валидности музикации конфигурации

### MenuState

Представляет состояние выпадающих меню Top Bar.

**Поля**:
- `fileMenuOpen: bool` - Состояние меню "Файл"
- `settingsMenuOpen: bool` - Состояние меню "Настройки"
- `aboutMenuOpen: bool` - Состояние меню "О программе"

**Правила**:
- Только одно меню может быть открыто одновременно
- Закрытие меню при клике вне его области

### IntegrationStatus

Представляет статус интеграции с внешними сервисами.

**Поля**:
- `service: String` - Название сервиса (z.ai, confluence, music)
- `status: ConnectionStatus` - Статус подключения
- `message: String` - Сообщение о статусе
- `lastChecked: DateTime?` - Время последней проверки

**ConnectionStatus enum**:
- `disconnected` - Не подключено
- `connecting` - Подключение
- `connected` - Подключено
- `error` - Ошибка подключения

## Связи между сущностями

```
AIProviderConfiguration 1..1 IntegrationStatus
TopBarState 1..* IntegrationStatus
MenuState 1..1 TopBarState
```

## Правила хранения данных

### SharedPreferences
- `ai_provider`: String (enum значение)
- `zai_access_type`: String (enum значение, только для Z.AI)
- `ai_base_url`: String (опционально)
- `ai_last_validated`: String (ISO datetime)

### flutter_secure_storage
- `ai_api_key`: String (зашифрованный, для текущего провайдера)
- `confluence_token`: String (зашифрованный)
- `music_api_key`: String (зашифрованный)

## Валидационные правила

### AI Конфигурация (корректировка для Z.AI)
```dart
bool validateAIConfig(AIProvider provider, String apiKey, ZAIAccessType? zaiAccessType) {
  // Минимальная длина API ключа (уже работает)
  if (apiKey.length < 10) return false;
  
  // Специфичная валидация для Z.AI (нужно исправить)
  if (provider == AIProvider.zai) {
    if (zaiAccessType == null) return false;
    // Base URL для Z.AI определяется автоматически (логика есть, но работает неправильно)
  }
  
  return true; // Базовая валидация, полная - через API (нужен фикс эндпоинта)
}
```

### TopBar Состояние
```dart
bool validateTopBarState(TopBarState state) {
  // Хотя бы один провайдер должен быть настроен
  return state.activeProvider != null;
}
```

## События и реакции

### AI События (включая Z.AI)
- `onProviderChanged`: Смена провайдера, очистка специфичных настроек
- `onZaiAccessTypeChanged`: Обновление baseUrl (только для Z.AI)
- `onApiKeyChanged`: Сброс флага валидации
- `onValidationRequested`: Вызов API валидации
- `onValidationSuccess`: Установка isValid = true
- `onValidationError`: Установка isValid = false

### TopBar События
- `onProviderChanged`: Обновление activeProvider
- `onIntegrationStatusChanged`: Обновление соответствующего статуса
- `onMenuToggle`: Переключение состояния меню
- `onMenuDismiss`: Закрытие всех меню

## Локализационные ключи

### Z.AI Интеграция
- `zai_title`: "Z.AI"
- `zai_access_type`: "Тип доступа Z.AI"
- `zai_coding_plan`: "Coding Plan"
- `zai_api`: "API"
- `zai_api_key`: "API Key"
- `zai_base_url`: "Base URL"
- `zai_validation_success`: "Подключение к Z.AI успешно"
- `zai_validation_error`: "Ошибка подключения к Z.AI"

### TopBar
- `topbar_file`: "Файл"
- `topbar_settings`: "Настройки"
- `topbar_about`: "О программе"
- `topbar_new_project`: "Новый проект"
- `topbar_open_project`: "Открыть проект"
- `topbar_save`: "Сохранить"
- `topbar_save_as`: "Сохранить как"
- `topbar_parameters`: "Параметры"
- `topbar_templates`: "Шаблоны"
- `topbar_close`: "Закрыть"

## Обработка ошибок

### AI Ошибки (включая Z.AI)
- `InvalidApiKeyException`: Неверный формат API ключа
- `ConnectionFailedException`: Ошибка подключения к API
- `UnauthorizedException`: Неверный API ключ
- `ServiceUnavailableException`: Сервис недоступен
- `InvalidZAIConfigurationException`: Некорректная конфигурация Z.AI (отсутствует тип доступа)

### TopBar Ошибки
- `MenuStateException`: Некорректное состояние меню
- `ProviderNotConfiguredException`: Провайдер не настроен
- `IntegrationStatusException`: Ошибка получения статуса интеграции