import 'dart:io';
import 'package:flutter/foundation.dart';
import '../../core/services/toast_service.dart';
import '../../shared/models/toast_model.dart';

enum ErrorType {
  validation,
  fileSystem,
  network,
  permission,
  diskSpace,
  corrupted,
  inaccessible,
  unknown,
}

enum ErrorSeverity {
  info,
  warning,
  error,
  critical,
}

class AppError {
  final String title;
  final String message;
  final String? details;
  final ErrorType type;
  final ErrorSeverity severity;
  final DateTime timestamp;
  final String? code;
  final Map<String, dynamic>? context;

  const AppError({
    required this.title,
    required this.message,
    this.details,
    required this.type,
    required this.severity,
    required this.timestamp,
    this.code,
    this.context,
  });

  factory AppError.validation({
    required String title,
    required String message,
    String? details,
    String? code,
    Map<String, dynamic>? context,
  }) {
    return AppError(
      title: title,
      message: message,
      details: details,
      type: ErrorType.validation,
      severity: ErrorSeverity.warning,
      timestamp: DateTime.now(),
      code: code,
      context: context,
    );
  }

  factory AppError.fileSystem({
    required String title,
    required String message,
    String? details,
    String? code,
    Map<String, dynamic>? context,
  }) {
    return AppError(
      title: title,
      message: message,
      details: details,
      type: ErrorType.fileSystem,
      severity: ErrorSeverity.error,
      timestamp: DateTime.now(),
      code: code,
      context: context,
    );
  }

  factory AppError.permission({
    required String title,
    required String message,
    String? details,
    String? code,
    Map<String, dynamic>? context,
  }) {
    return AppError(
      title: title,
      message: message,
      details: details,
      type: ErrorType.permission,
      severity: ErrorSeverity.error,
      timestamp: DateTime.now(),
      code: code,
      context: context,
    );
  }

  factory AppError.diskSpace({
    required String title,
    required String message,
    String? details,
    String? code,
    Map<String, dynamic>? context,
  }) {
    return AppError(
      title: title,
      message: message,
      details: details,
      type: ErrorType.diskSpace,
      severity: ErrorSeverity.critical,
      timestamp: DateTime.now(),
      code: code,
      context: context,
    );
  }

  factory AppError.corrupted({
    required String title,
    required String message,
    String? details,
    String? code,
    Map<String, dynamic>? context,
  }) {
    return AppError(
      title: title,
      message: message,
      details: details,
      type: ErrorType.corrupted,
      severity: ErrorSeverity.error,
      timestamp: DateTime.now(),
      code: code,
      context: context,
    );
  }

  factory AppError.inaccessible({
    required String title,
    required String message,
    String? details,
    String? code,
    Map<String, dynamic>? context,
  }) {
    return AppError(
      title: title,
      message: message,
      details: details,
      type: ErrorType.inaccessible,
      severity: ErrorSeverity.warning,
      timestamp: DateTime.now(),
      code: code,
      context: context,
    );
  }

  factory AppError.network({
    required String title,
    required String message,
    String? details,
    String? code,
    Map<String, dynamic>? context,
  }) {
    return AppError(
      title: title,
      message: message,
      details: details,
      type: ErrorType.network,
      severity: ErrorSeverity.error,
      timestamp: DateTime.now(),
      code: code,
      context: context,
    );
  }

  factory AppError.unknown({
    required String title,
    required String message,
    String? details,
    String? code,
    Map<String, dynamic>? context,
  }) {
    return AppError(
      title: title,
      message: message,
      details: details,
      type: ErrorType.unknown,
      severity: ErrorSeverity.error,
      timestamp: DateTime.now(),
      code: code,
      context: context,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'message': message,
      'details': details,
      'type': type.name,
      'severity': severity.name,
      'timestamp': timestamp.toIso8601String(),
      'code': code,
      'context': context,
    };
  }

  @override
  String toString() {
    return 'AppError(title: $title, message: $message, type: $type, severity: $severity)';
  }
}

class ErrorService {
  static final ErrorService _instance = ErrorService._internal();
  factory ErrorService() => _instance;
  ErrorService._internal();

