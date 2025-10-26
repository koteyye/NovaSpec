import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/ai_validation_service.dart';
import '../services/confluence_validation_service.dart';
import '../services/music_validation_service.dart';
import '../../shared/models/validation_result.dart';

// Enums for backward compatibility
enum AIProvider {
  openai('OpenAI'),
  anthropic('Anthropic'),
  cerebras('Cerebras'),
  groq('Groq'),
  openrouter('OpenRouter'),
  openaiCompetitive('OpenAI Competitive'),
  lmStudio('LM Studio'),
  ollama('Ollama'),
  zai('Z.AI');

  const AIProvider(this.displayName);
  final String displayName;
}

enum ConfluenceAuthMethod { apiToken, basicAuth }

enum ZAIAccessType {
  codingPlan('Coding Plan'),
  payAsYouGo('Pay-as-you-go');

  const ZAIAccessType(this.displayName);
  final String displayName;
}

class SettingsProvider extends ChangeNotifier {
  static const _secureStorage = FlutterSecureStorage();
  SharedPreferences? _prefs;

  final AIValidationService? _aiValidationService;
  final ConfluenceValidationService? _confluenceValidationService;
  final MusicValidationService? _musicValidationService;

  SettingsProvider({
    AIValidationService? aiValidationService,
    ConfluenceValidationService? confluenceValidationService,
    MusicValidationService? musicValidationService,
  }) : _aiValidationService = aiValidationService,
       _confluenceValidationService = confluenceValidationService,
       _musicValidationService = musicValidationService;

  // AI Provider Settings
  AIProvider _selectedProvider = AIProvider.openai;

  // Individual provider tokens
  String _openaiToken = '';
  String _openaiCompetitiveToken = '';
  String _openaiCompetitiveBaseUrl = '';
  String _anthropicToken = '';
  String _cerebrasToken = '';
  String _groqToken = '';
  String _lmStudioToken = '';
  String _lmStudioBaseUrl = '';
  String _ollamaToken = '';
  String _ollamaBaseUrl = '';
  String _openRouterToken = '';
  String _zaiToken = '';
  String _zaiBaseUrl = '';

  // Z.AI specific
  ZAIAccessType _zaiAccessType = ZAIAccessType.codingPlan;

  // Confluence Settings
  bool _confluenceEnabled = false;
  String _confluenceUrl = '';
  String _confluenceEmail = '';
  String _confluenceToken = '';
  ConfluenceAuthMethod _confluenceAuthMethod = ConfluenceAuthMethod.apiToken;

  // Music Settings
  bool _musicEnabled = false;
  String _musicToken = '';
  String _musicGenre = 'pop'; // Store as system name
  String _audioFormat = 'mp3';
  String _audioQuality = 'standard';

  // Genre mappings for localization
  static const Map<String, String> genresRu = {
    'Поп': 'pop',
    'Русский рэп': 'russian rap',
    'Рок': 'rock',
    'Джаз': 'jazz',
    'Классика': 'classic',
    'Электронная музыка': 'electric music',
    'Хип-хоп': 'hip-hop',
    'R&B': 'r&b',
  };

  static const Map<String, String> genresEn = {
    'Pop Music': 'pop',
    'Russian rap': 'russian rap',
    'Rock': 'rock',
    'Jazz': 'jazz',
    'Classic': 'classic',
    'Electro music': 'electro music',
    'Hip-hop': 'hip-hop',
    'R&B': 'r&b',
  };

  // General Settings
  String _language = 'ru';

  // Loading and error states
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  AIProvider get selectedAIProvider => _selectedProvider;
  String get apiKey => _openaiToken; // For backward compatibility
  String get baseUrl => _openaiCompetitiveBaseUrl; // For backward compatibility

