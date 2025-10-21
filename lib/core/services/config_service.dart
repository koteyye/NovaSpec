import 'dart:async';
import 'dart:convert';
import '../../shared/models/storage_result.dart';
import '../../shared/models/app_error.dart';
import '../../shared/models/app_config.dart';
import '../../shared/models/navigation_state.dart';
import 'storage_service.dart';
import 'cache_service.dart';

abstract class ConfigService {
  Future<void> initialize();
  
  Future<StorageResult<AppConfiguration>> getAppConfiguration();
  
  Future<StorageResult<bool>> saveAppConfiguration(AppConfiguration config);
  
  Future<StorageResult<NavigationState>> getNavigationState();
  
  Future<StorageResult<bool>> saveNavigationState(NavigationState state);
  
  Future<StorageResult<bool>> resetToDefaults();
  
  Future<StorageResult<bool>> validateConfiguration(AppConfiguration config);
}

class ConfigServiceImpl implements ConfigService {
  final StorageService _storageService;
  final CacheService _cacheService = CacheService.instance;
  
  static const String _configKey = 'app_configuration';
  static const String _navigationKey = 'navigation_state';
  static const String _lockPrefix = '_lock_';
  
  // File locking mechanism
  final Map<String, DateTime> _locks = {};
  static const Duration _lockTimeout = Duration(seconds: 30);
  
  ConfigServiceImpl(this._storageService);
  
  @override
  Future<void> initialize() async {
    await _storageService.initialize();
    
    // Initialize default config if not exists
    final hasConfig = await _storageService.containsKey(_configKey);
    if (!hasConfig.isSuccess || !hasConfig.data!) {
      await saveAppConfiguration(_getDefaultConfiguration());
    }
    
    // Initialize default navigation state if not exists
    final hasNavState = await _storageService.containsKey(_navigationKey);
    if (!hasNavState.isSuccess || !hasNavState.data!) {
      await saveNavigationState(_getDefaultNavigationState());
    }
  }
  
  @override
  Future<StorageResult<AppConfiguration>> getAppConfiguration() async {
    // Try cache first
    final cachedConfig = await _cacheService.get<AppConfiguration>(
      _configKey,
      (json) => AppConfiguration.fromJson(json as Map<String, dynamic>),
    );
    
    if (cachedConfig != null) {
      return StorageResult.success(cachedConfig);
    }
    
    return await _withLock(_configKey, () async {
      try {
        final result = await _storageService.get<String>(_configKey);
        if (!result.isSuccess) {
          return StorageResult.failure(result.error!);
        }
        
        if (result.data == null) {
          final defaultConfig = _getDefaultConfiguration();
          await _cacheService.set(
            _configKey,
            defaultConfig,
            (config) => config.toJson(),
            ttl: const Duration(minutes: 30),
          );
          return StorageResult.success(defaultConfig);
        }
        
        final configJson = jsonDecode(result.data!);
        final config = AppConfiguration.fromJson(configJson);
        
        // Cache the result
        await _cacheService.set(
          _configKey,
          config,
          (c) => c.toJson(),
          ttl: const Duration(minutes: 30),
        );
        
        return StorageResult.success(config);
      } catch (e) {
        return StorageResult.failure(
          AppError(
            type: ErrorType.configuration,
            severity: ErrorSeverity.high,
            code: 'GET_CONFIG_ERROR',
            message: 'Failed to get app configuration',
            details: e.toString(),
            timestamp: DateTime.now(),
          ),
        );
      }
    });
  }
  
  @override
  Future<StorageResult<bool>> saveAppConfiguration(AppConfiguration config) async {
    return await _withLock(_configKey, () async {
      try {
        final configJson = jsonEncode(config.toJson());
        final result = await _storageService.set<String>(_configKey, configJson);
        
        // Invalidate cache after successful save
        if (result.isSuccess) {
          await _cacheService.remove(_configKey);
        }
        
        return result;
      } catch (e) {
        return StorageResult.failure(
          AppError(
            type: ErrorType.configuration,
            severity: ErrorSeverity.high,
            code: 'SAVE_CONFIG_ERROR',
            message: 'Failed to save app configuration',
            details: e.toString(),
            timestamp: DateTime.now(),
          ),
        );
      }
    });
  }
  
