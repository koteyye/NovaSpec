# Quickstart Guide: Settings and Integrations

**Date**: 2025-10-23  
**Feature**: Settings and Integrations (Phase 4)  
**Target**: Flutter/Dart developers

## Prerequisites

- Flutter 3.x installed
- Dart 3.x installed  
- Basic knowledge of Provider pattern
- Understanding of MVVM architecture
- Access to external API services (OpenAI, Confluence, gen-api.ru)

## Setup Instructions

### 1. Add Dependencies

Add to `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # State Management & DI
  provider: ^6.1.1
  get_it: ^7.6.4
  
  # HTTP & Networking
  dio: ^5.4.0
  
  # Storage
  shared_preferences: ^2.2.2
  flutter_secure_storage: ^9.0.0
  
  # File Operations
  file_picker: ^6.1.1
  path_provider: ^2.1.1
  
  # UI Components
  flutter_svg: ^2.0.9
  flutter_localizations:
    sdk: flutter
  
  # WebView & Media
  webview_flutter: ^4.4.2
  audioplayers: ^5.2.1
  
  # Content Rendering
  flutter_markdown: ^0.6.18
  flutter_html: ^3.0.0
  
  # SSE for AI streaming
  eventsource: ^0.4.0
  
  # JSON & YAML
  yaml: ^3.1.2
  
  # HTTP Server for Swagger UI
  shelf: ^1.4.1
  shelf_static: ^1.1.2

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
  json_annotation: ^4.8.1
  json_serializable: ^6.7.1
```

### 2. Configure Localization

Update `lib/l10n/app_localizations.dart`:

```dart
import 'package:flutter/material.dart';

class AppLocalizations {
  static const List<Locale> supportedLocales = [
    Locale('en', ''),
    Locale('ru', ''),
  ];

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  final Locale locale;

  AppLocalizations(this.locale);

  // Settings Screen
  String get settings => locale.languageCode == 'ru' ? 'Параметры' : 'Settings';
  String get provider => locale.languageCode == 'ru' ? 'Провайдер' : 'Provider';
  String get confluence => locale.languageCode == 'ru' ? 'Confluence' : 'Confluence';
  String get music => locale.languageCode == 'ru' ? 'Музикация' : 'Music';
  String get language => locale.languageCode == 'ru' ? 'Язык' : 'Language';
  
  // AI Providers
  String get openai => 'OpenAI';
  String get anthropic => 'Anthropic';
  String get cerebras => 'Cerebras';
  String get groq => 'Groq';
  String get openrouter => 'OpenRouter';
  String get openaiCompetitive => 'OpenAI Compatible';
  String get lmStudio => 'LM Studio';
  String get ollama => 'Ollama';
  
  // Music Genres
  String get pop => locale.languageCode == 'ru' ? 'Поп' : 'Pop';
  String get russianRap => locale.languageCode == 'ru' ? 'Русский рэп' : 'Russian rap';
  String get rock => locale.languageCode == 'ru' ? 'Рок' : 'Rock';
  String get jazz => locale.languageCode == 'ru' ? 'Джаз' : 'Jazz';
  String get classic => locale.languageCode == 'ru' ? 'Классика' : 'Classic';
  String get electricMusic => locale.languageCode == 'ru' ? 'Электронная музыка' : 'Electric music';
  String get hipHop => locale.languageCode == 'ru' ? 'Хип-хоп' : 'Hip-hop';
  String get rnb => 'R&B';
  
  // Validation Messages
  String get invalidApiKey => locale.languageCode == 'ru' ? 'Неверный API ключ' : 'Invalid API key';
  String get connectionFailed => locale.languageCode == 'ru' ? 'Не удалось подключиться' : 'Connection failed';
  String get validationSuccess => locale.languageCode == 'ru' ? 'Проверка пройдена успешно' : 'Validation successful';
  String get validationFailed => locale.languageCode == 'ru' ? 'Проверка не пройдена' : 'Validation failed';
  
  // Common
  String get save => locale.languageCode == 'ru' ? 'Сохранить' : 'Save';
  String get cancel => locale.languageCode == 'ru' ? 'Отмена' : 'Cancel';
  String get check => locale.languageCode == 'ru' ? 'Проверить' : 'Check';
  String get apiKey => locale.languageCode == 'ru' ? 'API ключ' : 'API Key';
  String get baseUrl => locale.languageCode == 'ru' ? 'Базовый URL' : 'Base URL';
  String get email => locale.languageCode == 'ru' ? 'Email' : 'Email';
  String get token => locale.languageCode == 'ru' ? 'Токен' : 'Token';
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'ru'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(LocalizationsDelegate<AppLocalizations> old) => false;
}
```

### 3. Setup Dependency Injection

Create `lib/core/di/service_locator.dart`:

