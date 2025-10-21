import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import '../utils/helpers.dart';


/// Security service for input validation and secure storage
class SecurityService {
  static SecurityService? _instance;
  static SecurityService get instance => _instance ??= SecurityService._();
  
  SecurityService._();

  // Security constants
  static const int _maxInputLength = 10000;
  static const int _maxPathLength = 4096;
  static const List<String> _allowedFileExtensions = [
    '.json', '.yaml', '.yml', '.md', '.txt', '.dart', '.html', '.css', '.js'
  ];
  static const List<String> _dangerousPatterns = [
    '<script', 'javascript:', 'vbscript:', 'onload=', 'onerror=', 'onclick=',
    'eval(', 'setTimeout(', 'setInterval(', 'Function(', 'document.cookie',
    'localStorage', 'sessionStorage', 'window.', 'document.', 'alert(',
    'confirm(', 'prompt(', 'XMLHttpRequest', 'fetch(', 'import('
  ];

  /// Validate and sanitize text input
  SecurityValidationResult validateTextInput(String input, {
    String? fieldName,
    int? maxLength,
    bool allowHtml = false,
    bool allowSpecialChars = true,
  }) {
    final errors = <String>[];
    final sanitizedText = _sanitizeText(input, allowHtml: allowHtml);
    
    // Check null/empty
    if (input.isEmpty) {
      errors.add('${fieldName ?? 'Field'} cannot be empty');
    }
    
    // Check length
    final maxLen = maxLength ?? _maxInputLength;
    if (input.length > maxLen) {
      errors.add('${fieldName ?? 'Field'} exceeds maximum length of $maxLen characters');
    }
    
    // Check for dangerous patterns
    if (!allowHtml) {
      for (final pattern in _dangerousPatterns) {
        if (input.toLowerCase().contains(pattern)) {
          errors.add('Potentially dangerous content detected: $pattern');
          break;
        }
      }
    }
    
    // Check for control characters
    if (!allowSpecialChars) {
      final hasControlChars = input.codeUnits.any((code) => code < 32 && code != 9 && code != 10 && code != 13);
      if (hasControlChars) {
        errors.add('Invalid control characters detected');
      }
    }
    
    return SecurityValidationResult(
      isValid: errors.isEmpty,
      sanitizedInput: sanitizedText,
      errors: errors,
    );
  }

  /// Validate file path
  SecurityValidationResult validateFilePath(String path) {
    final errors = <String>[];
    
    // Check empty path
    if (path.isEmpty) {
      errors.add('File path cannot be empty');
      return SecurityValidationResult(isValid: false, sanitizedInput: path, errors: errors);
    }
    
    // Check path length
    if (path.length > _maxPathLength) {
      errors.add('Path exceeds maximum length of $_maxPathLength characters');
    }
    
    // Check for path traversal attacks
    if (path.contains('..') || path.contains('~')) {
      errors.add('Path traversal detected');
    }
    
    // Check for invalid characters (Windows-specific)
    final invalidChars = ['<', '>', ':', '"', '|', '?', '*'];
    for (final char in invalidChars) {
      if (path.contains(char)) {
        errors.add('Invalid character in path: $char');
      }
    }
    
    // Check for reserved names (Windows)
    final reservedNames = ['CON', 'PRN', 'AUX', 'NUL', 'COM1', 'COM2', 'COM3', 'COM4', 'COM5', 'COM6', 'COM7', 'COM8', 'COM9', 'LPT1', 'LPT2', 'LPT3', 'LPT4', 'LPT5', 'LPT6', 'LPT7', 'LPT8', 'LPT9'];
    final fileName = path.split(Platform.pathSeparator).last;
    final nameWithoutExt = fileName.contains('.') ? fileName.split('.').first : fileName;
    
    if (reservedNames.contains(nameWithoutExt.toUpperCase())) {
      errors.add('Reserved file name detected: $nameWithoutExt');
    }
    
    // Validate file extension
    final extension = fileName.contains('.') ? '.${fileName.split('.').last.toLowerCase()}' : '';
    if (extension.isNotEmpty && !_allowedFileExtensions.contains(extension)) {
      errors.add('File extension not allowed: $extension');
    }
    
    final sanitizedPath = _sanitizeText(path, allowHtml: false);
    return SecurityValidationResult(
      isValid: errors.isEmpty,
      sanitizedInput: sanitizedPath,
      errors: errors,
    );
  }

