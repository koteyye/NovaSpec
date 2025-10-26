/// Статусы подключения к сервисам
enum ConnectionStatus {
  /// Не подключено
  disconnected,
  /// Подключается
  connecting,
  /// Подключено успешно
  connected,
  /// Ошибка подключения
  error,
  /// Неавторизован
  unauthorized,
  /// Таймаут
  timeout,
}

/// Расширенная информация о статусе подключения
class ConnectionStatusInfo {
  final ConnectionStatus status;
  final String message;
  final String? details;
  final DateTime timestamp;
  final int? statusCode;
  
  ConnectionStatusInfo({
    required this.status,
    required this.message,
    this.details,
    DateTime? timestamp,
    this.statusCode,
  }) : timestamp = timestamp ?? DateTime.now();
  
  factory ConnectionStatusInfo.disconnected(String message, {String? details}) {
    return ConnectionStatusInfo(
      status: ConnectionStatus.disconnected,
      message: message,
      details: details,
    );
  }
  
  factory ConnectionStatusInfo.connecting(String message) {
    return ConnectionStatusInfo(
      status: ConnectionStatus.connecting,
      message: message,
    );
  }
  
  factory ConnectionStatusInfo.connected(String message, {String? details}) {
    return ConnectionStatusInfo(
      status: ConnectionStatus.connected,
      message: message,
      details: details,
    );
  }
  
  factory ConnectionStatusInfo.error(String message, {String? details, int? statusCode}) {
    return ConnectionStatusInfo(
      status: ConnectionStatus.error,
      message: message,
      details: details,
      statusCode: statusCode,
    );
  }
  
  factory ConnectionStatusInfo.unauthorized(String message, {String? details}) {
    return ConnectionStatusInfo(
      status: ConnectionStatus.unauthorized,
      message: message,
      details: details,
    );
  }
  
  factory ConnectionStatusInfo.timeout(String message) {
    return ConnectionStatusInfo(
      status: ConnectionStatus.timeout,
      message: message,
    );
  }
  
  bool get isConnected => status == ConnectionStatus.connected;
  bool get isError => status == ConnectionStatus.error || status == ConnectionStatus.unauthorized;
  bool get isPending => status == ConnectionStatus.connecting;
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ConnectionStatusInfo &&
        other.status == status &&
        other.message == message &&
        other.details == details &&
        other.statusCode == statusCode;
  }
  
  @override
  int get hashCode => Object.hash(status, message, details, statusCode);
  
  @override
  String toString() {
    return 'ConnectionStatusInfo(status: $status, message: $message, details: $details, statusCode: $statusCode)';
  }
}