  // Individual provider getters
  String get openaiToken => _openaiToken;
  String get openaiCompetitiveToken => _openaiCompetitiveToken;
  String get openaiCompetitiveBaseUrl => _openaiCompetitiveBaseUrl;
  String get anthropicToken => _anthropicToken;
  String get cerebrasToken => _cerebrasToken;
  String get groqToken => _groqToken;
  String get lmStudioToken => _lmStudioToken;
  String get lmStudioBaseUrl => _lmStudioBaseUrl;
  String get ollamaToken => _ollamaToken;
  String get ollamaBaseUrl => _ollamaBaseUrl;
  String get openRouterToken => _openRouterToken;
  String get zaiToken => _zaiToken;
  String get zaiBaseUrl => _zaiBaseUrl;

  bool get confluenceEnabled => _confluenceEnabled;
  String get confluenceUrl => _confluenceUrl;
  String get confluenceEmail => _confluenceEmail;
  String get confluenceToken => _confluenceToken;
  ConfluenceAuthMethod get confluenceAuthMethod => _confluenceAuthMethod;
  bool get musicEnabled => _musicEnabled;
  String get musicToken => _musicToken;
  String get musicGenre => _musicGenre;
  String get audioFormat => _audioFormat;
  String get audioQuality => _audioQuality;
  String get language => _language;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;

  // Music balance (placeholder for now)
  int get musicBalance => 150; // TODO: Implement actual balance fetching

  bool get needsBaseUrl =>
      _selectedProvider == AIProvider.openaiCompetitive ||
      _selectedProvider == AIProvider.lmStudio ||
      _selectedProvider == AIProvider.ollama;

  bool get isZAIProvider => _selectedProvider == AIProvider.zai;

  ZAIAccessType get zaiAccessType => _zaiAccessType;

  String getApiKeyPlaceholder() {
    switch (_selectedProvider) {
      case AIProvider.openai:
        return 'sk-...';
      case AIProvider.openaiCompetitive:
        return 'sk-...';
      case AIProvider.anthropic:
        return 'sk-ant-...';
      case AIProvider.cerebras:
        return 'cerebras-...';
      case AIProvider.groq:
        return 'gsk_...';
      case AIProvider.lmStudio:
        return 'lm-studio-...';
      case AIProvider.ollama:
        return 'ollama-...';
      case AIProvider.openrouter:
        return 'sk-or-...';
      case AIProvider.zai:
        return _zaiAccessType == ZAIAccessType.codingPlan
            ? 'zai-...'
            : 'zai-...';
    }
  }

  String getDefaultBaseUrl() {
    switch (_selectedProvider) {
      case AIProvider.openai:
        return 'https://api.openai.com/v1';
      case AIProvider.openaiCompetitive:
        return _openaiCompetitiveBaseUrl.isEmpty
            ? 'https://api.openai.com/v1'
            : _openaiCompetitiveBaseUrl;
      case AIProvider.anthropic:
        return 'https://api.anthropic.com/v1';
      case AIProvider.cerebras:
        return 'https://api.cerebras.ai/openai/v1';
      case AIProvider.groq:
        return 'https://api.groq.com/openai/v1';
      case AIProvider.openrouter:
        return 'https://openrouter.ai/api/v1';
      case AIProvider.lmStudio:
        return _lmStudioBaseUrl.isEmpty
            ? 'http://localhost:1234/v1'
            : _lmStudioBaseUrl;
      case AIProvider.ollama:
        return _ollamaBaseUrl.isEmpty
            ? 'http://localhost:11434/v1'
            : _ollamaBaseUrl;
      case AIProvider.zai:
        return _zaiBaseUrl.isEmpty
            ? (_zaiAccessType == ZAIAccessType.codingPlan
                ? 'https://api.z.ai/api/coding/paas/v4'
                : 'https://api.z.ai/api/paas/v4')
            : _zaiBaseUrl;
    }
  }

  // Setters
  void setSelectedAIProvider(AIProvider provider) {
    _selectedProvider = provider;
    _prefs?.setInt('selected_ai_provider', provider.index);
    notifyListeners();
  }