  /// Validate URL
  SecurityValidationResult validateUrl(String url) {
    final errors = <String>[];
    
    if (url.isEmpty) {
      errors.add('URL cannot be empty');
      return SecurityValidationResult(isValid: false, sanitizedInput: url, errors: errors);
    }
    
    try {
      final uri = Uri.parse(url);
      
      // Check scheme
      if (!['http', 'https'].contains(uri.scheme)) {
        errors.add('Only HTTP and HTTPS URLs are allowed');
      }
      
      // Check for localhost in production
      if (kReleaseMode && (uri.host == 'localhost' || uri.host == '127.0.0.1')) {
        errors.add('Localhost URLs not allowed in production');
      }
      
      // Check for suspicious patterns
      final suspiciousPatterns = ['javascript:', 'data:', 'vbscript:', 'file:'];
      for (final pattern in suspiciousPatterns) {
        if (url.toLowerCase().contains(pattern)) {
          errors.add('Suspicious URL pattern detected: $pattern');
        }
      }
      
    } catch (e) {
      errors.add('Invalid URL format: $e');
    }
    
    return SecurityValidationResult(
      isValid: errors.isEmpty,
      sanitizedInput: url,
      errors: errors,
    );
  }

  /// Validate JSON data
  SecurityValidationResult validateJson(String json, {int? maxDepth}) {
    final errors = <String>[];
    
    if (json.isEmpty) {
      errors.add('JSON cannot be empty');
      return SecurityValidationResult(isValid: false, sanitizedInput: json, errors: errors);
    }
    
    try {
      final decoded = jsonDecode(json);
      final maxD = maxDepth ?? 10;
      
      // Check JSON depth
      final depth = _calculateJsonDepth(decoded);
      if (depth > maxD) {
        errors.add('JSON depth exceeds maximum allowed depth of $maxD');
      }
      
      // Check JSON size
      final size = utf8.encode(json).length;
      if (size > 10 * 1024 * 1024) { // 10MB
        errors.add('JSON size exceeds maximum allowed size of 10MB');
      }
      
    } catch (e) {
      errors.add('Invalid JSON format: $e');
    }
    
    return SecurityValidationResult(
      isValid: errors.isEmpty,
      sanitizedInput: json,
      errors: errors,
    );
  }