  final List<AppError> _errorHistory = [];
  final List<Function(AppError)> _errorListeners = [];

  // Get error history
  List<AppError> get errorHistory => List.unmodifiable(_errorHistory);

  // Add error listener
  void addErrorListener(Function(AppError) listener) {
    _errorListeners.add(listener);
  }

  // Remove error listener
  void removeErrorListener(Function(AppError) listener) {
    _errorListeners.remove(listener);
  }

  // Handle and report error
  void handleError(AppError error, {bool showToUser = true}) {
    // Add to history
    _errorHistory.add(error);
    
    // Keep only last 100 errors
    if (_errorHistory.length > 100) {
      _errorHistory.removeAt(0);
    }

    // Notify listeners
    for (final listener in _errorListeners) {
      try {
        listener(error);
      } catch (e) {
        debugPrint('Error in error listener: $e');
      }
    }

    // Log error
    _logError(error);

    // Show to user if requested
    if (showToUser) {
      _showErrorToUser(error);
    }
  }

  // Handle exception
  void handleException(
    Exception exception, {
    String? title,
    String? message,
    ErrorType? type,
    ErrorSeverity? severity,
    String? code,
    Map<String, dynamic>? context,
    bool showToUser = true,
  }) {
    final error = _createErrorFromException(
      exception,
      title: title,
      message: message,
      type: type,
      severity: severity,
      code: code,
      context: context,
    );

    handleError(error, showToUser: showToUser);
  }

  // Create error from exception
  AppError _createErrorFromException(
    Exception exception, {
    String? title,
    String? message,
    ErrorType? type,
    ErrorSeverity? severity,
    String? code,
    Map<String, dynamic>? context,
  }) {
    // Handle common exception types
    if (exception is FileSystemException) {
      return _handleFileSystemException(exception, title, message, code, context);
    }

    if (exception is FormatException) {
      return AppError.corrupted(
        title: title ?? 'Ошибка формата',
        message: message ?? 'Неверный формат данных: ${exception.message}',
        details: exception.toString(),
        code: code,
        context: context,
      );
    }

    if (exception is SocketException) {
      return AppError.network(
        title: title ?? 'Сетевая ошибка',
        message: message ?? 'Ошибка сети: ${exception.message}',
        details: exception.toString(),
        code: code,
        context: context,
      );
    }

    // Default handling
    return AppError.unknown(
      title: title ?? 'Неизвестная ошибка',
      message: message ?? exception.toString(),
      details: exception.runtimeType.toString(),
      code: code,
      context: context,
    );
  }

  AppError _handleFileSystemException(
    FileSystemException exception, [
    String? title,
    String? message,
    String? code,
    Map<String, dynamic>? context,
  ]) {
    final errorType = _getFileSystemErrorType(exception);
    final errorTitle = title ?? _getFileSystemErrorTitle(errorType);
    final errorMessage = message ?? _getFileSystemErrorMessage(exception, errorType);

    return AppError(
      title: errorTitle,
      message: errorMessage,
      details: exception.toString(),
      type: errorType,
      severity: _getFileSystemErrorSeverity(errorType),
      timestamp: DateTime.now(),
      code: code ?? exception.osError?.errorCode.toString(),
      context: {
        'path': exception.path,
        'osError': exception.osError?.toString(),
        ...?context,
      },
    );
  }

  ErrorType _getFileSystemErrorType(FileSystemException exception) {
    final message = exception.message.toLowerCase();
    final osError = exception.osError;

    if (message.contains('permission denied') || 
        message.contains('доступ запрещен') ||
        osError?.errorCode == 13) {
      return ErrorType.permission;
    }

    if (message.contains('no space left') || 
        message.contains('места на диске') ||
        osError?.errorCode == 28) {
      return ErrorType.diskSpace;
    }

    if (message.contains('no such file') || 
        message.contains('не найден') ||
        message.contains('not found')) {
      return ErrorType.inaccessible;
    }

    return ErrorType.fileSystem;
  }