  void setApiKey(String key) {
    // Валидация формата API ключа
    if (!isApiKeyFormatValid(key)) {
      setError('Неверный формат API ключа');
      return;
    }

    // Save for current provider
    switch (_selectedProvider) {
      case AIProvider.openai:
        _openaiToken = key;
        _secureStorage.write(key: 'openai_token', value: key);
        break;
      case AIProvider.openaiCompetitive:
        _openaiCompetitiveToken = key;
        _secureStorage.write(key: 'openai_competitive_token', value: key);
        break;
      case AIProvider.anthropic:
        _anthropicToken = key;
        _secureStorage.write(key: 'anthropic_token', value: key);
        break;
      case AIProvider.cerebras:
        _cerebrasToken = key;
        _secureStorage.write(key: 'cerebras_token', value: key);
        break;
      case AIProvider.groq:
        _groqToken = key;
        _secureStorage.write(key: 'groq_token', value: key);
        break;
      case AIProvider.lmStudio:
        _lmStudioToken = key;
        _secureStorage.write(key: 'lm_studio_token', value: key);
        break;
      case AIProvider.ollama:
        _ollamaToken = key;
        _secureStorage.write(key: 'ollama_token', value: key);
        break;
      case AIProvider.openrouter:
        _openRouterToken = key;
        _secureStorage.write(key: 'openrouter_token', value: key);
        break;
      case AIProvider.zai:
        _zaiToken = key;
        _secureStorage.write(key: 'zai_token', value: key);
        break;
    }

    clearError(); // Очищаем ошибку если валидация прошла
    notifyListeners();
  }

  // Валидация формата API ключа
  bool isApiKeyFormatValid(String key) {
    if (key.isEmpty) return true; // Пустой ключ разрешаем для очистки
    
    switch (_selectedProvider) {
      case AIProvider.openai:
        return key.startsWith('sk-') && key.length >= 20;
      case AIProvider.openaiCompetitive:
        return key.startsWith('sk-') && key.length >= 20;
      case AIProvider.anthropic:
        return key.startsWith('sk-ant-') && key.length >= 30;
      case AIProvider.cerebras:
        return key.startsWith('cerebras-') && key.length >= 10;
      case AIProvider.groq:
        return key.startsWith('gsk_') && key.length >= 20;
      case AIProvider.lmStudio:
        return key.length >= 10;
      case AIProvider.ollama:
        return key.length >= 10;
      case AIProvider.openrouter:
        return key.startsWith('sk-or-') && key.length >= 20;
      case AIProvider.zai:
        return key.length >= 10; // Минимальная длина для Z.AI
    }
  }

  // Валидация обязательных полей для Z.AI
  bool isZAIConfigurationValid() {
    if (_selectedProvider != AIProvider.zai) return true;
    
    // Для Z.AI проверяем только API ключ и тип доступа
    // Base URL определяется автоматически и не требует валидации
    return _zaiToken.isNotEmpty && 
           _zaiToken.length >= 10; // Просто проверяем, что тип доступа выбран
  }

  void setBaseUrl(String url) {
    // Save for current provider
    switch (_selectedProvider) {
      case AIProvider.openaiCompetitive:
        _openaiCompetitiveBaseUrl = url;
        _secureStorage.write(key: 'openai_competitive_base_url', value: url);
        break;
      case AIProvider.lmStudio:
        _lmStudioBaseUrl = url;
        _secureStorage.write(key: 'lm_studio_base_url', value: url);
        break;
      case AIProvider.ollama:
        _ollamaBaseUrl = url;
        _secureStorage.write(key: 'ollama_base_url', value: url);
        break;
      case AIProvider.zai:
        // Для Z.AI Base URL определяется автоматически и не сохраняется
        _zaiBaseUrl = url;
        break;
      default:
        // Ignore base URL for providers that don't support it
        break;
    }
    notifyListeners();
  }

  // Individual provider setters
  void setOpenaiToken(String token) {
    _openaiToken = token;
    _secureStorage.write(key: 'openai_token', value: token);
    notifyListeners();
  }

