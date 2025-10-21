import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';


enum AIProvider {
  openai,
  anthropic,
  groq,
}

enum ConfluenceAuthMethod {
  apiToken,
  oauth,
}

class SettingsProvider extends ChangeNotifier {
  static const _secureStorage = FlutterSecureStorage();
  SharedPreferences? _prefs;
  
  // AI Provider Settings
  AIProvider _selectedAIProvider = AIProvider.openai;
  String _openaiApiKey = '';
  String _anthropicApiKey = '';
  String _groqApiKey = '';
  String _openaiBaseUrl = 'https://api.openai.com/v1';
  String _anthropicBaseUrl = 'https://api.anthropic.com';
  String _groqBaseUrl = 'https://api.groq.com/openai/v1';
  double _temperature = 0.7;
  int _maxTokens = 2048;
  int _timeoutSeconds = 30;
  
  // Confluence Settings
  String _confluenceUrl = '';
  ConfluenceAuthMethod _confluenceAuthMethod = ConfluenceAuthMethod.apiToken;
  String _confluenceUsername = '';
  String _confluenceApiToken = '';
  String _defaultSpace = '';
  
  // Music Generation Settings
  String _musicProvider = '';
  String _musicApiKey = '';
  String _audioFormat = 'mp3';
  String _audioQuality = 'standard';
  
  // General Settings
  String _language = 'ru';
  String _theme = 'system';
  int _autoSaveInterval = 300; // seconds
  String _defaultProjectLocation = '';
  
  // Editor Settings
  double _fontSize = 14.0;
  int _tabSize = 2;
  bool _wordWrap = true;
  bool _autoCompletion = true;
  
  bool _isLoading = false;
  String? _errorMessage;
  
  // Getters
  AIProvider get selectedAIProvider => _selectedAIProvider;
  String get openaiApiKey => _openaiApiKey;
  String get anthropicApiKey => _anthropicApiKey;
  String get groqApiKey => _groqApiKey;
  String get openaiBaseUrl => _openaiBaseUrl;
  String get anthropicBaseUrl => _anthropicBaseUrl;
  String get groqBaseUrl => _groqBaseUrl;
  double get temperature => _temperature;
  int get maxTokens => _maxTokens;
  int get timeoutSeconds => _timeoutSeconds;
  
  String get confluenceUrl => _confluenceUrl;
  ConfluenceAuthMethod get confluenceAuthMethod => _confluenceAuthMethod;
  String get confluenceUsername => _confluenceUsername;
  String get confluenceApiToken => _confluenceApiToken;
  String get defaultSpace => _defaultSpace;
  
  String get musicProvider => _musicProvider;
  String get musicApiKey => _musicApiKey;
  String get audioFormat => _audioFormat;
  String get audioQuality => _audioQuality;
  
  String get language => _language;
  String get theme => _theme;
  int get autoSaveInterval => _autoSaveInterval;
  String get defaultProjectLocation => _defaultProjectLocation;
  