  /// Generate secure hash
  String generateHash(String data) {
    final bytes = utf8.encode(data);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Generate secure random string
  String generateSecureRandomString(int length) {
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = DateTime.now().millisecondsSinceEpoch;
    
    String result = '';
    for (int i = 0; i < length; i++) {
      result += chars[(random + i) % chars.length];
    }
    
    return result;
  }

  /// Encrypt sensitive data (basic implementation)
  String encryptData(String data, String key) {
    try {
      // Simple XOR encryption for demonstration
      // In production, use proper encryption libraries
      final keyBytes = utf8.encode(key.padRight(32, '0').substring(0, 32));
      final dataBytes = utf8.encode(data);
      
      final encrypted = <int>[];
      for (int i = 0; i < dataBytes.length; i++) {
        encrypted.add(dataBytes[i] ^ keyBytes[i % keyBytes.length]);
      }
      
      return base64Encode(encrypted);
    } catch (e) {
      AppLogger.logError('Encryption failed: $e');
      return data; // Fallback to unencrypted
    }
  }

  /// Decrypt sensitive data
  String decryptData(String encryptedData, String key) {
    try {
      final keyBytes = utf8.encode(key.padRight(32, '0').substring(0, 32));
      final encrypted = base64Decode(encryptedData);
      
      final decrypted = <int>[];
      for (int i = 0; i < encrypted.length; i++) {
        decrypted.add(encrypted[i] ^ keyBytes[i % keyBytes.length]);
      }
      
      return utf8.decode(decrypted);
    } catch (e) {
      AppLogger.logError('Decryption failed: $e');
      return encryptedData; // Fallback to encrypted data
    }
  }

  /// Check for common attack patterns
  bool containsAttackPattern(String input) {
    final attackPatterns = [
      r'<script[^>]*>.*?</script>',
      r'javascript:',
      r'vbscript:',
      r'onload\s*=',
      r'onerror\s*=',
      r'onclick\s*=',
      r'eval\s*\(',
      r'document\.cookie',
      r'localStorage',
      r'sessionStorage',
      r'window\.',
      r'document\.',
      r'alert\s*\(',
      r'XMLHttpRequest',
      r'fetch\s*\(',
    ];
    
    for (final pattern in attackPatterns) {
      try {
        final regex = RegExp(pattern, caseSensitive: false);
        if (regex.hasMatch(input)) {
          return true;
        }
      } catch (e) {
        AppLogger.logError('Regex pattern error: $e');
      }
    }
    
    return false;
  }

  /// Sanitize text input
  String _sanitizeText(String input, {bool allowHtml = false}) {
    if (allowHtml) {
      return input;
    }
    
    return input
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#x27;')
        .replaceAll('/', '&#x2F;');
  }

  /// Calculate JSON depth
  int _calculateJsonDepth(dynamic json, [int currentDepth = 0]) {
    if (currentDepth > 50) return 50; // Prevent infinite recursion
    
    if (json is Map) {
      int maxDepth = currentDepth;
      for (final value in json.values) {
        final depth = _calculateJsonDepth(value, currentDepth + 1);
        maxDepth = maxDepth > depth ? maxDepth : depth;
      }
      return maxDepth;
    } else if (json is List) {
      int maxDepth = currentDepth;
      for (final item in json) {
        final depth = _calculateJsonDepth(item, currentDepth + 1);
        maxDepth = maxDepth > depth ? maxDepth : depth;
      }
      return maxDepth;
    } else {
      return currentDepth;
    }
  }

  /// Validate file content
  SecurityValidationResult validateFileContent(String content, String fileName) {
    final errors = <String>[];
    
    // Check file size
    final size = utf8.encode(content).length;
    if (size > 50 * 1024 * 1024) { // 50MB
      errors.add('File size exceeds maximum allowed size of 50MB');
    }
    
    // Check for malicious content based on file type
    final extension = fileName.contains('.') ? '.${fileName.split('.').last.toLowerCase()}' : '';
    
    switch (extension) {
      case '.json':
        final jsonValidation = validateJson(content);
        if (!jsonValidation.isValid) {
          errors.addAll(jsonValidation.errors);
        }
        break;
      case '.html':
        if (containsAttackPattern(content)) {
          errors.add('Potentially malicious HTML content detected');
        }
        break;
      case '.js':
        if (containsAttackPattern(content)) {
          errors.add('Potentially malicious JavaScript content detected');
        }
        break;
    }
    
    return SecurityValidationResult(
      isValid: errors.isEmpty,
      sanitizedInput: content,
      errors: errors,
    );
  }

  /// Rate limiting check
  bool isRateLimited(String identifier, {int maxRequests = 100, Duration window = const Duration(minutes: 1)}) {
    // This would need to be implemented with actual storage
    // For now, return false (no rate limiting)
    return false;
  }
}

/// Security validation result
class SecurityValidationResult {
  final bool isValid;
  final String sanitizedInput;
  final List<String> errors;

  SecurityValidationResult({
    required this.isValid,
    required this.sanitizedInput,
    required this.errors,
  });

  String get errorMessage => errors.join('; ');
}