  void setOpenaiCompetitiveToken(String token) {
    _openaiCompetitiveToken = token;
    _secureStorage.write(key: 'openai_competitive_token', value: token);
    notifyListeners();
  }

  void setOpenaiCompetitiveBaseUrl(String url) {
    _openaiCompetitiveBaseUrl = url;
    _secureStorage.write(key: 'openai_competitive_base_url', value: url);
    notifyListeners();
  }

  void setAnthropicToken(String token) {
    _anthropicToken = token;
    _secureStorage.write(key: 'anthropic_token', value: token);
    notifyListeners();
  }

  void setCerebrasToken(String token) {
    _cerebrasToken = token;
    _secureStorage.write(key: 'cerebras_token', value: token);
    notifyListeners();
  }

  void setGroqToken(String token) {
    _groqToken = token;
    _secureStorage.write(key: 'groq_token', value: token);
    notifyListeners();
  }

  void setLmStudioToken(String token) {
    _lmStudioToken = token;
    _secureStorage.write(key: 'lm_studio_token', value: token);
    notifyListeners();
  }

  void setLmStudioBaseUrl(String url) {
    _lmStudioBaseUrl = url;
    _secureStorage.write(key: 'lm_studio_base_url', value: url);
    notifyListeners();
  }

  void setOllamaToken(String token) {
    _ollamaToken = token;
    _secureStorage.write(key: 'ollama_token', value: token);
    notifyListeners();
  }

  void setOllamaBaseUrl(String url) {
    _ollamaBaseUrl = url;
    _secureStorage.write(key: 'ollama_base_url', value: url);
    notifyListeners();
  }

  void setOpenRouterToken(String token) {
    _openRouterToken = token;
    _secureStorage.write(key: 'openrouter_token', value: token);
    notifyListeners();
  }

  void setZaiToken(String token) {
    _zaiToken = token;
    _secureStorage.write(key: 'zai_token', value: token);
    notifyListeners();
  }

  void setZaiBaseUrl(String url) {
    _zaiBaseUrl = url;
    _secureStorage.write(key: 'zai_base_url', value: url);
    notifyListeners();
  }

  void setConfluenceEnabled(bool enabled) {
    _confluenceEnabled = enabled;
    _prefs?.setBool('confluence_enabled', enabled);
    notifyListeners();
  }

  void setConfluenceUrl(String url) {
    _confluenceUrl = url;
    _secureStorage.write(key: 'confluence_url', value: url);
    notifyListeners();
  }

  void setConfluenceEmail(String email) {
    _confluenceEmail = email;
    _secureStorage.write(key: 'confluence_email', value: email);
    notifyListeners();
  }

  void setConfluenceToken(String token) {
    _confluenceToken = token;
    _secureStorage.write(key: 'confluence_token', value: token);
    notifyListeners();
  }

  void setConfluenceAuthMethod(ConfluenceAuthMethod method) {
    _confluenceAuthMethod = method;
    _prefs?.setInt('confluence_auth_method', method.index);
    notifyListeners();
  }

  void setMusicEnabled(bool enabled) {
    _musicEnabled = enabled;
    _prefs?.setBool('music_enabled', enabled);
    notifyListeners();
  }

  void setMusicToken(String token) {
    _musicToken = token;
    _secureStorage.write(key: 'music_token', value: token);
    notifyListeners();
  }

  void setMusicGenre(String genre) {
    _musicGenre = genre;
    _prefs?.setString('music_genre', genre);
    notifyListeners();
  }

  void setAudioFormat(String format) {
    _audioFormat = format;
    _prefs?.setString('audio_format', format);
    notifyListeners();
  }

  void setAudioQuality(String quality) {
    _audioQuality = quality;
    _prefs?.setString('audio_quality', quality);
    notifyListeners();
  }

  List<String> getAvailableGenres(String language) {
    if (language == 'ru') {
      return genresRu.keys.toList();
    } else {
      return genresEn.keys.toList();
    }
  }

