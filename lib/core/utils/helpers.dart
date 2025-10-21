import 'dart:convert';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../shared/models/app_error.dart';
import '../services/toast_service.dart';

class AppLogger {
  static const String _tag = 'NovaSpec';
  
  static void debug(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    if (kDebugMode) {
      developer.log(
        message,
        name: tag ?? _tag,
        time: DateTime.now(),
        level: 500,
        error: error,
        stackTrace: stackTrace,
      );
    }
  }
  
  static void info(String message, {String? tag}) {
    developer.log(
      message,
      name: tag ?? _tag,
      time: DateTime.now(),
      level: 800,
    );
  }
  
  static void warning(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    developer.log(
      message,
      name: tag ?? _tag,
      time: DateTime.now(),
      level: 900,
      error: error,
      stackTrace: stackTrace,
    );
  }
  
  static void error(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    developer.log(
      message,
      name: tag ?? _tag,
      time: DateTime.now(),
      level: 1000,
      error: error,
      stackTrace: stackTrace,
    );
  }
  
  static void logError(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    AppLogger.error(message, tag: tag, error: error, stackTrace: stackTrace);
  }
  
  static void logAppError(AppError appError, {String? tag}) {
    final logTag = tag ?? _tag;
    final message = '[${appError.type.name}] ${appError.code}: ${appError.message}';
    
    switch (appError.severity) {
      case ErrorSeverity.low:
        debug(message, tag: logTag, error: appError.details);
        break;
      case ErrorSeverity.medium:
        warning(message, tag: logTag, error: appError.details);
        break;
      case ErrorSeverity.high:
      case ErrorSeverity.critical:
        error(message, tag: logTag, error: appError.details, stackTrace: appError.stackTrace != null ? StackTrace.fromString(appError.stackTrace!) : null);
        break;
    }
  }
}

class ErrorHandler {
  static AppError handleError(dynamic error, {String? code, String? message, ErrorType? type, ErrorSeverity? severity}) {
    if (error is AppError) {
      return error;
    }
    
    final errorType = type ?? _determineErrorType(error);
    final errorSeverity = severity ?? _determineErrorSeverity(error);
    final errorCode = code ?? 'UNKNOWN_ERROR';
    final errorMessage = message ?? error?.toString() ?? 'Unknown error occurred';
    
    return AppError(
      type: errorType,
      severity: errorSeverity,
      code: errorCode,
      message: errorMessage,
      details: error?.toString(),
      timestamp: DateTime.now(),
      stackTrace: error is Error ? error.stackTrace?.toString() : StackTrace.current.toString(),
    );
  }
  
  static ErrorType _determineErrorType(dynamic error) {
    final errorString = error?.toString().toLowerCase() ?? '';
    
    if (errorString.contains('network') || errorString.contains('connection') || errorString.contains('timeout')) {
      return ErrorType.network;
    } else if (errorString.contains('file') || errorString.contains('directory') || errorString.contains('path')) {
      return ErrorType.fileSystem;
    } else if (errorString.contains('permission') || errorString.contains('access')) {
      return ErrorType.permission;
    } else if (errorString.contains('validation') || errorString.contains('invalid')) {
      return ErrorType.validation;
    } else if (errorString.contains('auth') || errorString.contains('unauthorized')) {
      return ErrorType.authentication;
    } else if (errorString.contains('config') || errorString.contains('setting')) {
      return ErrorType.configuration;
    } else if (errorString.contains('storage')) {
      return ErrorType.storage;
    }
    
    return ErrorType.unknown;
  }
  
  static ErrorSeverity _determineErrorSeverity(dynamic error) {
    final errorString = error?.toString().toLowerCase() ?? '';
    
    if (errorString.contains('critical') || errorString.contains('fatal')) {
      return ErrorSeverity.critical;
    } else if (errorString.contains('timeout') || errorString.contains('connection') || errorString.contains('permission denied')) {
      return ErrorSeverity.high;
    } else if (errorString.contains('warning') || errorString.contains('deprecated')) {
      return ErrorSeverity.low;
    }
    
    return ErrorSeverity.medium;
  }
}

class ValidationHelper {
  static bool isEmpty(String? value) {
    return value == null || value.trim().isEmpty;
  }
  
  static bool isValidEmail(String? email) {
    if (isEmpty(email)) return false;
    
    return RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(email!);
  }
  
  static bool isValidUrl(String? url) {
    if (isEmpty(url)) return false;
    
    try {
      final uri = Uri.parse(url!);
      return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (e) {
      return false;
    }
  }
  
  static bool isValidLength(String? value, int minLength, int maxLength) {
    if (value == null) return false;
    
    return value.length >= minLength && value.length <= maxLength;
  }
  
  static bool isNumeric(String? value) {
    if (isEmpty(value)) return false;
    
    return double.tryParse(value!) != null;
  }
  
  static bool isInRange(num? value, num min, num max) {
    if (value == null) return false;
    
    return value >= min && value <= max;
  }
}

class DateTimeHelper {
  static String formatDate(DateTime date, {String format = 'yyyy-MM-dd'}) {
    switch (format) {
      case 'yyyy-MM-dd':
        return '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      case 'dd-MM-yyyy':
        return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year.toString().padLeft(4, '0')}';
      case 'MM-dd-yyyy':
        return '${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}-${date.year.toString().padLeft(4, '0')}';
      default:
        return DateFormat(format).format(date);
    }
  }
  
  static String formatTime(DateTime time, {bool includeSeconds = false}) {
    final hours = time.hour.toString().padLeft(2, '0');
    final minutes = time.minute.toString().padLeft(2, '0');
    
    if (includeSeconds) {
      final seconds = time.second.toString().padLeft(2, '0');
      return '$hours:$minutes:$seconds';
    }
    
    return '$hours:$minutes';
  }
  
