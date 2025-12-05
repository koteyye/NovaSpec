import 'dart:io' show Platform;

/// Типы платформ
enum PlatformType { windows, macos, linux, unknown }

/// Детектор платформы с поддержкой WebView2
class PlatformDetector {
  static PlatformType _currentPlatform = PlatformType.unknown;
  
  /// Возвращает текущую платформу
  static PlatformType getCurrentPlatform() {
    if (_currentPlatform != PlatformType.unknown) {
      return _currentPlatform;
    }
    
    if (Platform.isWindows) {
      _currentPlatform = PlatformType.windows;
    } else if (Platform.isMacOS) {
      _currentPlatform = PlatformType.macos;
    } else if (Platform.isLinux) {
      _currentPlatform = PlatformType.linux;
    } else {
      _currentPlatform = PlatformType.unknown;
    }
    
    return _currentPlatform;
  }
  
  /// Проверяет является ли текущая платформа Windows
  static bool isWindows() {
    return getCurrentPlatform() == PlatformType.windows;
  }
  
  /// Проверяет является ли текущая платформа macOS
  static bool isMacOS() {
    return getCurrentPlatform() == PlatformType.macos;
  }
  
  /// Проверяет является ли текущая платформа Linux
  static bool isLinux() {
    return getCurrentPlatform() == PlatformType.linux;
  }
  
  /// Проверяет поддерживается ли WebView2 на текущей платформе
  static bool supportsWebView2() {
    return isWindows();
  }
  
  /// Проверяет поддерживается ли стандартный WebView на текущей платформе
  static bool supportsWebView() {
    return isWindows() || isMacOS() || isLinux();
  }
  
  /// Возвращает имя платформы для логирования
  static String getPlatformName() {
    switch (getCurrentPlatform()) {
      case PlatformType.windows:
        return 'Windows';
      case PlatformType.macos:
        return 'macOS';
      case PlatformType.linux:
        return 'Linux';
      case PlatformType.unknown:
        return 'Unknown';
    }
  }
  
  /// Возвращает информацию о системе
  static Map<String, dynamic> getSystemInfo() {
    return {
      'platform': getPlatformName(),
      'isWindows': isWindows(),
      'isMacOS': isMacOS(),
      'isLinux': isLinux(),
      'supportsWebView2': supportsWebView2(),
      'supportsWebView': supportsWebView(),
      'operatingSystem': Platform.operatingSystem,
      'operatingSystemVersion': Platform.operatingSystemVersion,
      'localHostname': Platform.localHostname,
      'numberOfProcessors': Platform.numberOfProcessors,
      'pathSeparator': Platform.pathSeparator,
    };
  }
  
  /// Сбрасывает кэш платформы (для тестов)
  static void resetCache() {
    _currentPlatform = PlatformType.unknown;
  }
}