  String getGenreDisplayName(String genreSystemName) {
    if (_language == 'ru') {
      final entry = genresRu.entries.firstWhere(
        (e) => e.value == genreSystemName,
        orElse: () => const MapEntry('Поп', 'pop'),
      );
      return entry.key;
    } else {
      final entry = genresEn.entries.firstWhere(
        (e) => e.value == genreSystemName,
        orElse: () => const MapEntry('Pop Music', 'pop'),
      );
      return entry.key;
    }
  }

  void setLanguage(String lang) {
    _language = lang;
    notifyListeners();
  }

  Locale getCurrentLocale() {
    return _language == 'ru'
        ? const Locale('ru', 'RU')
        : const Locale('en', 'US');
  }

  void setZaiAccessType(ZAIAccessType accessType) {
    _zaiAccessType = accessType;
    _prefs?.setInt('zai_access_type', accessType.index);
    
    // Обновляем base URL при смене типа доступа
    if (_zaiBaseUrl.isEmpty) {
      _zaiBaseUrl = getDefaultBaseUrl(); // Добавить эту строку
      _secureStorage.write(key: 'zai_base_url', value: _zaiBaseUrl);
    }
    
    notifyListeners();
  }

  // Getter for current provider
  AIProvider get currentProvider => _selectedProvider;

