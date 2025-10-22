# Data Model: Settings and Integrations

**Date**: 2025-10-23  
**Feature**: Settings and Integrations (Phase 4)  
**Status**: Complete

## Entity Overview

### 1. Settings (Root Entity)
Основная сущность настроек приложения, агрегирующая все конфигурации.

```dart
class Settings {
  final String id;
  final String language; // 'en' | 'ru'
  final bool darkMode;
  final bool notificationsEnabled;
  final DateTime lastModified;
  final AIProviderConfig? aiProvider;
  final ConfluenceConfig? confluenceConfig;
  final MusicConfig? musicConfig;
  
  // Validation rules
  static const List<String> supportedLanguages = ['en', 'ru'];
  static const int maxAIProviders = 1; // Только один провайдер одновременно
}

enum AIProviderType {
  openai,
  openaiCompetitive,
  anthropic,
  cerebras,
  groq,
  lmStudio,
  ollama,
  openrouter,
}
```

**Validation Rules:**
- language: должен быть в списке поддерживаемых языков
- aiProvider: только один провайдер может быть активен
- lastModified: автоматически обновляется при изменениях

### 2. AIProviderConfig
Конфигурация AI-провайдера для генерации контента.

```dart
class AIProviderConfig {
  final String id;
  final AIProviderType provider;
  final String apiKey;
  final String? baseUrl; // для OpenAI Competitive, LM Studio, Ollama
  final String? model;
  final Map<String, dynamic> parameters;
  final bool isEnabled;
  final DateTime createdAt;
  final DateTime? lastValidated;
  final bool isValid;
  
  // Validation rules
  static const Map<AIProviderType, List<String>> supportedModels = {
    AIProviderType.openai: ['gpt-4o', 'gpt-3.5-turbo'],
    AIProviderType.anthropic: ['claude-3-5-sonnet-20240620', 'claude-3-opus'],
    AIProviderType.cerebras: ['llama-4-scout-17b-16e-instruct'],
    AIProviderType.groq: ['openai/gpt-oss-20b'],
    AIProviderType.openrouter: ['openai/gpt-4o-mini'],
    AIProviderType.openaiCompetitive: [], // зависит от провайдера
    AIProviderType.lmStudio: [], // зависит от загруженных моделей
    AIProviderType.ollama: [], // зависит от загруженных моделей
  };
  
  static const Map<AIProviderType, String> defaultBaseUrls = {
    AIProviderType.openai: 'https://api.openai.com/v1',
    AIProviderType.anthropic: 'https://api.anthropic.com/v1',
    AIProviderType.cerebras: 'https://api.cerebras.ai/openai/v1',
    AIProviderType.groq: 'https://api.groq.com/openai/v1',
    AIProviderType.openrouter: 'https://openrouter.ai/api/v1',
  };
}
```

**Validation Rules:**
- apiKey: обязательное поле, формат зависит от провайдера
- model: должен быть в списке поддерживаемых для провайдера
- baseUrl: обязателен для OpenAI Competitive, LM Studio, Ollama
- parameters: валидация JSON схемы для каждого провайдера
- isValid: обновляется после успешной валидации API

### 3. ConfluenceConfig
Настройки подключения к Confluence Cloud или Data Center.

```dart
class ConfluenceConfig {
  final String id;
  final ConfluenceType type; // enum: cloud, dataCenter
  final String url;
  final String? email;
  final String? token;
  final bool isEnabled;
  final DateTime? lastConnected;
  final bool isConnected;
  final ConfluenceConnectionStatus status;
  
  // Validation rules
  static const RegExp urlRegex = RegExp(r'^https?://[^\s/$.?#].[^\s]*$');
  static const int maxUrlLength = 2048;
}

enum ConfluenceType { cloud, dataCenter }
enum ConfluenceConnectionStatus {
  disconnected,
  connecting,
  connected,
  error,
  unauthorized
}

class ConfluenceSpace {
  final int id;
  final String key;
  final String name;
  final String type;
  final String? description;
}
```

**Validation Rules:**
- url: обязательный, валидный URL, HTTPS предпочтительно
- type: автоматически определяется по URL при возможности
- email: обязательный для Data Center
- token: обязательный для всех типов
- cloudId: обязательный для Cloud после подключения

