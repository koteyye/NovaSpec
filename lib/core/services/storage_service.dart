import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import '../../shared/models/storage_result.dart';
import '../../shared/models/app_error.dart';

abstract class StorageService {
  Future<void> initialize();
  
  Future<StorageResult<T>> get<T>(String key);
  
  Future<StorageResult<bool>> set<T>(String key, T value);
  
  Future<StorageResult<bool>> remove(String key);
  
  Future<StorageResult<bool>> clear();
  
  Future<StorageResult<bool>> containsKey(String key);
  
  Future<StorageResult<List<String>>> getKeys();
}

class StorageServiceImpl implements StorageService {
  late SharedPreferences _prefs;
  
  @override
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }
  
  @override
  Future<StorageResult<T>> get<T>(String key) async {
    try {
      if (!_prefs.containsKey(key)) {
        return StorageResult.failure(
          AppError(
            type: ErrorType.storage,
            severity: ErrorSeverity.low,
            code: 'KEY_NOT_FOUND',
            message: 'Key not found: $key',
            timestamp: DateTime.now(),
          ),
        );
      }
      
      dynamic value;
      final typeString = T.toString();
      if (typeString == 'String') {
        value = _prefs.getString(key);
      } else if (typeString == 'int') {
        value = _prefs.getInt(key);
      } else if (typeString == 'double') {
        value = _prefs.getDouble(key);
      } else if (typeString == 'bool') {
        value = _prefs.getBool(key);
      } else if (typeString == 'List<String>') {
        value = _prefs.getStringList(key);
      } else {
        return StorageResult.failure(
          AppError(
            type: ErrorType.validation,
            severity: ErrorSeverity.medium,
            code: 'UNSUPPORTED_TYPE',
            message: 'Unsupported type: $T',
            timestamp: DateTime.now(),
          ),
        );
      }
      
      return StorageResult.success(value as T);
    } catch (e) {
      return StorageResult.failure(
        AppError(
          type: ErrorType.storage,
          severity: ErrorSeverity.high,
          code: 'GET_ERROR',
          message: 'Failed to get value for key: $key',
          details: e.toString(),
          timestamp: DateTime.now(),
        ),
      );
    }
  }
  
  @override
  Future<StorageResult<bool>> set<T>(String key, T value) async {
    try {
      bool success;
      final typeString = T.toString();
      if (typeString == 'String') {
        success = await _prefs.setString(key, value as String);
      } else if (typeString == 'int') {
        success = await _prefs.setInt(key, value as int);
      } else if (typeString == 'double') {
        success = await _prefs.setDouble(key, value as double);
      } else if (typeString == 'bool') {
        success = await _prefs.setBool(key, value as bool);
      } else if (typeString == 'List<String>') {
        success = await _prefs.setStringList(key, value as List<String>);
      } else {
        return StorageResult.failure(
          AppError(
            type: ErrorType.validation,
            severity: ErrorSeverity.medium,
            code: 'UNSUPPORTED_TYPE',
            message: 'Unsupported type: $T',
            timestamp: DateTime.now(),
          ),
        );
      }
      
      return StorageResult.success(success);
    } catch (e) {
      return StorageResult.failure(
        AppError(
          type: ErrorType.storage,
          severity: ErrorSeverity.high,
          code: 'SET_ERROR',
          message: 'Failed to set value for key: $key',
          details: e.toString(),
          timestamp: DateTime.now(),
        ),
      );
    }
  }
  
  @override
  Future<StorageResult<bool>> remove(String key) async {
    try {
      final success = await _prefs.remove(key);
      return StorageResult.success(success);
    } catch (e) {
      return StorageResult.failure(
        AppError(
          type: ErrorType.storage,
          severity: ErrorSeverity.high,
          code: 'REMOVE_ERROR',
          message: 'Failed to remove key: $key',
          details: e.toString(),
          timestamp: DateTime.now(),
        ),
      );
    }
  }
  
  @override
  Future<StorageResult<bool>> clear() async {
    try {
      final success = await _prefs.clear();
      return StorageResult.success(success);
    } catch (e) {
      return StorageResult.failure(
        AppError(
          type: ErrorType.storage,
          severity: ErrorSeverity.high,
          code: 'CLEAR_ERROR',
          message: 'Failed to clear storage',
          details: e.toString(),
          timestamp: DateTime.now(),
        ),
      );
    }
  }
  
  @override
  Future<StorageResult<bool>> containsKey(String key) async {
    try {
      final contains = _prefs.containsKey(key);
      return StorageResult.success(contains);
    } catch (e) {
      return StorageResult.failure(
        AppError(
          type: ErrorType.storage,
          severity: ErrorSeverity.medium,
          code: 'CONTAINS_KEY_ERROR',
          message: 'Failed to check if key exists: $key',
          details: e.toString(),
          timestamp: DateTime.now(),
        ),
      );
    }
  }
  
  @override
  Future<StorageResult<List<String>>> getKeys() async {
    try {
      final keys = _prefs.getKeys().toList();
      return StorageResult.success(keys);
    } catch (e) {
      return StorageResult.failure(
        AppError(
          type: ErrorType.storage,
          severity: ErrorSeverity.medium,
          code: 'GET_KEYS_ERROR',
          message: 'Failed to get all keys',
          details: e.toString(),
          timestamp: DateTime.now(),
        ),
      );
    }
  }
}
