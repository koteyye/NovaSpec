import 'dart:io';
import 'package:flutter/foundation.dart';
import '../utils/helpers.dart';
import '../../shared/models/app_error.dart';
import 'cache_service.dart';

/// Comprehensive error handling service for edge cases
class ErrorHandlingService {
  static ErrorHandlingService? _instance;
  static ErrorHandlingService get instance => _instance ??= ErrorHandlingService._();
  
  ErrorHandlingService._();

  /// Handle file system errors
  AppError handleFileSystemError(dynamic error, String operation) {
    if (error is FileSystemException) {
      switch (error.osError?.errorCode) {
        case 2: // No such file or directory
          return AppError(
            type: ErrorType.fileSystem,
            severity: ErrorSeverity.medium,
            code: 'FILE_NOT_FOUND',
            message: 'File or directory not found',
            details: 'Path: ${error.path}, Operation: $operation',
            timestamp: DateTime.now(),
          );
        case 13: // Permission denied
          return AppError(
            type: ErrorType.fileSystem,
            severity: ErrorSeverity.high,
            code: 'PERMISSION_DENIED',
            message: 'Permission denied',
            details: 'Path: ${error.path}, Operation: $operation',
            timestamp: DateTime.now(),
          );
        case 28: // No space left on device
          return AppError(
            type: ErrorType.fileSystem,
            severity: ErrorSeverity.critical,
            code: 'NO_SPACE_LEFT',
            message: 'No space left on device',
            details: 'Path: ${error.path}, Operation: $operation',
            timestamp: DateTime.now(),
          );
        default:
          return AppError(
            type: ErrorType.fileSystem,
            severity: ErrorSeverity.medium,
            code: 'FILE_SYSTEM_ERROR',
            message: 'File system operation failed',
            details: 'Error: ${error.message}, Path: ${error.path}, Operation: $operation',
            timestamp: DateTime.now(),
          );
      }
    }
    
    return AppError(
      type: ErrorType.fileSystem,
      severity: ErrorSeverity.medium,
      code: 'UNKNOWN_FILE_ERROR',
      message: 'Unknown file system error',
      details: 'Error: $error, Operation: $operation',
      timestamp: DateTime.now(),
    );
  }

  /// Handle memory errors
  AppError handleMemoryError(dynamic error, String operation) {
    if (error.toString().contains('OutOfMemoryError')) {
      return AppError(
        type: ErrorType.memory,
        severity: ErrorSeverity.critical,
        code: 'OUT_OF_MEMORY',
        message: 'Application ran out of memory',
        details: 'Operation: $operation, Error: $error',
        timestamp: DateTime.now(),
      );
    }
    
    return AppError(
      type: ErrorType.memory,
      severity: ErrorSeverity.medium,
      code: 'MEMORY_ERROR',
      message: 'Memory operation failed',
      details: 'Operation: $operation, Error: $error',
      timestamp: DateTime.now(),
    );
  }

  /// Handle network errors
  AppError handleNetworkError(dynamic error, String operation) {
    if (error is SocketException) {
      return AppError(
        type: ErrorType.network,
        severity: ErrorSeverity.medium,
        code: 'NETWORK_ERROR',
        message: 'Network connection failed',
        details: 'Operation: $operation, Error: ${error.message}',
        timestamp: DateTime.now(),
      );
    }
    
    if (error.toString().contains('TimeoutException')) {
      return AppError(
        type: ErrorType.network,
        severity: ErrorSeverity.medium,
        code: 'NETWORK_TIMEOUT',
        message: 'Network operation timed out',
        details: 'Operation: $operation, Error: $error',
        timestamp: DateTime.now(),
      );
    }
    
    return AppError(
      type: ErrorType.network,
      severity: ErrorSeverity.medium,
      code: 'UNKNOWN_NETWORK_ERROR',
      message: 'Unknown network error',
      details: 'Operation: $operation, Error: $error',
      timestamp: DateTime.now(),
    );
  }

  /// Handle validation errors
  AppError handleValidationError(String field, dynamic value, String constraint) {
    return AppError(
      type: ErrorType.validation,
      severity: ErrorSeverity.low,
      code: 'VALIDATION_ERROR',
      message: 'Validation failed for field: $field',
      details: 'Value: $value, Constraint: $constraint',
      timestamp: DateTime.now(),
    );
  }

  /// Handle configuration errors
  AppError handleConfigurationError(String configKey, dynamic error) {
    return AppError(
      type: ErrorType.configuration,
      severity: ErrorSeverity.high,
      code: 'CONFIG_ERROR',
      message: 'Configuration error for key: $configKey',
      details: 'Error: $error',
      timestamp: DateTime.now(),
    );
  }

  /// Handle permission errors
  AppError handlePermissionError(String permission, String operation) {
    return AppError(
      type: ErrorType.permission,
      severity: ErrorSeverity.high,
      code: 'PERMISSION_ERROR',
      message: 'Permission denied: $permission',
      details: 'Operation: $operation',
      timestamp: DateTime.now(),
    );
  }

  /// Handle async operation errors
  AppError handleAsyncError(dynamic error, String operation, {StackTrace? stackTrace}) {
    return AppError(
      type: ErrorType.async,
      severity: ErrorSeverity.medium,
      code: 'ASYNC_ERROR',
      message: 'Async operation failed: $operation',
      details: 'Error: $error',
      timestamp: DateTime.now(),
        stackTrace: stackTrace?.toString(),
    );
  }

