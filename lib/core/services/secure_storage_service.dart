import 'dart:async';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../shared/models/storage_result.dart';
import '../../shared/models/app_error.dart';

abstract class SecureStorageService {
  Future<void> initialize();
  
  Future<StorageResult<String?>> get(String key);
  
  Future<StorageResult<bool>> set(String key, String value);
  
  Future<StorageResult<bool>> remove(String key);
  
  Future<StorageResult<bool>> clear();
  
  Future<StorageResult<bool>> containsKey(String key);
  
  Future<StorageResult<Map<String, String>>> getAll();
}

class SecureStorageServiceImpl implements SecureStorageService {
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  
  @override
  Future<void> initialize() async {
    // FlutterSecureStorage doesn't require explicit initialization
  }
  
  @override
  Future<StorageResult<String?>> get(String key) async {
    try {
      final value = await _secureStorage.read(key: key);
      return StorageResult.success(value);
    } catch (e) {
      return StorageResult.failure(
        AppError(
          type: ErrorType.storage,
          severity: ErrorSeverity.high,
          code: 'SECURE_GET_ERROR',
          message: 'Failed to get secure value for key: $key',
          details: e.toString(),
          timestamp: DateTime.now(),
        ),
      );
    }
  }
  
  @override
  Future<StorageResult<bool>> set(String key, String value) async {
    try {
      await _secureStorage.write(key: key, value: value);
      return StorageResult.success(true);
    } catch (e) {
      return StorageResult.failure(
        AppError(
          type: ErrorType.storage,
          severity: ErrorSeverity.high,
          code: 'SECURE_SET_ERROR',
          message: 'Failed to set secure value for key: $key',
          details: e.toString(),
          timestamp: DateTime.now(),
        ),
      );
    }
  }
  
  @override
  Future<StorageResult<bool>> remove(String key) async {
    try {
      await _secureStorage.delete(key: key);
      return StorageResult.success(true);
    } catch (e) {
      return StorageResult.failure(
        AppError(
          type: ErrorType.storage,
          severity: ErrorSeverity.high,
          code: 'SECURE_REMOVE_ERROR',
          message: 'Failed to remove secure key: $key',
          details: e.toString(),
          timestamp: DateTime.now(),
        ),
      );
    }
  }
  
  @override
  Future<StorageResult<bool>> clear() async {
    try {
      await _secureStorage.deleteAll();
      return StorageResult.success(true);
    } catch (e) {
      return StorageResult.failure(
        AppError(
          type: ErrorType.storage,
          severity: ErrorSeverity.high,
          code: 'SECURE_CLEAR_ERROR',
          message: 'Failed to clear secure storage',
          details: e.toString(),
          timestamp: DateTime.now(),
        ),
      );
    }
  }
  
  @override
  Future<StorageResult<bool>> containsKey(String key) async {
    try {
      final contains = await _secureStorage.containsKey(key: key);
      return StorageResult.success(contains);
    } catch (e) {
      return StorageResult.failure(
        AppError(
          type: ErrorType.storage,
          severity: ErrorSeverity.medium,
          code: 'SECURE_CONTAINS_KEY_ERROR',
          message: 'Failed to check if secure key exists: $key',
          details: e.toString(),
          timestamp: DateTime.now(),
        ),
      );
    }
  }
  
  @override
  Future<StorageResult<Map<String, String>>> getAll() async {
    try {
      final allData = await _secureStorage.readAll();
      return StorageResult.success(allData);
    } catch (e) {
      return StorageResult.failure(
        AppError(
          type: ErrorType.storage,
          severity: ErrorSeverity.medium,
          code: 'SECURE_GET_ALL_ERROR',
          message: 'Failed to get all secure data',
          details: e.toString(),
          timestamp: DateTime.now(),
        ),
      );
    }
  }
}
