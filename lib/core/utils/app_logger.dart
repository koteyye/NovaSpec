import 'dart:developer' as developer;
import 'dart:io';

/// Comprehensive logging utility for NovaSpec application
class AppLogger {
  static const String _defaultTag = 'NovaSpec';
  
  // Log levels
  static const int _debugLevel = 0;
  static const int _infoLevel = 1;
  static const int _warningLevel = 2;
  static const int _errorLevel = 3;
  
  // Current log level (can be configured)
  static int _currentLogLevel = _debugLevel;
  
  /// Set the minimum log level
  static void setLogLevel(String level) {
    switch (level.toLowerCase()) {
      case 'debug':
        _currentLogLevel = _debugLevel;
        break;
      case 'info':
        _currentLogLevel = _infoLevel;
        break;
      case 'warning':
      case 'warn':
        _currentLogLevel = _warningLevel;
        break;
      case 'error':
        _currentLogLevel = _errorLevel;
        break;
    }
  }
  
  /// Debug level logging
  static void debug(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    if (_currentLogLevel <= _debugLevel) {
      _log('DEBUG', message, tag: tag, error: error, stackTrace: stackTrace);
    }
  }
  
  /// Info level logging
  static void info(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    if (_currentLogLevel <= _infoLevel) {
      _log('INFO', message, tag: tag, error: error, stackTrace: stackTrace);
    }
  }
  
  /// Warning level logging
  static void warning(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    if (_currentLogLevel <= _warningLevel) {
      _log('WARNING', message, tag: tag, error: error, stackTrace: stackTrace);
    }
  }
  
  /// Error level logging
  static void error(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    if (_currentLogLevel <= _errorLevel) {
      _log('ERROR', message, tag: tag, error: error, stackTrace: stackTrace);
    }
  }
  
  /// Project-specific logging methods
  static void projectCreated(String projectName, String projectPath) {
    info('Project created: $projectName at $projectPath', tag: 'PROJECT');
  }
  
  static void projectOpened(String projectName, String projectPath) {
    info('Project opened: $projectName at $projectPath', tag: 'PROJECT');
  }
  
  static void projectSaved(String projectName) {
    info('Project saved: $projectName', tag: 'PROJECT');
  }
  
  static void projectAccessibilityCheck(String projectId, bool isAccessible) {
    debug('Project accessibility check: $projectId - ${isAccessible ? "accessible" : "inaccessible"}', tag: 'PROJECT_MONITOR');
  }
  
  static void projectStatusChanged(String projectId, String oldStatus, String newStatus) {
    info('Project status changed: $projectId from $oldStatus to $newStatus', tag: 'PROJECT_STATUS');
  }
  
  static void fileMonitoringStarted(String path) {
    debug('File monitoring started: $path', tag: 'FILE_MONITOR');
  }
  
  static void fileMonitoringStopped(String path) {
    debug('File monitoring stopped: $path', tag: 'FILE_MONITOR');
  }
  
  static void fileSystemEvent(String path, String eventType) {
    debug('File system event: $eventType - $path', tag: 'FILE_SYSTEM');
  }
  
  static void syncOperation(String projectId, String operation, {bool success = true}) {
    if (success) {
      info('Sync operation successful: $operation for project $projectId', tag: 'SYNC');
    } else {
      warning('Sync operation failed: $operation for project $projectId', tag: 'SYNC');
    }
  }
  
  static void lockAcquired(String projectId, String instanceId) {
    info('Lock acquired: $projectId by instance $instanceId', tag: 'SYNC_LOCK');
  }
  
  static void lockReleased(String projectId, String instanceId) {
    info('Lock released: $projectId by instance $instanceId', tag: 'SYNC_LOCK');
  }
  
  static void lockConflict(String projectId, String holderInstanceId) {
    warning('Lock conflict: $projectId held by $holderInstanceId', tag: 'SYNC_LOCK');
  }
  
  /// Service-specific logging
  static void serviceInitialized(String serviceName) {
    info('Service initialized: $serviceName', tag: 'SERVICE');
  }
  
