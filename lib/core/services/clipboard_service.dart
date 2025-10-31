import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ClipboardData {
  final List<String> paths;
  final bool isCut;
  final DateTime timestamp;

  const ClipboardData({
    required this.paths,
    required this.isCut,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'paths': paths,
      'isCut': isCut,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory ClipboardData.fromJson(Map<String, dynamic> json) {
    return ClipboardData(
      paths: List<String>.from(json['paths']),
      isCut: json['isCut'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}

class ClipboardService {
  static const String _clipboardKey = 'workspace_clipboard';
  static const Duration _maxAge = Duration(hours: 24);
  
  late SharedPreferences _prefs;

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    await _cleanupExpiredClipboard();
  }

  Future<void> copy(List<String> paths) async {
    try {
      final clipboardData = ClipboardData(
        paths: paths,
        isCut: false,
        timestamp: DateTime.now(),
      );
      
      await _saveClipboardData(clipboardData);
    } catch (e) {
      throw Exception('Failed to copy to clipboard: $e');
    }
  }

  Future<void> cut(List<String> paths) async {
    try {
      final clipboardData = ClipboardData(
        paths: paths,
        isCut: true,
        timestamp: DateTime.now(),
      );
      
      await _saveClipboardData(clipboardData);
    } catch (e) {
      throw Exception('Failed to cut to clipboard: $e');
    }
  }

  Future<ClipboardData?> getClipboardData() async {
    try {
      final clipboardJson = _prefs.getString(_clipboardKey);
      if (clipboardJson == null) return null;
      
      final data = ClipboardData.fromJson(jsonDecode(clipboardJson));
      
      // Check if clipboard data is expired
      if (DateTime.now().difference(data.timestamp) > _maxAge) {
        await clear();
        return null;
      }
      
      return data;
    } catch (e) {
      await clear();
      return null;
    }
  }

  Future<bool> hasClipboardData() async {
    final data = await getClipboardData();
    return data != null && data.paths.isNotEmpty;
  }

  Future<bool> isCutOperation() async {
    final data = await getClipboardData();
    return data?.isCut ?? false;
  }

  Future<List<String>> getPaths() async {
    final data = await getClipboardData();
    return data?.paths ?? [];
  }

  Future<void> clear() async {
    try {
      await _prefs.remove(_clipboardKey);
    } catch (e) {
      throw Exception('Failed to clear clipboard: $e');
    }
  }

  Future<void> _saveClipboardData(ClipboardData data) async {
    final clipboardJson = jsonEncode(data.toJson());
    await _prefs.setString(_clipboardKey, clipboardJson);
  }

  Future<void> _cleanupExpiredClipboard() async {
    try {
      final data = await getClipboardData();
      if (data != null && DateTime.now().difference(data.timestamp) > _maxAge) {
        await clear();
      }
    } catch (e) {
      await clear();
    }
  }

  // Validation methods
  Future<bool> validatePaths() async {
    try {
      final data = await getClipboardData();
      if (data == null) return false;
      
      for (final path in data.paths) {
        // Basic path validation
        if (path.isEmpty || path.contains('..')) {
          return false;
        }
      }
      
      return true;
    } catch (e) {
      return false;
    }
  }

  // Statistics
  Future<Map<String, dynamic>> getClipboardStats() async {
    try {
      final data = await getClipboardData();
      if (data == null) {
        return {
          'hasData': false,
          'pathCount': 0,
          'isCut': false,
          'age': null,
        };
      }
      
      return {
        'hasData': true,
        'pathCount': data.paths.length,
        'isCut': data.isCut,
        'age': DateTime.now().difference(data.timestamp).inMinutes,
        'timestamp': data.timestamp.toIso8601String(),
      };
    } catch (e) {
      return {
        'hasData': false,
        'pathCount': 0,
        'isCut': false,
        'age': null,
        'error': e.toString(),
      };
    }
  }
}
