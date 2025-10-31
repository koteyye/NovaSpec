import 'package:flutter/material.dart';
import '../services/config_service.dart';
import '../services/storage_service.dart';
import '../../shared/models/app_config.dart';
import '../../shared/models/navigation_state.dart';
import '../../shared/models/app_error.dart';
import '../utils/helpers.dart';

class AppProvider extends ChangeNotifier {
  final ConfigService _configService;
  final StorageService _storageService;
  
  AppConfiguration? _appConfiguration;
  NavigationState? _navigationState;
  bool _isLoading = false;
  AppError? _error;
  
  // Status indicators
  String _aiProvider = '';
  bool _atlassianActive = false;
  bool _musicActive = false;
  int _musicBalance = 0;
  String _musicGenre = '';
  
  AppProvider(this._configService, this._storageService);
  
  // Getters
  AppConfiguration? get appConfiguration => _appConfiguration;
  NavigationState? get navigationState => _navigationState;
  bool get isLoading => _isLoading;
  AppError? get error => _error;
  
  // Status indicator getters
  String get aiProvider => _aiProvider;
  bool get atlassianActive => _atlassianActive;
  bool get musicActive => _musicActive;
  int get musicBalance => _musicBalance;
  String get musicGenre => _musicGenre;
  
  // Computed properties
  String get currentLanguage => _appConfiguration?.language ?? 'ru';
  String get currentTheme => _appConfiguration?.theme ?? 'light';
  bool get autoSaveEnabled => _appConfiguration?.autoSave ?? true;
  bool get notificationsEnabled => _appConfiguration?.notificationsEnabled ?? true;
  String? get lastOpenedProject => _appConfiguration?.lastOpenedProject;
  String get currentRoute => _navigationState?.currentRoute ?? '/';
  List<String> get navigationHistory => _navigationState?.history ?? ['/'];
  Map<String, dynamic> get navigationParameters => _navigationState?.parameters ?? {};

  Locale get currentLocale => Locale(_appConfiguration?.language ?? 'ru');

  ThemeMode get themeMode {
    switch (_appConfiguration?.theme) {
      case 'dark':
        return ThemeMode.dark;
      case 'light':
        return ThemeMode.light;
      default:
        return ThemeMode.system;
    }
  }

  void changeLanguage(String language) {
    updateLanguage(language);
  }
  
  // Initialization
  Future<void> initialize() async {
    await _setLoading(true);
    await _clearError();
    
    try {
      AppLogger.info('Initializing AppProvider');
      
      // Initialize services
      await _configService.initialize();
      await _storageService.initialize();
      
      // Load configuration
      final configResult = await _configService.getAppConfiguration();
      if (configResult.isSuccess && configResult.data != null) {
        _appConfiguration = configResult.data!;
        AppLogger.info('App configuration loaded successfully');
      } else {
        _setError(configResult.error);
        return;
      }
      
      // Load navigation state
      final navResult = await _configService.getNavigationState();
      if (navResult.isSuccess && navResult.data != null) {
        _navigationState = navResult.data!;
        AppLogger.info('Navigation state loaded successfully');
      } else {
        _setError(navResult.error);
        return;
      }
      
      AppLogger.info('AppProvider initialized successfully');
    } catch (e) {
      final appError = ErrorHandler.handleError(e, code: 'APP_INIT_ERROR');
      _setError(appError);
      AppLogger.logAppError(appError);
    } finally {
      await _setLoading(false);
    }
  }
  
  // Configuration management
  Future<void> updateLanguage(String language) async {
    print('DEBUG: updateLanguage called with: $language');
    print('DEBUG: Current config: ${_appConfiguration?.toJson()}');
    if (_appConfiguration == null) {
      print('DEBUG: Configuration is null, reloading...');
      await initialize();
    }
    if (_appConfiguration?.language == language) {
      print('DEBUG: Language unchanged, returning');
      return;
    }
    
    await _clearError();
    
    try {
      final updatedConfig = _appConfiguration!.copyWith(language: language);
      final result = await _configService.saveAppConfiguration(updatedConfig);
      
      if (result.isSuccess) {
        _appConfiguration = updatedConfig;
        AppLogger.info('Language updated to: $language');
        print('DEBUG: Language successfully updated to: $language');
        notifyListeners();
      } else {
        _setError(result.error);
      }
    } catch (e) {
      final appError = ErrorHandler.handleError(e, code: 'UPDATE_LANGUAGE_ERROR');
      _setError(appError);
      AppLogger.logAppError(appError);
    }
  }
  