### 4. MusicConfig
Настройки генерации музыки через gen-api.ru.

```dart
class MusicConfig {
  final String id;
  final String apiKey;
  final String genre; // системное название жанра: 'pop', 'russian rap', 'rock', etc.
  final bool isEnabled;
  final DateTime? lastGenerated;
  final int generationCount;
  final int? balance; // баланс в рублях из API
  
  // Validation rules
  static const Map<String, String> supportedGenres = {
    'Поп': 'pop',
    'Русский рэп': 'russian rap', 
    'Рок': 'rock',
    'Джаз': 'jazz',
    'Классика': 'classic',
    'Электронная музыка': 'electric music',
    'Хип-хоп': 'hip-hop',
    'R&B': 'r&b',
  };
  static const int maxGenerationCountPerDay = 100;
}

enum MusicGenerationStatus {
  processing,
  success, 
  failed,
  cancelled
}

class MusicGenerationRequest {
  final int requestId;
  final String model; // 'suno'
  final MusicGenerationStatus status;
  final int? cost;
  final int? progress;
  final List<String>? result; // download URLs
  final String? errorMessage;
  final DateTime createdAt;
  final String? title;
  final String? lyrics;
  final String? genre;
}
```

**Validation Rules:**
- apiKey: обязательный, формата Bearer token для gen-api.ru
- genre: должен быть в списке поддерживаемых жанров
- generationCount: лимит на количество генераций в день
- balance: обновляется через API /api/v1/user

## State Transitions

### AI Provider Configuration
```
Created → Validating → Valid/Invalid → Enabled/Disabled
    ↓         ↓           ↓            ↓
  Error ←  Error ←  Re-validating ← Updating
```

### Confluence Connection
```
Configured → Connecting → Connected → Ready
     ↓          ↓          ↓         ↓
   Error ←   Error ←   Error ←  Disconnected
```

### Music Generation (gen-api.ru)
```
Configured → Generate Lyrics → Suno Generation → Processing → Success/Failed
     ↓              ↓                ↓              ↓             ↓
   Error ←        Error ←          Error ←      Check Status ← Download Files
```

**Sunno Generation Flow:**
1. POST /api/v1/networks/suno → получить request_id
2. GET /api/v1/request/get/{requestId} → проверять статус каждые 2 секунды  
3. При status = "success" → скачать файлы из result массива
4. Обновить баланс через GET /api/v1/user

## Data Relationships

```
Settings (1) ──── (0..1) AIProviderConfig
Settings (1) ──── (0..1) ConfluenceConfig
Settings (1) ──── (0..1) MusicConfig

AIProviderConfig (1) ──── (0..*) APIValidationResult
ConfluenceConfig (1) ──── (0..*) ConnectionTestResult
MusicConfig (1) ──── (0..*) GenerationResult
```

## Storage Strategy

### SharedPreferences (General Settings)
```dart
{
  "language": "ru",
  "dark_mode": true,
  "notifications_enabled": true,
  "last_modified": "2025-10-23T10:30:00Z",
  "ai_provider_type": "openai",
  "selected_model": "gpt-4o",
  "music_genre": "pop"
}
```

### Flutter Secure Storage (Sensitive Data)
```dart
{
  "ai_provider_openai_key": "sk-...",
  "ai_provider_anthropic_key": "sk-ant-...",
  "confluence_api_token": "ATATT3xFfGF0...",
  "music_api_key": "gen-api-..."
}
```

### File System (Complex Configurations)
```dart
// lib/data/settings.json
{
  "ai_provider": {...},
  "confluence_config": {...},
  "music_config": {...}
}

// lib/data/music_generation_log.json
{
  "request_id": 28104643,
  "status": "processing",
  "created_at": "2025-10-23T10:30:00Z"
}
```

## Validation Schemas

