import 'dart:io';
import 'package:webview_windows/webview_windows.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/webview/webview2_status.dart';
import '../../../core/utils/app_logger.dart';

/// Сервис для проверки наличия и версии WebView2 на Windows
class WebView2CheckerService {
  static const String _cacheKey = 'webview2_status';
  static const String _lastCheckKey = 'webview2_last_check';
  static const Duration _cacheTimeout = Duration(hours: 24);

  /// Проверяет наличие и версию WebView2 на системе
  Future<WebView2Status> checkAvailability() async {
    try {
      // Проверяем кэш
      final cachedStatus = await _getCachedStatus();
      if (cachedStatus != null) {
        AppLogger.info(
          'WebView2 status from cache: ${cachedStatus.availability}',
        );
        return cachedStatus;
      }

      AppLogger.info('Checking WebView2 availability...');

      if (!Platform.isWindows) {
        final status = WebView2Status.notInstalled();
        await _cacheStatus(status);
        return status;
      }

      // Проверяем через webview_windows
      try {
        final version = await WebviewController.getWebViewVersion();
        if (version != null) {
          AppLogger.info('WebView2 found via webview_windows: $version');

          if (_isVersionCompatible(version)) {
            final status = WebView2Status.available(version);
            await _cacheStatus(status);
            return status;
          } else {
            AppLogger.warning('WebView2 version too old: $version');
            final status = WebView2Status.versionTooOld(version);
            await _cacheStatus(status);
            return status;
          }
        }
      } catch (e) {
        AppLogger.warning('Failed to check WebView2 via webview_windows: $e');
      }

      // Fallback проверка через реестр
      AppLogger.info(
        'WebView2 not found via webview_windows, checking registry...',
      );
      final registryStatus = await _checkRegistry();
      await _cacheStatus(registryStatus);
      return registryStatus;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Error checking WebView2 availability',
        error: e,
        stackTrace: stackTrace,
      );
      final status = WebView2Status.error(e.toString());
      await _cacheStatus(status);
      return status;
    }
  }

  /// Проверяет совместимость версии WebView2
  bool _isVersionCompatible(String version) {
    try {
      final parts = version.split('.');
      if (parts.length < 2) return false;

      final major = int.tryParse(parts[0]) ?? 0;
      return major >= 90; // WebView2 версии 90+ поддерживается
    } catch (e) {
      return false;
    }
  }

  /// Получает детальную информацию о WebView2
  Future<WebView2Info?> getWebView2Info() async {
    try {
      final status = await checkAvailability();
      if (!status.isAvailable) return null;

      return WebView2Info(
        version: status.version!,
        availability: status.availability,
        installPath: await _getInstallPath(),
        lastChecked: status.checkedAt,
      );
    } catch (e) {
      AppLogger.error('Error getting WebView2 info', error: e);
      return null;
    }
  }

  /// Очищает кэш статуса WebView2
  Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_cacheKey);
      await prefs.remove(_lastCheckKey);
      AppLogger.info('WebView2 status cache cleared');
    } catch (e) {
      AppLogger.error('Error clearing WebView2 cache', error: e);
    }
  }

  /// Получает кэшированный статус
  Future<WebView2Status?> _getCachedStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastCheckTime = prefs.getInt(_lastCheckKey);

      if (lastCheckTime != null) {
        final lastCheck = DateTime.fromMillisecondsSinceEpoch(lastCheckTime);
        final now = DateTime.now();

        if (now.difference(lastCheck) < _cacheTimeout) {
          final statusMap = prefs.getString(_cacheKey);
          if (statusMap != null) {
            // В реальной реализации здесь будет десериализация JSON
            // Для упрощения возвращаем null
          }
        }
      }

      return null;
    } catch (e) {
      AppLogger.error('Error getting cached WebView2 status', error: e);
      return null;
    }
  }

  /// Сохраняет статус в кэш
  Future<void> _cacheStatus(WebView2Status status) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(
        _lastCheckKey,
        status.checkedAt.millisecondsSinceEpoch,
      );
      // В реальной реализации здесь будет сериализация JSON
      // await prefs.setString(_cacheKey, jsonEncode(status.toMap()));
      AppLogger.info('WebView2 status cached: ${status.availability}');
    } catch (e) {
      AppLogger.error('Error caching WebView2 status', error: e);
    }
  }

  /// Проверяет наличие WebView2 через реестр Windows
  Future<WebView2Status> _checkRegistry() async {
    try {
      if (!Platform.isWindows) {
        return WebView2Status.notInstalled();
      }

      // Проверяем реестр на наличие WebView2
      // Упрощенная проверка - в реальной реализации нужно использовать win32 правильно
      // Для демонстрации просто возвращаем notInstalled
      AppLogger.info('Registry check not implemented, returning notInstalled');

      return WebView2Status.notInstalled();
    } catch (e) {
      AppLogger.error('Error checking WebView2 registry', error: e);
      return WebView2Status.error('Registry check failed: $e');
    }
  }

  /// Получает путь установки WebView2
  Future<String?> _getInstallPath() async {
    try {
      // В реальной реализации здесь будет чтение пути из реестра
      return null;
    } catch (e) {
      AppLogger.error('Error getting WebView2 install path', error: e);
      return null;
    }
  }
}

/// Детальная информация о WebView2
class WebView2Info {
  final String version;
  final WebView2Availability availability;
  final String? installPath;
  final DateTime lastChecked;

  WebView2Info({
    required this.version,
    required this.availability,
    this.installPath,
    required this.lastChecked,
  });

  @override
  String toString() {
    return 'WebView2Info(version: $version, availability: $availability, installPath: $installPath)';
  }
}