  String _getFileSystemErrorTitle(ErrorType type) {
    switch (type) {
      case ErrorType.permission:
        return 'Ошибка доступа';
      case ErrorType.diskSpace:
        return 'Недостаточно места';
      case ErrorType.inaccessible:
        return 'Файл недоступен';
      default:
        return 'Ошибка файловой системы';
    }
  }

  String _getFileSystemErrorMessage(FileSystemException exception, ErrorType type) {
    switch (type) {
      case ErrorType.permission:
        return 'Нет прав доступа к файлу или директории';
      case ErrorType.diskSpace:
        return 'Недостаточно места на диске для выполнения операции';
      case ErrorType.inaccessible:
        return 'Файл или директория не найдены или недоступны';
      default:
        return 'Ошибка при работе с файловой системой: ${exception.message}';
    }
  }

  ErrorSeverity _getFileSystemErrorSeverity(ErrorType type) {
    switch (type) {
      case ErrorType.diskSpace:
        return ErrorSeverity.critical;
      case ErrorType.permission:
      case ErrorType.corrupted:
        return ErrorSeverity.error;
      case ErrorType.inaccessible:
        return ErrorSeverity.warning;
      default:
        return ErrorSeverity.error;
    }
  }

  void _logError(AppError error) {
    if (kDebugMode) {
      debugPrint('=== ERROR ===');
      debugPrint('Title: ${error.title}');
      debugPrint('Message: ${error.message}');
      debugPrint('Type: ${error.type}');
      debugPrint('Severity: ${error.severity}');
      debugPrint('Timestamp: ${error.timestamp}');
      if (error.details != null) {
        debugPrint('Details: ${error.details}');
      }
      if (error.code != null) {
        debugPrint('Code: ${error.code}');
      }
      if (error.context != null) {
        debugPrint('Context: ${error.context}');
      }
      debugPrint('============');
    }
  }

  void _showErrorToUser(AppError error) {
    final toastService = ToastService();
    switch (error.severity) {
      case ErrorSeverity.info:
        toastService.showToast(description: error.message, variant: ToastVariant.info);
        break;
      case ErrorSeverity.warning:
        toastService.showWarning(description: error.message);
        break;
      case ErrorSeverity.error:
        toastService.showError(description: error.message);
        break;
      case ErrorSeverity.critical:
        toastService.showError(description: error.message);
        // For critical errors, you might want to show a dialog
        break;
    }
  }

  // Clear error history
  void clearErrorHistory() {
    _errorHistory.clear();
  }

  // Get errors by type
  List<AppError> getErrorsByType(ErrorType type) {
    return _errorHistory.where((error) => error.type == type).toList();
  }

  // Get errors by severity
  List<AppError> getErrorsBySeverity(ErrorSeverity severity) {
    return _errorHistory.where((error) => error.severity == severity).toList();
  }

  // Get recent errors (last 24 hours)
  List<AppError> getRecentErrors() {
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));
    
    return _errorHistory.where((error) => error.timestamp.isAfter(yesterday)).toList();
  }

  // Export error history
  Map<String, dynamic> exportErrorHistory() {
    return {
      'exportedAt': DateTime.now().toIso8601String(),
      'totalErrors': _errorHistory.length,
      'errors': _errorHistory.map((error) => error.toJson()).toList(),
    };
  }
}

// Extension for easier error handling
extension ErrorHandling<T> on Future<T> {
  Future<T> handleError({
    String? title,
    String? message,
    ErrorType? type,
    ErrorSeverity? severity,
    String? code,
    Map<String, dynamic>? context,
    bool showToUser = true,
  }) {
    return catchError((error) {
      final errorService = ErrorService();
      
      if (error is Exception) {
        errorService.handleException(
          error,
          title: title,
          message: message,
          type: type,
          severity: severity,
          code: code,
          context: context,
          showToUser: showToUser,
        );
      } else {
        errorService.handleError(
          AppError.unknown(
            title: title ?? 'Ошибка',
            message: error.toString(),
            code: code,
            context: context,
          ),
          showToUser: showToUser,
        );
      }
      
      throw error;
    });
  }
}