```dart
import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../services/api_service.dart';
import '../services/ai_provider_service.dart';
import '../services/confluence_service.dart';
import '../services/music_generation_service.dart';
import '../services/secure_storage_service.dart';
import '../services/settings_storage_service.dart';
import '../../features/settings/providers/settings_provider.dart';

final GetIt sl = GetIt.instance;

Future<void> setupServiceLocator() async {
  // Core dependencies
  sl.registerLazySingleton(() => Dio());
  sl.registerLazySingleton(() => FlutterSecureStorage());
  sl.registerLazySingleton(() => SharedPreferences.getInstance());
  
  // Storage services
  sl.registerLazySingleton(() => SecureStorageService(sl()));
  sl.registerLazySingleton(() => SettingsStorageService(sl()));
  
  // API services
  sl.registerLazySingleton(() => ApiService(sl()));
  sl.registerLazySingleton(() => AIProviderService(sl(), sl()));
  sl.registerLazySingleton(() => ConfluenceService(sl(), sl()));
  sl.registerLazySingleton(() => MusicGenerationService(sl(), sl()));
  
  // Providers
  sl.registerLazySingleton(() => SettingsProvider(
    sl(), // AIProviderService
    sl(), // ConfluenceService  
    sl(), // MusicGenerationService
    sl(), // SettingsStorageService
  ));
}
```

### 4. Create Core Services

#### API Service (`lib/core/services/api_service.dart`)

```dart
import 'package:dio/dio.dart';

class ApiService {
  final Dio _dio;

  ApiService(this._dio) {
    _dio.options = BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
      headers: {
        'User-Agent': 'NovaSpec/1.0',
        'Accept': 'application/json',
      },
    );

    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      logPrint: (obj) => print(obj),
    ));
  }

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _dio.get<T>(path, queryParameters: queryParameters, options: options);
  }

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _dio.post<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response> download(
    String urlPath,
    String savePath, {
    ProgressCallback? onReceiveProgress,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _dio.download(
      urlPath,
      savePath,
      onReceiveProgress: onReceiveProgress,
      queryParameters: queryParameters,
      options: options,
    );
  }
}
```

#### Settings Provider (`lib/features/settings/providers/settings_provider.dart`)

```dart
import 'package:flutter/foundation.dart';
import '../../../core/services/ai_provider_service.dart';
import '../../../core/services/confluence_service.dart';
import '../../../core/services/music_generation_service.dart';
import '../../../core/services/settings_storage_service.dart';
import '../models/settings_model.dart';

class SettingsProvider extends ChangeNotifier {
  final AIProviderService _aiService;
  final ConfluenceService _confluenceService;
  final MusicGenerationService _musicService;
  final SettingsStorageService _storageService;

  SettingsProvider(
    this._aiService,
    this._confluenceService,
    this._musicService,
    this._storageService,
  );

  Settings _settings = Settings.empty();
  bool _isLoading = false;
  String? _error;

  Settings get settings => _settings;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadSettings() async {
    _setLoading(true);
    try {
      _settings = await _storageService.loadSettings();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> validateAllIntegrations() async {
    _setLoading(true);
    try {
      // Validate AI Provider
      if (_settings.aiProvider != null) {
        final isValid = await _aiService.validateApiKey(
          _settings.aiProvider!.provider,
          _settings.aiProvider!.apiKey,
          _settings.aiProvider!.baseUrl,
        );
        _settings = _settings.copyWith(
          aiProvider: _settings.aiProvider!.copyWith(isValid: isValid),
        );
      }

      // Validate Confluence
      if (_settings.confluenceConfig?.isEnabled == true) {
        final isConnected = await _confluenceService.testConnection(_settings.confluenceConfig!);
        _settings = _settings.copyWith(
          confluenceConfig: _settings.confluenceConfig!.copyWith(
            isConnected: isConnected,
            lastConnected: DateTime.now(),
          ),
        );
      }

      // Validate Music Service
      if (_settings.musicConfig?.isEnabled == true) {
        final balance = await _musicService.getBalance(_settings.musicConfig!.apiKey);
        _settings = _settings.copyWith(
          musicConfig: _settings.musicConfig!.copyWith(balance: balance),
        );
      }

      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> saveSettings() async {
    _setLoading(true);
    try {
      await _storageService.saveSettings(_settings);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  void updateAIProvider(AIProviderConfig? aiProvider) {
    _settings = _settings.copyWith(aiProvider: aiProvider);
    notifyListeners();
  }

  void updateConfluenceConfig(ConfluenceConfig? confluenceConfig) {
    _settings = _settings.copyWith(confluenceConfig: confluenceConfig);
    notifyListeners();
  }

  void updateMusicConfig(MusicConfig? musicConfig) {
    _settings = _settings.copyWith(musicConfig: musicConfig);
    notifyListeners();
  }

  void updateLanguage(String language) {
    _settings = _settings.copyWith(language: language);
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
```