  // Method to get provider token
  String? getProviderToken(AIProvider provider) {
    switch (provider) {
      case AIProvider.openai:
        return _openaiToken;
      case AIProvider.openaiCompetitive:
        return _openaiCompetitiveToken;
      case AIProvider.anthropic:
        return _anthropicToken;
      case AIProvider.cerebras:
        return _cerebrasToken;
      case AIProvider.groq:
        return _groqToken;
      case AIProvider.lmStudio:
        return _lmStudioToken;
      case AIProvider.ollama:
        return _ollamaToken;
      case AIProvider.openrouter:
        return _openRouterToken;
      case AIProvider.zai:
        return _zaiToken;
    }
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Initialize settings from storage
  Future<void> initialize() async {
    try {
      setLoading(true);
      clearError();

      _prefs = await SharedPreferences.getInstance();

      // Load AI provider settings
      final providerIndex = _prefs?.getInt('selected_ai_provider') ?? 0;
      _selectedProvider = AIProvider.values[providerIndex];

      // Load tokens from secure storage
      _openaiToken = await _secureStorage.read(key: 'openai_token') ?? '';
      _openaiCompetitiveToken =
          await _secureStorage.read(key: 'openai_competitive_token') ?? '';
      _openaiCompetitiveBaseUrl =
          await _secureStorage.read(key: 'openai_competitive_base_url') ?? '';
      _anthropicToken = await _secureStorage.read(key: 'anthropic_token') ?? '';
      _cerebrasToken = await _secureStorage.read(key: 'cerebras_token') ?? '';
      _groqToken = await _secureStorage.read(key: 'groq_token') ?? '';
      _lmStudioToken = await _secureStorage.read(key: 'lm_studio_token') ?? '';
      _lmStudioBaseUrl =
          await _secureStorage.read(key: 'lm_studio_base_url') ?? '';
      _ollamaToken = await _secureStorage.read(key: 'ollama_token') ?? '';
      _ollamaBaseUrl = await _secureStorage.read(key: 'ollama_base_url') ?? '';
      _openRouterToken =
          await _secureStorage.read(key: 'openrouter_token') ?? '';
      _zaiToken = await _secureStorage.read(key: 'zai_token') ?? '';
      _zaiBaseUrl = await _secureStorage.read(key: 'zai_base_url') ?? '';

      // Load Z.AI access type
      final zaiAccessIndex = _prefs?.getInt('zai_access_type') ?? 0;
      _zaiAccessType = ZAIAccessType.values[zaiAccessIndex];

      // Load Confluence settings
      _confluenceEnabled = _prefs?.getBool('confluence_enabled') ?? false;
      _confluenceUrl = await _secureStorage.read(key: 'confluence_url') ?? '';
      _confluenceEmail =
          await _secureStorage.read(key: 'confluence_email') ?? '';
      _confluenceToken =
          await _secureStorage.read(key: 'confluence_token') ?? '';

      // Load Music settings
      _musicEnabled = _prefs?.getBool('music_enabled') ?? false;
      _musicToken = await _secureStorage.read(key: 'music_token') ?? '';
      _musicGenre = _prefs?.getString('music_genre') ?? 'pop';
      // Migration: convert old "Pop" to "pop"
      if (_musicGenre == 'Pop') {
        _musicGenre = 'pop';
        await _prefs?.setString('music_genre', 'pop');
      }

      // Load general settings
      _language = _prefs?.getString('language') ?? 'ru';

      notifyListeners();
    } catch (e) {
      setError('Failed to initialize settings: $e');
    } finally {
      setLoading(false);
    }
  }

  // Save settings to storage
  Future<void> save() async {
    try {
      setLoading(true);
      clearError();

      // Save AI provider settings
      await _prefs?.setInt('selected_ai_provider', _selectedProvider.index);

      // Save tokens to secure storage
      await _secureStorage.write(key: 'openai_token', value: _openaiToken);
      await _secureStorage.write(
        key: 'openai_competitive_token',
        value: _openaiCompetitiveToken,
      );
      await _secureStorage.write(
        key: 'openai_competitive_base_url',
        value: _openaiCompetitiveBaseUrl,
      );
      await _secureStorage.write(
        key: 'anthropic_token',
        value: _anthropicToken,
      );
      await _secureStorage.write(key: 'cerebras_token', value: _cerebrasToken);
      await _secureStorage.write(key: 'groq_token', value: _groqToken);
      await _secureStorage.write(key: 'lm_studio_token', value: _lmStudioToken);
      await _secureStorage.write(
        key: 'lm_studio_base_url',
        value: _lmStudioBaseUrl,
      );
      await _secureStorage.write(key: 'ollama_token', value: _ollamaToken);
      await _secureStorage.write(key: 'ollama_base_url', value: _ollamaBaseUrl);
      await _secureStorage.write(
        key: 'openrouter_token',
        value: _openRouterToken,
      );
      await _secureStorage.write(key: 'zai_token', value: _zaiToken);
      await _secureStorage.write(key: 'zai_base_url', value: _zaiBaseUrl);

      // Save Z.AI access type
      await _prefs?.setInt('zai_access_type', _zaiAccessType.index);

      // Save Confluence settings
      await _prefs?.setBool('confluence_enabled', _confluenceEnabled);
      await _secureStorage.write(key: 'confluence_url', value: _confluenceUrl);
      await _secureStorage.write(
        key: 'confluence_email',
        value: _confluenceEmail,
      );
      await _secureStorage.write(
        key: 'confluence_token',
        value: _confluenceToken,
      );

      // Save Music settings
      await _prefs?.setBool('music_enabled', _musicEnabled);
      await _secureStorage.write(key: 'music_token', value: _musicToken);
      await _prefs?.setString('music_genre', _musicGenre);

      // Save general settings
      await _prefs?.setString('language', _language);

      notifyListeners();
    } catch (e) {
      setError('Failed to save settings: $e');
    } finally {
      setLoading(false);
    }
  }

  // Validate current settings
  Future<bool> validateSettings() async {
    try {
      setLoading(true);
      clearError();

      bool allValid = true;

      // Validate AI provider
      if (_aiValidationService != null) {
        final token = getProviderToken(_selectedProvider);
        print(
          'DEBUG: AI Validation - Provider: ${_selectedProvider.name}, Token: "$token"',
        );
        if (token != null && token.isNotEmpty) {
          print('DEBUG: Calling validateProvider...');
          final result = await _aiValidationService.validateApiKey(
            _selectedProvider,
            token,
            getDefaultBaseUrl(),
          );
          print(
            'DEBUG: Validation result: ${result.isValid}, Message: ${result.message}',
          );
          if (!result.isValid) {
            allValid = false;
            setError('Invalid AI provider credentials: ${result.message}');
          }
        } else {
          print('DEBUG: Token is null or empty, validation failed');
          allValid = false;
          setError('API ключ не может быть пустым');
        }
      } else {
        print('DEBUG: AI Validation Service is null');
        allValid = false;
        setError('Сервис валидации недоступен');
      }

      // Validate Confluence
      if (_confluenceEnabled && _confluenceValidationService != null) {
        final result = await _confluenceValidationService
            .validateConnectionSimple(
              _confluenceUrl,
              _confluenceEmail,
              _confluenceToken,
            );
        if (!result.isValid) {
          allValid = false;
          setError('Invalid Confluence credentials: ${result.message}');
        }
      }

      // Validate Music
      if (_musicEnabled && _musicValidationService != null) {
        final result = await _musicValidationService.validateApiKey(
          _musicToken,
        );
        if (!result.isValid) {
          allValid = false;
          setError('Invalid Music API credentials: ${result.message}');
        }
      }

      return allValid;
    } catch (e) {
      setError('Validation failed: $e');
      return false;
    } finally {
      setLoading(false);
    }
  }

  // Validate current provider (alias for validateSettings)
  Future<bool> validateCurrentProvider() async {
    print(
      'DEBUG: validateCurrentProvider called for ${_selectedProvider.name}',
    );
    print('DEBUG: Token: ${getProviderToken(_selectedProvider)}');
    print('DEBUG: AI Validation Service: ${_aiValidationService != null}');
    return await validateSettings();
  }

  // Save settings (alias for save)
  Future<void> saveSettings() async {
    await save();
  }

  // Get base URL placeholder
  String getBaseUrlPlaceholder() {
    switch (_selectedProvider) {
      case AIProvider.openaiCompetitive:
        return 'https://api.example.com/v1';
      case AIProvider.lmStudio:
        return 'http://localhost:1234/v1';
      case AIProvider.ollama:
        return 'http://localhost:11434/v1';
      case AIProvider.zai:
        return _zaiAccessType == ZAIAccessType.codingPlan
            ? 'https://api.z.ai/api/coding/paas/v4'
            : 'https://api.z.ai/api/paas/v4';
      default:
        return '';
    }
  }

  // Additional getters for backward compatibility
  String get openaiApiKey => _openaiToken;
  String get anthropicApiKey => _anthropicToken;
  String get cerebrasApiKey => _cerebrasToken;
  String get groqApiKey => _groqToken;
  String get openrouterApiKey => _openRouterToken;
  String get openaiCompetitiveApiKey => _openaiCompetitiveToken;
  String get lmStudioApiKey => _lmStudioToken;
  String get ollamaApiKey => _ollamaToken;
  String get zaiApiKey => _zaiToken;

  String get openaiBaseUrl => 'https://api.openai.com/v1';
  String get anthropicBaseUrl => 'https://api.anthropic.com';
  String get cerebrasBaseUrl => 'https://api.cerebras.ai/openai/v1';
  String get groqBaseUrl => 'https://api.groq.com/openai/v1';
  String get openrouterBaseUrl => 'https://openrouter.ai/api/v1';

  String get confluenceUsername => _confluenceEmail;
  String get confluenceApiToken => _confluenceToken;
  String get defaultSpace => '';
  String get musicApiKey => _musicToken;
  String get musicProvider => _musicEnabled ? 'gen-api' : '';

  String get theme => 'system';
  String get autoSaveInterval => '300';
  String get defaultProjectLocation => '';
  double get fontSize => 14.0;
  int get tabSize => 2;
  bool get wordWrap => true;
  bool get autoCompletion => true;
  double get temperature => 0.7;
  int get maxTokens => 2048;
  int get timeoutSeconds => 30;

  Map<String, dynamic> get aiValidationResults => {};
  Map<String, dynamic> get connectionStatuses => {};

  // Additional setters for backward compatibility
  void setOpenaiApiKey(String key) => setOpenaiToken(key);
  void setAnthropicApiKey(String key) => setAnthropicToken(key);
  void setCerebrasApiKey(String key) => setCerebrasToken(key);
  void setGroqApiKey(String key) => setGroqToken(key);
  void setOpenrouterApiKey(String key) => setOpenRouterToken(key);
  void setOpenaiCompetitiveApiKey(String key) => setOpenaiCompetitiveToken(key);
  void setLmStudioApiKey(String key) => setLmStudioToken(key);
  void setOllamaApiKey(String key) => setOllamaToken(key);
  void setZaiApiKey(String key) => setZaiToken(key);

  void setOpenaiBaseUrl(String url) {
    /* OpenAI doesn't support custom base URL */
  }
  void setAnthropicBaseUrl(String url) {
    /* Anthropic doesn't support custom base URL */
  }
  void setCerebrasBaseUrl(String url) {
    /* Cerebras doesn't support custom base URL */
  }
  void setGroqBaseUrl(String url) {
    /* Groq doesn't support custom base URL */
  }
  void setOpenrouterBaseUrl(String url) {
    /* OpenRouter doesn't support custom base URL */
  }

  void setConfluenceUsername(String username) => setConfluenceEmail(username);
  void setConfluenceApiToken(String token) => setConfluenceToken(token);
  void setDefaultSpace(String space) {
    /* Not implemented in simple provider */
  }
  void setMusicApiKey(String key) => setMusicToken(key);
  void setMusicProvider(String provider) =>
      setMusicEnabled(provider.isNotEmpty);

  void setTheme(String themeValue) {
    /* Theme handled by AppProvider */
  }
  void setAutoSaveInterval(int interval) {
    /* Not implemented in simple provider */
  }
  void setDefaultProjectLocation(String location) {
    /* Not implemented in simple provider */
  }
  void setFontSize(double size) {
    /* Not implemented in simple provider */
  }
  void setTabSize(int size) {
    /* Not implemented in simple provider */
  }
  void setWordWrap(bool enabled) {
    /* Not implemented in simple provider */
  }
  void setAutoCompletion(bool enabled) {
    /* Not implemented in simple provider */
  }
  void setTemperature(double value) {
    /* Not implemented in simple provider */
  }
  void setMaxTokens(int value) {
    /* Not implemented in simple provider */
  }
  void setTimeoutSeconds(int value) {
    /* Not implemented in simple provider */
  }

  // Validation methods
  Future<void> validateAllConnections() async {
    await validateSettings();
  }

  Future<void> updateValidationResult(dynamic provider, dynamic result) async {
    // Not implemented in simple provider
  }

  Future<void> updateConnectionStatus(String service, dynamic status) async {
    // Not implemented in simple provider
  }

  Future<dynamic> validateAIProvider(dynamic provider) async {
    return await validateSettings();
  }

  Future<dynamic> validateConfluence() async {
    if (_confluenceValidationService != null) {
      return await _confluenceValidationService.validateConnectionSimple(
        _confluenceUrl,
        _confluenceEmail,
        _confluenceToken,
      );
    }
    return ValidationResult.error('Сервис валидации недоступен');
  }

  Future<dynamic> validateMusicService() async {
    if (_musicValidationService != null) {
      return await _musicValidationService.validateApiKey(_musicToken);
    }
    return ValidationResult.error('Сервис валидации недоступен');
  }

  // Auto-detect Confluence type
  ConfluenceAuthMethod detectConfluenceType(String url) {
    if (_confluenceValidationService != null) {
      return _confluenceValidationService.detectConfluenceType(url);
    }

    // Fallback logic
    try {
      final uri = Uri.parse(url.toLowerCase());
      if (uri.host.endsWith('atlassian.net') && uri.path.contains('/wiki')) {
        return ConfluenceAuthMethod.apiToken;
      } else {
        return ConfluenceAuthMethod.basicAuth;
      }
    } catch (e) {
      return ConfluenceAuthMethod.basicAuth;
    }
  }
}