  static String formatDateTime(DateTime dateTime, {String dateFormat = 'yyyy-MM-dd', bool includeSeconds = false}) {
    final dateStr = formatDate(dateTime, format: dateFormat);
    final timeStr = formatTime(dateTime, includeSeconds: includeSeconds);
    return '$dateStr $timeStr';
  }
  
  static DateTime? parseDate(String? dateString, {String format = 'yyyy-MM-dd'}) {
    if (dateString == null || dateString.isEmpty) return null;
    
    try {
      return DateTime.parse(dateString);
    } catch (e) {
      try {
        final parts = dateString.split('-');
        if (parts.length == 3) {
          final year = int.parse(parts[0]);
          final month = int.parse(parts[1]);
          final day = int.parse(parts[2]);
          return DateTime(year, month, day);
        }
      } catch (e) {
        return null;
      }
      return null;
    }
  }
  
  static String getRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }
}

class StringHelper {
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }
  
  static String titleCase(String text) {
    if (text.isEmpty) return text;
    
    return text.split(' ').map((word) => capitalize(word)).join(' ');
  }
  
  static String truncate(String text, int maxLength, {String suffix = '...'}) {
    if (text.length <= maxLength) return text;
    
    return text.substring(0, maxLength - suffix.length) + suffix;
  }
  
  static String removeExtraWhitespace(String text) {
    return text.replaceAll(RegExp(r'\s+'), ' ').trim();
  }
  
  static bool isValidJson(String text) {
    try {
      // ignore: unused_local_variable
      final decoded = jsonDecode(text);
      return true;
    } catch (e) {
      return false;
    }
  }
}

class Helpers {
  // Форматирование даты
  static String formatDate(DateTime date, {String format = 'dd.MM.yyyy'}) {
    return DateFormat(format).format(date);
  }

  // Форматирование времени
  static String formatTime(DateTime time, {String format = 'HH:mm'}) {
    return DateFormat(format).format(time);
  }

  // Форматирование даты и времени
  static String formatDateTime(DateTime dateTime, {String format = 'dd.MM.yyyy HH:mm'}) {
    return DateFormat(format).format(dateTime);
  }

  // Проверка валидности email
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  // Проверка валидности телефона
  static bool isValidPhone(String phone) {
    return RegExp(r'^\+?[\d\s\-\(\)]+$').hasMatch(phone);
  }

  // Форматирование размера файла
  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  // Получение расширения файла
  static String getFileExtension(String fileName) {
    return fileName.split('.').last.toLowerCase();
  }

  // Проверка является ли файл изображением
  static bool isImageFile(String fileName) {
    final extension = getFileExtension(fileName);
    return ['jpg', 'jpeg', 'png', 'gif', 'svg', 'webp'].contains(extension);
  }

  // Проверка является ли файл документом
  static bool isDocumentFile(String fileName) {
    final extension = getFileExtension(fileName);
    return ['pdf', 'doc', 'docx', 'txt', 'md', 'rtf'].contains(extension);
  }

  // Генерация уникального ID
  static String generateUniqueId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  // Капитализация первой буквы
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  // Обрезка текста с добавлением многоточия
  static String truncateText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength - 3)}...';
  }

  // Удаление HTML тегов
  static String removeHtmlTags(String htmlText) {
    final RegExp exp = RegExp(r'<[^>]*>', multiLine: true, caseSensitive: true);
    return htmlText.replaceAll(exp, '');
  }

  // Конвертация цвета в MaterialColor
  static MaterialColor createMaterialColor(Color color) {
    final strengths = <double>[.05];
    final swatch = <int, Color>{};
    final int r = (color.r * 255.0).round(), g = (color.g * 255.0).round(), b = (color.b * 255.0).round();

    for (int i = 1; i < 10; i++) {
      strengths.add(0.1 * i);
    }
    for (var strength in strengths) {
      final double ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    }
    return MaterialColor(color.toARGB32(), swatch);
  }

  // Показать Toast (замена SnackBar)
  static void showSnackBar(BuildContext context, String message, {Color? backgroundColor}) {
    // Use ToastService instead of ScaffoldMessenger
    if (backgroundColor == Colors.green || backgroundColor == Colors.lightGreen) {
      success(description: message);
    } else if (backgroundColor == Colors.red || backgroundColor == Colors.redAccent) {
      error(description: message);
    } else if (backgroundColor == Colors.orange || backgroundColor == Colors.amber) {
      warning(description: message);
    } else {
      show(description: message);
    }
  }

  // Показать диалог подтверждения
  static Future<bool> showConfirmationDialog(
    BuildContext context,
    String title,
    String message,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('OK'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  // Безопасное навигационное push
  static Future<T?> safeNavigate<T>(BuildContext context, Widget page) {
    return Navigator.of(context).push<T>(
      MaterialPageRoute(builder: (context) => page),
    );
  }

  // Безопасное навигационное replace
  static Future<T?> safeNavigateReplace<T>(BuildContext context, Widget page) {
    return Navigator.of(context).pushReplacement<T, T>(
      MaterialPageRoute(builder: (context) => page),
    );
  }

  // Получение безопасного цвета
  static Color getSafeColor(String colorString) {
    try {
      return Color(int.parse(colorString.replaceFirst('#', '0xFF')));
    } catch (e) {
      return Colors.grey;
    }
  }

  // Проверка на null или пустое значение
  static bool isNullOrEmpty(String? value) {
    return value == null || value.trim().isEmpty;
  }

  // Получение initials из имени
  static String getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '';
  }
}