### AI Provider Validation
```dart
class AIProviderValidation {
  static Future<ValidationResult> validateApiKey(
    AIProviderType type,
    String apiKey,
    String? baseUrl,
  ) async {
    // API call to provider for validation
    // Return ValidationResult with isValid and message
  }
  
  static String? validateKeyFormat(AIProviderType type, String apiKey) {
    switch (type) {
      case AIProviderType.openai:
        if (!apiKey.startsWith('sk-') || apiKey.length < 20) {
          return 'OpenAI API key must start with "sk-" and be at least 20 characters';
        }
        break;
      case AIProviderType.anthropic:
        if (!apiKey.startsWith('sk-ant-') || apiKey.length < 30) {
          return 'Anthropic API key must start with "sk-ant-" and be at least 30 characters';
        }
        break;
      // ... другие провайдеры
    }
    return null;
  }
}
```

### Confluence Validation
```dart
class ConfluenceValidation {
  static ConfluenceType detectType(String url) {
    final uri = Uri.parse(url.toLowerCase());
    if (uri.host.endsWith('.atlassian.net') && uri.path.contains('/wiki')) {
      return ConfluenceType.cloud;
    }
    return ConfluenceType.dataCenter;
  }
  
  static String buildApiUrl(String userUrl) {
    final uri = Uri.parse(userUrl);
    final type = detectType(userUrl);
    
    switch (type) {
      case ConfluenceType.cloud:
        return 'https://${uri.host}/wiki/rest/api';
      case ConfluenceType.dataCenter:
        final path = uri.path.endsWith('/') ? uri.path : '${uri.path}/';
        return '${uri.scheme}://${uri.host}${path}rest/api';
    }
  }
  
  static Future<ValidationResult> testConnection(ConfluenceConfig config) async {
    // Test API connectivity
    // Return connection status and available spaces
  }
}
```

### Music Generation Validation
```dart
class MusicGenerationValidation {
  static Future<ValidationResult> validateApiKey(String apiKey) async {
    // Call GET /api/v1/user to validate
    // Return ValidationResult with balance info
  }
  
  static String? validateGenre(String genre) {
    if (!MusicConfig.supportedGenres.containsValue(genre)) {
      return 'Unsupported music genre: $genre';
    }
    return null;
  }
}
```

## Error Handling

### Validation Errors
```dart
enum SettingsValidationError {
  invalidApiKey,
  unsupportedModel,
  invalidUrl,
  connectionFailed,
  quotaExceeded,
  invalidFormat,
  insufficientBalance,
  generationInProgress,
}
```

### Error Messages (Localized)
```dart
const Map<SettingsValidationError, Map<String, String>> errorMessages = {
  SettingsValidationError.invalidApiKey: {
    'en': 'Invalid API key format',
    'ru': 'Неверный формат API ключа',
  },
  SettingsValidationError.connectionFailed: {
    'en': 'Failed to connect to service',
    'ru': 'Не удалось подключиться к сервису',
  },
  SettingsValidationError.insufficientBalance: {
    'en': 'Insufficient balance for music generation',
    'ru': 'Недостаточно баланса для генерации музыки',
  },
};
```

## Performance Considerations

### Lazy Loading
- AI provider validation только при запросе
- Confluence connection test в фоне
- Music generation queue для предотвращения перегрузки

### Caching Strategy
- Валидация API ключей кэшируется на 1 час
- Confluence spaces кэшируются на 30 минут
- Music balance кэшируется на 5 минут
- AI models кэшируются на 1 час

### Memory Management
- Ограничение на количество одновременно активных провайдеров (1)
- Очистка неиспользуемых конфигураций
- Периодическая очистка кэша валидации
- Graceful shutdown для долгих операций

## Localization Support

### Genre Mapping
```dart
class GenreLocalization {
  static Map<String, String> getLocalizedGenres(String locale) {
    if (locale.startsWith('ru')) {
      return MusicConfig.supportedGenres;
    } else {
      return {
        'Pop': 'pop',
        'Russian rap': 'russian rap',
        'Rock': 'rock',
        'Jazz': 'jazz',
        'Classic': 'classic',
        'Electro music': 'electric music',
        'Hip-hop': 'hip-hop',
        'R&B': 'r&b',
      };
    }
  }
}
```

### AI Provider Names
```dart
class AIProviderLocalization {
  static Map<AIProviderType, Map<String, String>> providerNames = {
    AIProviderType.openai: {
      'en': 'OpenAI',
      'ru': 'OpenAI',
    },
    AIProviderType.anthropic: {
      'en': 'Anthropic',
      'ru': 'Anthropic',
    },
    // ... другие провайдеры
  };
}
```