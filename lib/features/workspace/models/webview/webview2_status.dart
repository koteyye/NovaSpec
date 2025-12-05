/// Результат проверки наличия WebView2 на системе
enum WebView2Availability {
  available,
  notInstalled,
  versionTooOld,
  unknown
}

/// Статус WebView2 с детальной информацией
class WebView2Status {
  final WebView2Availability availability;
  final String? version;
  final String? errorMessage;
  final DateTime checkedAt;
  
  const WebView2Status({
    required this.availability,
    this.version,
    this.errorMessage,
    required this.checkedAt,
  });
  
  /// Создает статус доступности WebView2
  factory WebView2Status.available(String version) {
    return WebView2Status(
      availability: WebView2Availability.available,
      version: version,
      checkedAt: DateTime.now(),
    );
  }
  
  /// Создает статус отсутствия WebView2
  factory WebView2Status.notInstalled() {
    return WebView2Status(
      availability: WebView2Availability.notInstalled,
      checkedAt: DateTime.now(),
    );
  }
  
  /// Создает статус старой версии WebView2
  factory WebView2Status.versionTooOld(String version) {
    return WebView2Status(
      availability: WebView2Availability.versionTooOld,
      version: version,
      checkedAt: DateTime.now(),
    );
  }
  
  /// Создает статус ошибки
  factory WebView2Status.error(String errorMessage) {
    return WebView2Status(
      availability: WebView2Availability.unknown,
      errorMessage: errorMessage,
      checkedAt: DateTime.now(),
    );
  }
  
  /// Проверяет доступен ли WebView2
  bool get isAvailable => availability == WebView2Availability.available;
  
  /// Проверяет нужно ли показывать заглушку
  bool get needsFallback => availability != WebView2Availability.available;
  
  /// Возвращает пользовательское сообщение
  String get userMessage {
    switch (availability) {
      case WebView2Availability.available:
        return 'WebView2 доступен';
      case WebView2Availability.notInstalled:
        return 'WebView2 не установлен. Пожалуйста, установите Microsoft Edge WebView2.';
      case WebView2Availability.versionTooOld:
        return 'Версия WebView2 слишком старая. Пожалуйста, обновите Microsoft Edge WebView2.';
      case WebView2Availability.unknown:
        return 'Не удалось определить статус WebView2: $errorMessage';
    }
  }
  
  /// Преобразует в Map для сохранения в SharedPreferences
  Map<String, dynamic> toMap() {
    return {
      'availability': availability.name,
      'version': version,
      'errorMessage': errorMessage,
      'checkedAt': checkedAt.millisecondsSinceEpoch,
    };
  }
  
  /// Создает статус из Map из SharedPreferences
  factory WebView2Status.fromMap(Map<String, dynamic> map) {
    final availabilityName = map['availability'] as String?;
    final availability = WebView2Availability.values.firstWhere(
      (e) => e.name == availabilityName,
      orElse: () => WebView2Availability.unknown,
    );
    
    return WebView2Status(
      availability: availability,
      version: map['version'] as String?,
      errorMessage: map['errorMessage'] as String?,
      checkedAt: DateTime.fromMillisecondsSinceEpoch(
        map['checkedAt'] as int? ?? DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }
  
  /// Проверяет актуальность статуса (не старше 24 часов)
  bool isFresh() {
    final now = DateTime.now();
    final difference = now.difference(checkedAt);
    return difference.inHours < 24;
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WebView2Status &&
           other.availability == availability &&
           other.version == version &&
           other.errorMessage == errorMessage;
  }
  
  @override
  int get hashCode {
    return availability.hashCode ^
           version.hashCode ^
           errorMessage.hashCode ^
           checkedAt.hashCode;
  }
  
  @override
  String toString() {
    return 'WebView2Status(availability: $availability, version: $version, checkedAt: $checkedAt)';
  }
}