  @override
  Future<StorageResult<NavigationState>> getNavigationState() async {
    return await _withLock(_navigationKey, () async {
      try {
        final result = await _storageService.get<String>(_navigationKey);
        if (!result.isSuccess) {
          return StorageResult.failure(result.error!);
        }
        
        if (result.data == null) {
          return StorageResult.success(_getDefaultNavigationState());
        }
        
        final stateJson = jsonDecode(result.data!);
        final state = NavigationState.fromJson(stateJson);
        return StorageResult.success(state);
      } catch (e) {
        return StorageResult.failure(
          AppError(
            type: ErrorType.configuration,
            severity: ErrorSeverity.medium,
            code: 'GET_NAVIGATION_ERROR',
            message: 'Failed to get navigation state',
            details: e.toString(),
            timestamp: DateTime.now(),
          ),
        );
      }
    });
  }
  
  @override
  Future<StorageResult<bool>> saveNavigationState(NavigationState state) async {
    return await _withLock(_navigationKey, () async {
      try {
        final stateJson = jsonEncode(state.toJson());
        final result = await _storageService.set<String>(_navigationKey, stateJson);
        return result;
      } catch (e) {
        return StorageResult.failure(
          AppError(
            type: ErrorType.configuration,
            severity: ErrorSeverity.medium,
            code: 'SAVE_NAVIGATION_ERROR',
            message: 'Failed to save navigation state',
            details: e.toString(),
            timestamp: DateTime.now(),
          ),
        );
      }
    });
  }
  
  @override
  Future<StorageResult<bool>> resetToDefaults() async {
    try {
      // Clear cache before reset
      await _cacheService.remove(_configKey);
      await _cacheService.remove(_navigationKey);
      
      final configResult = await saveAppConfiguration(_getDefaultConfiguration());
      if (!configResult.isSuccess) {
        return configResult;
      }
      
      final navResult = await saveNavigationState(_getDefaultNavigationState());
      return navResult;
    } catch (e) {
      return StorageResult.failure(
        AppError(
          type: ErrorType.configuration,
          severity: ErrorSeverity.high,
          code: 'RESET_CONFIG_ERROR',
          message: 'Failed to reset configuration to defaults',
          details: e.toString(),
          timestamp: DateTime.now(),
        ),
      );
    }
  }
  
  AppConfiguration _getDefaultConfiguration() {
    return const AppConfiguration(
      language: 'ru',
      theme: 'light',
      autoSave: true,
      notificationsEnabled: true,
      lastOpenedProject: null,
    );
  }
  
  NavigationState _getDefaultNavigationState() {
    return const NavigationState(
      currentRoute: '/',
      history: ['/'],
      parameters: {},
    );
  }
  
  // File locking mechanism implementation
  Future<T> _withLock<T>(String key, Future<T> Function() operation) async {
    final lockKey = '$_lockPrefix$key';
    
    // Wait for existing lock to be released
    while (_isLocked(lockKey)) {
      await Future.delayed(const Duration(milliseconds: 100));
    }
    
    // Acquire lock
    _acquireLock(lockKey);
    
    try {
      return await operation();
    } finally {
      _releaseLock(lockKey);
    }
  }
  
  bool _isLocked(String lockKey) {
    final lockTime = _locks[lockKey];
    if (lockTime == null) return false;
    
    // Check if lock has expired
    if (DateTime.now().difference(lockTime) > _lockTimeout) {
      _locks.remove(lockKey);
      return false;
    }
    
    return true;
  }
  
  void _acquireLock(String lockKey) {
    _locks[lockKey] = DateTime.now();
  }
  
  void _releaseLock(String lockKey) {
    _locks.remove(lockKey);
  }
  
  // Method to check if configuration is valid
  @override
  Future<StorageResult<bool>> validateConfiguration(AppConfiguration config) async {
    try {
      // Validate language
      if (!['ru', 'en'].contains(config.language)) {
        return StorageResult.failure(
          AppError(
            type: ErrorType.validation,
            severity: ErrorSeverity.medium,
            code: 'INVALID_LANGUAGE',
            message: 'Invalid language configuration',
            details: 'Language must be either "ru" or "en"',
            timestamp: DateTime.now(),
          ),
        );
      }
      
      // Validate theme
      if (!['light', 'dark', 'system'].contains(config.theme)) {
        return StorageResult.failure(
          AppError(
            type: ErrorType.validation,
            severity: ErrorSeverity.medium,
            code: 'INVALID_THEME',
            message: 'Invalid theme configuration',
            details: 'Theme must be either "light", "dark", or "system"',
            timestamp: DateTime.now(),
          ),
        );
      }
      
      return StorageResult.success(true);
    } catch (e) {
      return StorageResult.failure(
        AppError(
          type: ErrorType.validation,
          severity: ErrorSeverity.medium,
          code: 'VALIDATION_ERROR',
          message: 'Configuration validation failed',
          details: e.toString(),
          timestamp: DateTime.now(),
        ),
      );
    }
  }
}