  double get fontSize => _fontSize;
  int get tabSize => _tabSize;
  bool get wordWrap => _wordWrap;
  bool get autoCompletion => _autoCompletion;
  
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      _prefs = await SharedPreferences.getInstance();
      await _loadSettings();
    } catch (e) {
      _errorMessage = 'Failed to load settings: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> _loadSettings() async {
    if (_prefs == null) return;
    
    // Load AI Provider Settings
    _selectedAIProvider = AIProvider.values[_prefs!.getInt('selected_ai_provider') ?? 0];
    _openaiBaseUrl = _prefs!.getString('openai_base_url') ?? 'https://api.openai.com/v1';
    _anthropicBaseUrl = _prefs!.getString('anthropic_base_url') ?? 'https://api.anthropic.com';
    _groqBaseUrl = _prefs!.getString('groq_base_url') ?? 'https://api.groq.com/openai/v1';
    _temperature = _prefs!.getDouble('temperature') ?? 0.7;
    _maxTokens = _prefs!.getInt('max_tokens') ?? 2048;
    _timeoutSeconds = _prefs!.getInt('timeout_seconds') ?? 30;
    
    // Load secure API keys
    _openaiApiKey = await _secureStorage.read(key: 'openai_api_key') ?? '';
    _anthropicApiKey = await _secureStorage.read(key: 'anthropic_api_key') ?? '';
    _groqApiKey = await _secureStorage.read(key: 'groq_api_key') ?? '';
    
    // Load Confluence Settings
    _confluenceUrl = _prefs!.getString('confluence_url') ?? '';
    _confluenceAuthMethod = ConfluenceAuthMethod.values[_prefs!.getInt('confluence_auth_method') ?? 0];
    _confluenceUsername = _prefs!.getString('confluence_username') ?? '';
    _defaultSpace = _prefs!.getString('default_space') ?? '';
    _confluenceApiToken = await _secureStorage.read(key: 'confluence_api_token') ?? '';
    
    // Load Music Settings
    _musicProvider = _prefs!.getString('music_provider') ?? '';
    _audioFormat = _prefs!.getString('audio_format') ?? 'mp3';
    _audioQuality = _prefs!.getString('audio_quality') ?? 'standard';
    _musicApiKey = await _secureStorage.read(key: 'music_api_key') ?? '';
    
    // Load General Settings
    _language = _prefs!.getString('language') ?? 'ru';
    _theme = _prefs!.getString('theme') ?? 'system';
    _autoSaveInterval = _prefs!.getInt('auto_save_interval') ?? 300;
    _defaultProjectLocation = _prefs!.getString('default_project_location') ?? '';
    
    // Load Editor Settings
    _fontSize = _prefs!.getDouble('font_size') ?? 14.0;
    _tabSize = _prefs!.getInt('tab_size') ?? 2;
    _wordWrap = _prefs!.getBool('word_wrap') ?? true;
    _autoCompletion = _prefs!.getBool('auto_completion') ?? true;
  }
  
  Future<void> saveSettings() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      if (_prefs == null) return;
      
      // Save AI Provider Settings
      await _prefs!.setInt('selected_ai_provider', _selectedAIProvider.index);
      await _prefs!.setString('openai_base_url', _openaiBaseUrl);
      await _prefs!.setString('anthropic_base_url', _anthropicBaseUrl);
      await _prefs!.setString('groq_base_url', _groqBaseUrl);
      await _prefs!.setDouble('temperature', _temperature);
      await _prefs!.setInt('max_tokens', _maxTokens);
      await _prefs!.setInt('timeout_seconds', _timeoutSeconds);
      
      // Save secure API keys
      await _secureStorage.write(key: 'openai_api_key', value: _openaiApiKey);
      await _secureStorage.write(key: 'anthropic_api_key', value: _anthropicApiKey);
      await _secureStorage.write(key: 'groq_api_key', value: _groqApiKey);
      
      // Save Confluence Settings
      await _prefs!.setString('confluence_url', _confluenceUrl);
      await _prefs!.setInt('confluence_auth_method', _confluenceAuthMethod.index);
      await _prefs!.setString('confluence_username', _confluenceUsername);
      await _prefs!.setString('default_space', _defaultSpace);
      await _secureStorage.write(key: 'confluence_api_token', value: _confluenceApiToken);
      
      // Save Music Settings
      await _prefs!.setString('music_provider', _musicProvider);
      await _prefs!.setString('audio_format', _audioFormat);
      await _prefs!.setString('audio_quality', _audioQuality);
      await _secureStorage.write(key: 'music_api_key', value: _musicApiKey);
      
      // Save General Settings
      await _prefs!.setString('language', _language);
      await _prefs!.setString('theme', _theme);
      await _prefs!.setInt('auto_save_interval', _autoSaveInterval);
      await _prefs!.setString('default_project_location', _defaultProjectLocation);
      
      // Save Editor Settings
      await _prefs!.setDouble('font_size', _fontSize);
      await _prefs!.setInt('tab_size', _tabSize);
      await _prefs!.setBool('word_wrap', _wordWrap);
      await _prefs!.setBool('auto_completion', _autoCompletion);
      
    } catch (e) {
      _errorMessage = 'Failed to save settings: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // AI Provider Setters
  void setSelectedAIProvider(AIProvider provider) {
    _selectedAIProvider = provider;
    notifyListeners();
  }
  
  void setOpenaiApiKey(String key) {
    _openaiApiKey = key;
    notifyListeners();
  }
  
  void setAnthropicApiKey(String key) {
    _anthropicApiKey = key;
    notifyListeners();
  }
  
  void setGroqApiKey(String key) {
    _groqApiKey = key;
    notifyListeners();
  }
  
  void setOpenaiBaseUrl(String url) {
    _openaiBaseUrl = url;
    notifyListeners();
  }
  
  void setAnthropicBaseUrl(String url) {
    _anthropicBaseUrl = url;
    notifyListeners();
  }
  
  void setGroqBaseUrl(String url) {
    _groqBaseUrl = url;
    notifyListeners();
  }
  
  void setTemperature(double value) {
    _temperature = value.clamp(0.0, 2.0);
    notifyListeners();
  }
  
  void setMaxTokens(int value) {
    _maxTokens = value.clamp(1, 8192);
    notifyListeners();
  }
  
  void setTimeoutSeconds(int value) {
    _timeoutSeconds = value.clamp(5, 300);
    notifyListeners();
  }
  
  // Confluence Setters
  void setConfluenceUrl(String url) {
    _confluenceUrl = url;
    notifyListeners();
  }
  
  void setConfluenceAuthMethod(ConfluenceAuthMethod method) {
    _confluenceAuthMethod = method;
    notifyListeners();
  }
  
  void setConfluenceUsername(String username) {
    _confluenceUsername = username;
    notifyListeners();
  }
  
  void setConfluenceApiToken(String token) {
    _confluenceApiToken = token;
    notifyListeners();
  }
  
  void setDefaultSpace(String space) {
    _defaultSpace = space;
    notifyListeners();
  }
  
  // Music Setters
  void setMusicProvider(String provider) {
    _musicProvider = provider;
    notifyListeners();
  }
  
  void setMusicApiKey(String key) {
    _musicApiKey = key;
    notifyListeners();
  }
  
  void setAudioFormat(String format) {
    _audioFormat = format;
    notifyListeners();
  }
  
  void setAudioQuality(String quality) {
    _audioQuality = quality;
    notifyListeners();
  }
  
  // General Setters
  void setLanguage(String language) {
    _language = language;
    notifyListeners();
  }
  
  void setTheme(String theme) {
    _theme = theme;
    notifyListeners();
  }
  
  void setAutoSaveInterval(int interval) {
    _autoSaveInterval = interval.clamp(60, 3600);
    notifyListeners();
  }
  
  void setDefaultProjectLocation(String location) {
    _defaultProjectLocation = location;
    notifyListeners();
  }
  
  // Editor Setters
  void setFontSize(double size) {
    _fontSize = size.clamp(8.0, 24.0);
    notifyListeners();
  }
  
  void setTabSize(int size) {
    _tabSize = size.clamp(1, 8);
    notifyListeners();
  }
  
  void setWordWrap(bool enabled) {
    _wordWrap = enabled;
    notifyListeners();
  }
  
  void setAutoCompletion(bool enabled) {
    _autoCompletion = enabled;
    notifyListeners();
  }
  
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}