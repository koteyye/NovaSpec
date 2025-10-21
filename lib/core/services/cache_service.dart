import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../utils/helpers.dart';

/// Cache entry with expiration support
class CacheEntry<T> {
  final T data;
  final DateTime createdAt;
  final Duration? ttl;

  CacheEntry({
    required this.data,
    required this.createdAt,
    this.ttl,
  });

  bool get isExpired {
    if (ttl == null) return false;
    return DateTime.now().difference(createdAt) > ttl!;
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data,
      'createdAt': createdAt.toIso8601String(),
      'ttl': ttl?.inMilliseconds,
    };
  }

  factory CacheEntry.fromJson(Map<String, dynamic> json, T Function(dynamic) fromJson) {
    return CacheEntry<T>(
      data: fromJson(json['data']),
      createdAt: DateTime.parse(json['createdAt']),
      ttl: json['ttl'] != null ? Duration(milliseconds: json['ttl']) : null,
    );
  }
}

/// Cache service for performance optimization
class CacheService {
  static CacheService? _instance;
  static CacheService get instance => _instance ??= CacheService._();
  
  CacheService._();

  final Map<String, CacheEntry> _memoryCache = {};
  final Duration _defaultTTL = const Duration(hours: 1);
  final int _maxMemoryCacheSize = 100;
  Directory? _cacheDir;

  /// Initialize cache service
  Future<void> initialize() async {
    try {
      _cacheDir = await getTemporaryDirectory();
      AppLogger.info('CacheService initialized with directory: ${_cacheDir!.path}');
    } catch (e) {
      AppLogger.logError('Failed to initialize CacheService: $e');
    }
  }



  /// Clean expired entries from memory cache
  void _cleanExpiredEntries() {
    final expiredKeys = _memoryCache.entries
        .where((entry) => entry.value.isExpired)
        .map((entry) => entry.key)
        .toList();

    for (final key in expiredKeys) {
      _memoryCache.remove(key);
    }

    // Remove oldest entries if cache is too large
    if (_memoryCache.length > _maxMemoryCacheSize) {
      final entries = _memoryCache.entries.toList()
        ..sort((a, b) => a.value.createdAt.compareTo(b.value.createdAt));
      
      final toRemove = entries.length - _maxMemoryCacheSize;
      for (int i = 0; i < toRemove; i++) {
        _memoryCache.remove(entries[i].key);
      }
    }
  }

  /// Store data in memory cache
  void setMemory<T>(String key, T data, {Duration? ttl}) {
    _cleanExpiredEntries();
    
    _memoryCache[key] = CacheEntry<T>(
      data: data,
      createdAt: DateTime.now(),
      ttl: ttl ?? _defaultTTL,
    );
    
    AppLogger.debug('Cached data in memory with key: $key');
  }

  /// Retrieve data from memory cache
  T? getMemory<T>(String key) {
    final entry = _memoryCache[key];
    if (entry == null) return null;
    
    if (entry.isExpired) {
      _memoryCache.remove(key);
      AppLogger.debug('Expired cache entry removed: $key');
      return null;
    }
    
    AppLogger.debug('Retrieved data from memory cache: $key');
    return entry.data as T?;
  }

  /// Store data in file cache
  Future<void> setFile<T>(
    String key, 
    T data, 
    T Function(dynamic) toJson, {
    Duration? ttl,
  }) async {
    if (_cacheDir == null) {
      AppLogger.logError('Cache directory not initialized');
      return;
    }

    try {
      final entry = CacheEntry<T>(
        data: data,
        createdAt: DateTime.now(),
        ttl: ttl ?? _defaultTTL,
      );

      final file = File('${_cacheDir!.path}/$key.json');
      await file.writeAsString(jsonEncode(entry.toJson()));
      
      AppLogger.debug('Cached data to file: $key');
    } catch (e) {
      AppLogger.logError('Failed to cache data to file: $e');
    }
  }

  /// Retrieve data from file cache
  Future<T?> getFile<T>(
    String key, 
    T Function(dynamic) fromJson,
  ) async {
    if (_cacheDir == null) {
      AppLogger.logError('Cache directory not initialized');
      return null;
    }

    try {
      final file = File('${_cacheDir!.path}/$key.json');
      if (!await file.exists()) {
        return null;
      }

      final content = await file.readAsString();
      final json = jsonDecode(content) as Map<String, dynamic>;
      final entry = CacheEntry.fromJson(json, fromJson);

      if (entry.isExpired) {
        await file.delete();
        AppLogger.debug('Expired file cache entry removed: $key');
        return null;
      }

      AppLogger.debug('Retrieved data from file cache: $key');
      return entry.data as T?;
    } catch (e) {
      AppLogger.logError('Failed to retrieve data from file cache: $e');
      return null;
    }
  }

  /// Get data with fallback strategy (memory -> file -> null)
  Future<T?> get<T>(
    String key,
    T Function(dynamic) fromJson,
  ) async {
    // Try memory cache first
    final memoryData = getMemory<T>(key);
    if (memoryData != null) return memoryData;

    // Try file cache
    final fileData = await getFile<T>(key, fromJson);
    if (fileData != null) {
      // Store in memory for faster access next time
      setMemory(key, fileData);
      return fileData;
    }

    return null;
  }

  /// Set data with both memory and file storage
  Future<void> set<T>(
    String key,
    T data,
    T Function(dynamic) toJson, {
    Duration? ttl,
  }) async {
    setMemory(key, data, ttl: ttl);
    await setFile(key, data, toJson, ttl: ttl);
  }

  /// Remove specific cache entry
  Future<void> remove(String key) async {
    _memoryCache.remove(key);
    
    if (_cacheDir != null) {
      try {
        final file = File('${_cacheDir!.path}/$key.json');
        if (await file.exists()) {
          await file.delete();
        }
      } catch (e) {
        AppLogger.logError('Failed to remove cache file: $e');
      }
    }
    
    AppLogger.debug('Removed cache entry: $key');
  }

  /// Clear all cache
  Future<void> clear() async {
    _memoryCache.clear();
    
    if (_cacheDir != null) {
      try {
        final files = await _cacheDir!.list().toList();
        for (final file in files) {
          if (file is File && file.path.endsWith('.json')) {
            await file.delete();
          }
        }
      } catch (e) {
        AppLogger.logError('Failed to clear cache files: $e');
      }
    }
    
    AppLogger.info('Cache cleared');
  }

  /// Get cache statistics
  Map<String, dynamic> getStats() {
    return {
      'memoryCacheSize': _memoryCache.length,
      'maxMemoryCacheSize': _maxMemoryCacheSize,
      'cacheDirectory': _cacheDir?.path,
    };
  }

  /// Preload commonly used data
  Future<void> preloadCommonData() async {
    AppLogger.info('Preloading common cache data...');
    
    // Preload app configuration if available
    try {
      // This would be implemented based on actual app needs
      AppLogger.debug('Common data preloaded');
    } catch (e) {
      AppLogger.logError('Failed to preload common data: $e');
    }
  }
}