  Future<void> updateTheme(String theme) async {
    print('DEBUG: updateTheme called with: $theme');
    print('DEBUG: Current config: ${_appConfiguration?.toJson()}');
    if (_appConfiguration == null) {
      print('DEBUG: Configuration is null, reloading...');
      await initialize();
    }
    if (_appConfiguration?.theme == theme) {
      print('DEBUG: Theme unchanged, returning');
      return;
    }
    
    await _clearError();
    
    try {
      final updatedConfig = _appConfiguration!.copyWith(theme: theme);
      final result = await _configService.saveAppConfiguration(updatedConfig);
      
      if (result.isSuccess) {
        _appConfiguration = updatedConfig;
        AppLogger.info('Theme updated to: $theme');
        print('DEBUG: Theme successfully updated to: $theme');
        notifyListeners();
      } else {
        _setError(result.error);
      }
    } catch (e) {
      final appError = ErrorHandler.handleError(e, code: 'UPDATE_THEME_ERROR');
      _setError(appError);
      AppLogger.logAppError(appError);
    }
  }
  
  Future<void> updateAutoSave(bool autoSave) async {
    print('DEBUG: updateAutoSave called with: $autoSave');
    if (_appConfiguration == null || _appConfiguration!.autoSave == autoSave) {
      print('DEBUG: AutoSave unchanged or config null, returning');
      return;
    }
    
    await _clearError();
    
    try {
      final updatedConfig = _appConfiguration!.copyWith(autoSave: autoSave);
      final result = await _configService.saveAppConfiguration(updatedConfig);
      
      if (result.isSuccess) {
        _appConfiguration = updatedConfig;
        AppLogger.info('AutoSave updated to: $autoSave');
        print('DEBUG: AutoSave successfully updated to: $autoSave');
        notifyListeners();
      } else {
        _setError(result.error);
      }
    } catch (e) {
      final appError = ErrorHandler.handleError(e, code: 'UPDATE_AUTO_SAVE_ERROR');
      _setError(appError);
      AppLogger.logAppError(appError);
    }
  }
  
  Future<void> updateNotificationsEnabled(bool enabled) async {
    print('DEBUG: updateNotificationsEnabled called with: $enabled');
    if (_appConfiguration == null || _appConfiguration!.notificationsEnabled == enabled) {
      print('DEBUG: Notifications unchanged or config null, returning');
      return;
    }
    
    await _clearError();
    
    try {
      final updatedConfig = _appConfiguration!.copyWith(notificationsEnabled: enabled);
      final result = await _configService.saveAppConfiguration(updatedConfig);
      
      if (result.isSuccess) {
        _appConfiguration = updatedConfig;
        AppLogger.info('Notifications enabled updated to: $enabled');
        print('DEBUG: Notifications successfully updated to: $enabled');
        notifyListeners();
      } else {
        _setError(result.error);
      }
    } catch (e) {
      final appError = ErrorHandler.handleError(e, code: 'UPDATE_NOTIFICATIONS_ERROR');
      _setError(appError);
      AppLogger.logAppError(appError);
    }
  }
  
  Future<void> updateLastOpenedProject(String? projectPath) async {
    if (_appConfiguration == null || _appConfiguration!.lastOpenedProject == projectPath) {
      return;
    }
    
    await _clearError();
    
    try {
      final updatedConfig = _appConfiguration!.copyWith(lastOpenedProject: projectPath);
      final result = await _configService.saveAppConfiguration(updatedConfig);
      
      if (result.isSuccess) {
        _appConfiguration = updatedConfig;
        AppLogger.info('Last opened project updated to: $projectPath');
        notifyListeners();
      } else {
        _setError(result.error);
      }
    } catch (e) {
      final appError = ErrorHandler.handleError(e, code: 'UPDATE_LAST_PROJECT_ERROR');
      _setError(appError);
      AppLogger.logAppError(appError);
    }
  }
  
  // Navigation management
  Future<void> navigateTo(String route, {Map<String, dynamic>? parameters}) async {
    if (_navigationState == null) {
      return;
    }
    
    await _clearError();
    
    try {
      final updatedHistory = List<String>.from(_navigationState!.history);
      if (updatedHistory.last != route) {
        updatedHistory.add(route);
      }
      
      final updatedState = _navigationState!.copyWith(
        currentRoute: route,
        history: updatedHistory,
        parameters: parameters ?? {},
      );
      
      final result = await _configService.saveNavigationState(updatedState);
      
      if (result.isSuccess) {
        _navigationState = updatedState;
        AppLogger.info('Navigated to: $route');
        notifyListeners();
      } else {
        _setError(result.error);
      }
    } catch (e) {
      final appError = ErrorHandler.handleError(e, code: 'NAVIGATE_ERROR');
      _setError(appError);
      AppLogger.logAppError(appError);
    }
  }
  