  static void serviceError(String serviceName, String operation, Object error) {
    AppLogger.error('Service error: $serviceName during $operation - $error', tag: 'SERVICE_ERROR');
  }
  
  /// UI-specific logging
  static void uiEvent(String eventName, {Map<String, dynamic>? data}) {
    debug('UI event: $eventName${data != null ? ' - $data' : ''}', tag: 'UI');
  }
  
  static void navigationEvent(String from, String to) {
    debug('Navigation: $from -> $to', tag: 'NAVIGATION');
  }
  
  /// Performance logging
  static void performance(String operation, Duration duration, {Map<String, dynamic>? metadata}) {
    info('Performance: $operation took ${duration.inMilliseconds}ms${metadata != null ? ' - $metadata' : ''}', tag: 'PERFORMANCE');
  }
  
  /// Network logging
  static void networkRequest(String method, String url, {int? statusCode, Duration? duration}) {
    if (statusCode != null) {
      info('Network: $method $url - $statusCode${duration != null ? ' (${duration.inMilliseconds}ms)' : ''}', tag: 'NETWORK');
    } else {
      debug('Network: $method $url${duration != null ? ' (${duration.inMilliseconds}ms)' : ''}', tag: 'NETWORK');
    }
  }
  
  static void networkError(String method, String url, Object error) {
    AppLogger.error('Network error: $method $url - $error', tag: 'NETWORK_ERROR');
  }
  
  /// Configuration logging
  static void configurationChanged(String key, dynamic oldValue, dynamic newValue) {
    info('Configuration changed: $key from $oldValue to $newValue', tag: 'CONFIG');
  }
  
  /// Security logging
  static void securityEvent(String event, {String? user, String? resource}) {
    warning('Security: $event${user != null ? ' by $user' : ''}${resource != null ? ' on $resource' : ''}', tag: 'SECURITY');
  }
  
  /// Internal logging method
  static void _log(String level, String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    final timestamp = DateTime.now().toIso8601String();
    final logTag = tag ?? _defaultTag;
    final logMessage = '[$timestamp] [$level] [$logTag] $message';
    
    // Use developer.log for structured logging
    developer.log(
      logMessage,
      time: DateTime.now(),
      level: _getLevelValue(level),
      name: logTag,
      error: error,
      stackTrace: stackTrace,
    );
    
    // Also print to console for immediate visibility
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      print(logMessage);
      if (error != null) {
        print('Error: $error');
      }
      if (stackTrace != null) {
        print('StackTrace: $stackTrace');
      }
    }
  }
  
  /// Convert string level to developer.log level
  static int _getLevelValue(String level) {
    switch (level) {
      case 'DEBUG':
        return 500;
      case 'INFO':
        return 800;
      case 'WARNING':
        return 900;
      case 'ERROR':
        return 1000;
      default:
        return 800;
    }
  }
  
  /// Initialize logger with configuration
  static void initialize({
    String level = 'debug',
    bool enableFileLogging = false,
    String? logFilePath,
  }) {
    setLogLevel(level);
    
    if (enableFileLogging && logFilePath != null) {
      _initializeFileLogging(logFilePath);
    }
    
    info('AppLogger initialized with level: $level', tag: 'LOGGER');
  }
  
  /// Initialize file logging (simplified implementation)
  static void _initializeFileLogging(String logFilePath) {
    // In a real implementation, you would set up file logging here
    // For now, we'll just log that file logging was requested
    info('File logging requested: $logFilePath', tag: 'LOGGER');
  }
  
  /// Get current log statistics
  static Map<String, dynamic> getStats() {
    return {
      'current_level': _getLevelName(_currentLogLevel),
      'timestamp': DateTime.now().toIso8601String(),
      'platform': Platform.operatingSystem,
    };
  }
  
  /// Convert numeric level back to string
  static String _getLevelName(int level) {
    switch (level) {
      case _debugLevel:
        return 'debug';
      case _infoLevel:
        return 'info';
      case _warningLevel:
        return 'warning';
      case _errorLevel:
        return 'error';
      default:
        return 'unknown';
    }
  }
}