### 5. Create Settings Screen

Create `lib/features/settings/screens/settings_screen.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/ai_provider_widget.dart';
import '../widgets/confluence_widget.dart';
import '../widgets/music_widget.dart';
import '../widgets/language_widget.dart';
import '../../../shared/widgets/modern_button.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SettingsProvider>().loadSettings();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).settings),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: AppLocalizations.of(context).provider),
            Tab(text: AppLocalizations.of(context).confluence),
            Tab(text: AppLocalizations.of(context).music),
            Tab(text: AppLocalizations.of(context).language),
          ],
        ),
        actions: [
          Consumer<SettingsProvider>(
            builder: (context, provider, child) {
              return Row(
                children: [
                  ModernButton(
                    text: AppLocalizations.of(context).check,
                    variant: ButtonVariant.secondary,
                    onPressed: provider.isLoading ? null : () async {
                      await provider.validateAllIntegrations();
                      if (provider.error == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(AppLocalizations.of(context).validationSuccess)),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(provider.error!)),
                        );
                      }
                    },
                  ),
                  const SizedBox(width: 8),
                  ModernButton(
                    text: AppLocalizations.of(context).save,
                    variant: ButtonVariant.primary,
                    onPressed: provider.isLoading ? null : () async {
                      await provider.saveSettings();
                      if (provider.error == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Settings saved successfully')),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(provider.error!)),
                        );
                      }
                    },
                  ),
                  const SizedBox(width: 16),
                ],
              );
            },
          ),
        ],
      ),
      body: Consumer<SettingsProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return TabBarView(
            controller: _tabController,
            children: [
              AIProviderWidget(),
              ConfluenceWidget(),
              MusicWidget(),
              LanguageWidget(),
            ],
          );
        },
      ),
    );
  }
}
```

## Testing Scenarios

### Manual Testing Checklist

#### AI Provider Testing
1. **OpenAI Configuration**
   - Enter valid OpenAI API key
   - Click "Check" - should validate successfully
   - Try invalid key - should show error message
   - Save configuration - should persist

2. **Anthropic Configuration**
   - Enter valid Anthropic API key
   - Validate models endpoint
   - Test with different headers (x-api-key)

3. **Provider Switching**
   - Switch between different providers
   - Verify configuration is maintained
   - Test validation for each provider

#### Confluence Testing
1. **Cloud Detection**
   - Enter `https://example.atlassian.net/wiki`
   - Should auto-detect as Cloud type
   - Test with Bearer token authentication

2. **Data Center Detection**
   - Enter `https://confluence.company.com`
   - Should auto-detect as Data Center
   - Test with Basic authentication

3. **Connection Testing**
   - Test valid credentials
   - Test invalid credentials
   - Verify error messages

#### Music Generation Testing
1. **Balance Check**
   - Enter valid gen-api.ru token
   - Should retrieve current balance
   - Display balance in UI

2. **Genre Selection**
   - Test all 8 genres
   - Verify localization works
   - Test genre persistence

#### Settings Persistence
1. **Save/Load**
   - Configure all integrations
   - Save settings
   - Restart app
   - Verify all settings loaded

2. **Validation State**
   - Validate integrations
   - Save without validation - should be disabled
   - Validate successfully - save should be enabled

## Common Issues and Solutions

### API Key Validation Fails
**Issue**: API key validation returns false even for valid keys  
**Solution**: Check network connectivity, verify API endpoint URLs, ensure correct headers are set

### Confluence Connection Timeout
**Issue**: Connection to Confluence times out  
**Solution**: Check URL format, verify firewall settings, ensure correct authentication method

### Music Generation Not Working
**Issue**: gen-api.ru integration not working  
**Solution**: Verify API key balance, check User-Agent header, ensure correct endpoint URLs

### Settings Not Persisting
**Issue**: Settings lost after app restart  
**Solution**: Check SharedPreferences initialization, verify secure storage permissions, ensure proper serialization

## Performance Tips

1. **Lazy Loading**: Load provider configurations only when needed
2. **Caching**: Cache validation results for 1 hour
3. **Debouncing**: Debounce validation calls to prevent excessive API requests
4. **Background Operations**: Use isolates for music generation status checking

## Security Considerations

1. **API Keys**: Always store in flutter_secure_storage
2. **Network Security**: Use HTTPS for all API calls
3. **Input Validation**: Validate all user inputs before API calls
4. **Error Handling**: Don't expose sensitive information in error messages

## Next Steps

1. Implement remaining UI widgets (AIProviderWidget, ConfluenceWidget, etc.)
2. Add comprehensive error handling
3. Implement proper logging
4. Add unit tests for business logic (if allowed by constitution)
5. Performance optimization and caching