  /// Check system resources
  Future<List<AppError>> checkSystemResources() async {
    final errors = <AppError>[];
    
    try {
      // Check available memory (simplified check)
      final memoryInfo = await _getMemoryInfo();
      if ((memoryInfo['available'] ?? 0) < 100 * 1024 * 1024) { // Less than 100MB
        errors.add(AppError(
          type: ErrorType.memory,
          severity: ErrorSeverity.high,
          code: 'LOW_MEMORY',
          message: 'Low memory warning',
          details: 'Available memory: ${memoryInfo['available']} bytes',
          timestamp: DateTime.now(),
        ));
      }
      
      // Check disk space
      final diskSpace = await _getDiskSpace();
      if ((diskSpace['free'] ?? 0) < 50 * 1024 * 1024) { // Less than 50MB
        errors.add(AppError(
          type: ErrorType.fileSystem,
          severity: ErrorSeverity.high,
          code: 'LOW_DISK_SPACE',
          message: 'Low disk space warning',
          details: 'Free disk space: ${diskSpace['free']} bytes',
          timestamp: DateTime.now(),
        ));
      }
      
    } catch (e) {
      errors.add(AppError(
        type: ErrorType.system,
        severity: ErrorSeverity.medium,
        code: 'RESOURCE_CHECK_ERROR',
        message: 'Failed to check system resources',
        details: 'Error: $e',
        timestamp: DateTime.now(),
      ));
    }
    
    return errors;
  }

  /// Get memory information (platform-specific implementation would be needed)
  Future<Map<String, int>> _getMemoryInfo() async {
    // Simplified implementation - in real app would use platform-specific APIs
    return {
      'total': 1024 * 1024 * 1024, // 1GB
      'available': 512 * 1024 * 1024, // 512MB
    };
  }

  /// Get disk space information
  Future<Map<String, int>> _getDiskSpace() async {
    try {
      // Simplified - would need platform-specific implementation
      return {
        'total': 10 * 1024 * 1024 * 1024, // 10GB
        'free': 5 * 1024 * 1024 * 1024, // 5GB
      };
    } catch (e) {
      return {
        'total': 0,
        'free': 0,
      };
    }
  }

  /// Validate file path for security
  bool isValidFilePath(String path) {
    if (path.isEmpty) return false;
    
    // Check for path traversal attacks
    if (path.contains('..')) return false;
    
    // Check for invalid characters
    final invalidChars = ['<', '>', ':', '"', '|', '?', '*'];
    for (final char in invalidChars) {
      if (path.contains(char)) return false;
    }
    
    // Check path length
    if (path.length > 260) return false; // Windows MAX_PATH limit
    
    return true;
  }

  /// Validate URL for security
  bool isValidUrl(String url) {
    try {
      final uri = Uri.parse(url);
      
      // Only allow http and https schemes
      if (!['http', 'https'].contains(uri.scheme)) {
        return false;
      }
      
      // Check for localhost in production (optional security measure)
      if (kReleaseMode && (uri.host == 'localhost' || uri.host == '127.0.0.1')) {
        return false;
      }
      
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Sanitize user input
  String sanitizeInput(String input, {int maxLength = 1000}) {
    if (input.isEmpty) return '';
    
    // Remove potentially dangerous characters
    String sanitized = input
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#x27;')
        .replaceAll('/', '&#x2F;');
    
    // Limit length
    if (sanitized.length > maxLength) {
      sanitized = sanitized.substring(0, maxLength);
    }
    
    return sanitized.trim();
  }

  /// Handle critical errors with recovery attempts
  Future<bool> handleCriticalError(AppError error) async {
    AppLogger.logAppError(error);
    
    switch (error.code) {
      case 'OUT_OF_MEMORY':
        return await _handleOutOfMemory();
      case 'NO_SPACE_LEFT':
        return await _handleNoSpaceLeft();
      case 'PERMISSION_DENIED':
        return await _handlePermissionDenied();
      default:
        return false;
    }
  }

  Future<bool> _handleOutOfMemory() async {
    try {
      // Clear caches
      await CacheService.instance.clear();
      
      // Force garbage collection
      if (!kReleaseMode) {
        // In debug mode, we can hint garbage collection
        await Future.delayed(const Duration(milliseconds: 100));
      }
      
      return true;
    } catch (e) {
      AppLogger.logError('Failed to handle out of memory: $e');
      return false;
    }
  }

  Future<bool> _handleNoSpaceLeft() async {
    try {
      // Clear temporary files
      await CacheService.instance.clear();
      
      // Log the issue for user to take manual action
      AppLogger.logError('Critical: No space left on device. Please free up disk space.');
      
      return true;
    } catch (e) {
      AppLogger.logError('Failed to handle no space left: $e');
      return false;
    }
  }

  Future<bool> _handlePermissionDenied() async {
    try {
      // Log permission issue for user
      AppLogger.logError('Critical: Permission denied. Please check application permissions.');
      
      return true;
    } catch (e) {
      AppLogger.logError('Failed to handle permission denied: $e');
      return false;
    }
  }
}