  Future<void> navigateBack() async {
    if (_navigationState == null || _navigationState!.history.length <= 1) {
      return;
    }
    
    await _clearError();
    
    try {
      final updatedHistory = List<String>.from(_navigationState!.history);
      updatedHistory.removeLast();
      
      final previousRoute = updatedHistory.isNotEmpty ? updatedHistory.last : '/';
      
      final updatedState = _navigationState!.copyWith(
        currentRoute: previousRoute,
        history: updatedHistory,
      );
      
      final result = await _configService.saveNavigationState(updatedState);
      
      if (result.isSuccess) {
        _navigationState = updatedState;
        AppLogger.info('Navigated back to: $previousRoute');
        notifyListeners();
      } else {
        _setError(result.error);
      }
    } catch (e) {
      final appError = ErrorHandler.handleError(e, code: 'NAVIGATE_BACK_ERROR');
      _setError(appError);
      AppLogger.logAppError(appError);
    }
  }
  
  Future<void> resetNavigation() async {
    if (_navigationState == null) {
      return;
    }
    
    await _clearError();
    
    try {
      final resetState = const NavigationState(
        currentRoute: '/',
        history: ['/'],
        parameters: {},
      );
      
      final result = await _configService.saveNavigationState(resetState);
      
      if (result.isSuccess) {
        _navigationState = resetState;
        AppLogger.info('Navigation reset to initial state');
        notifyListeners();
      } else {
        _setError(result.error);
      }
    } catch (e) {
      final appError = ErrorHandler.handleError(e, code: 'RESET_NAVIGATION_ERROR');
      _setError(appError);
      AppLogger.logAppError(appError);
    }
  }
  
  // Configuration reset
  Future<void> resetToDefaults() async {
    await _setLoading(true);
    await _clearError();
    
    try {
      final result = await _configService.resetToDefaults();
      
      if (result.isSuccess) {
        // Reload configuration
        final configResult = await _configService.getAppConfiguration();
        if (configResult.isSuccess && configResult.data != null) {
          _appConfiguration = configResult.data!;
        }
        
        // Reload navigation state
        final navResult = await _configService.getNavigationState();
        if (navResult.isSuccess && navResult.data != null) {
          _navigationState = navResult.data!;
        }
        
        AppLogger.info('Configuration reset to defaults');
        notifyListeners();
      } else {
        _setError(result.error);
      }
    } catch (e) {
      final appError = ErrorHandler.handleError(e, code: 'RESET_CONFIG_ERROR');
      _setError(appError);
      AppLogger.logAppError(appError);
    } finally {
      await _setLoading(false);
    }
  }
  
  // Error handling
  void clearError() {
    _clearError();
    notifyListeners();
  }
  
  // Private methods
  Future<void> _setLoading(bool loading) async {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }
  
  Future<void> _setError(AppError? error) async {
    if (_error != error) {
      _error = error;
      if (error != null) {
        AppLogger.logAppError(error);
      }
      notifyListeners();
    }
  }
  
  Future<void> _clearError() async {
    if (_error != null) {
      _error = null;
      notifyListeners();
    }
  }
  
  // Status indicator management
  void updateAIProvider(String provider) {
    if (_aiProvider != provider) {
      _aiProvider = provider;
      notifyListeners();
    }
  }
  
  void updateAtlassianStatus(bool active) {
    if (_atlassianActive != active) {
      _atlassianActive = active;
      notifyListeners();
    }
  }
  
  void updateMusicStatus(bool active, {int? balance, String? genre}) {
    bool changed = false;
    if (_musicActive != active) {
      _musicActive = active;
      changed = true;
    }
    if (balance != null && _musicBalance != balance) {
      _musicBalance = balance;
      changed = true;
    }
    if (genre != null && _musicGenre != genre) {
      _musicGenre = genre;
      changed = true;
    }
    if (changed) {
      notifyListeners();
    }
  }
  
  Future<void> refreshMusicBalance() async {
    // Simulate API call to refresh balance
    await Future.delayed(const Duration(milliseconds: 500));
    _musicBalance = 150; // Example balance
    notifyListeners();
  }
}
