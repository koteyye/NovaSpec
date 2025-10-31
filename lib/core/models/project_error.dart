/// Категории ошибок проекта
enum ProjectErrorCategory {
  accessibility,    // Ошибки доступности
  permission,       // Ошибки прав доступа
  network,          // Сетевые ошибки
  validation,       // Ошибки валидации
  synchronization,  // Ошибки синхронизации
  fileSystem,       // Ошибки файловой системы
  configuration,    // Ошибки конфигурации
  unknown           // Неизвестные ошибки
}

/// Уровень критичности ошибки
enum ProjectErrorSeverity {
  low,      // Низкая - информационное сообщение
  medium,   // Средняя - предупреждение
  high,     // Высокая - ошибка
  critical  // Критическая - блокирующая ошибка
}

/// Класс для представления ошибок проекта
class ProjectError {
  final String id;                    // Уникальный ID ошибки
  final String projectId;             // ID проекта
  final ProjectErrorCategory category; // Категория ошибки
  final ProjectErrorSeverity severity; // Уровень критичности
  final String message;               // Сообщение об ошибке
  final String? details;              // Детальная информация
  final String? stackTrace;           // Stack trace (для отладки)
  final DateTime timestamp;           // Время возникновения
  final String? context;              // Контекст ошибки
  final Map<String, dynamic>? metadata; // Дополнительные метаданные

  const ProjectError({
    required this.id,
    required this.projectId,
    required this.category,
    required this.severity,
    required this.message,
    this.details,
    this.stackTrace,
    required this.timestamp,
    this.context,
    this.metadata,
  });

  /// Создать ошибку доступности
  factory ProjectError.accessibility({
    required String projectId,
    required String message,
    String? details,
    String? context,
  }) {
    return ProjectError(
      id: _generateId(),
      projectId: projectId,
      category: ProjectErrorCategory.accessibility,
      severity: ProjectErrorSeverity.high,
      message: message,
      details: details,
      timestamp: DateTime.now(),
      context: context,
    );
  }

  /// Создать ошибку прав доступа
  factory ProjectError.permission({
    required String projectId,
    required String message,
    String? details,
    String? context,
  }) {
    return ProjectError(
      id: _generateId(),
      projectId: projectId,
      category: ProjectErrorCategory.permission,
      severity: ProjectErrorSeverity.high,
      message: message,
      details: details,
      timestamp: DateTime.now(),
      context: context,
    );
  }

  /// Создать сетевую ошибку
  factory ProjectError.network({
    required String projectId,
    required String message,
    String? details,
    String? context,
  }) {
    return ProjectError(
      id: _generateId(),
      projectId: projectId,
      category: ProjectErrorCategory.network,
      severity: ProjectErrorSeverity.medium,
      message: message,
      details: details,
      timestamp: DateTime.now(),
      context: context,
    );
  }

  /// Создать ошибку валидации
  factory ProjectError.validation({
    required String projectId,
    required String message,
    String? details,
    String? context,
  }) {
    return ProjectError(
      id: _generateId(),
      projectId: projectId,
      category: ProjectErrorCategory.validation,
      severity: ProjectErrorSeverity.medium,
      message: message,
      details: details,
      timestamp: DateTime.now(),
      context: context,
    );
  }

  /// Создать ошибку синхронизации
  factory ProjectError.synchronization({
    required String projectId,
    required String message,
    String? details,
    String? context,
  }) {
    return ProjectError(
      id: _generateId(),
      projectId: projectId,
      category: ProjectErrorCategory.synchronization,
      severity: ProjectErrorSeverity.medium,
      message: message,
      details: details,
      timestamp: DateTime.now(),
      context: context,
    );
  }

  /// Создать ошибку файловой системы
  factory ProjectError.fileSystem({
    required String projectId,
    required String message,
    String? details,
    String? stackTrace,
    String? context,
  }) {
    return ProjectError(
      id: _generateId(),
      projectId: projectId,
      category: ProjectErrorCategory.fileSystem,
      severity: ProjectErrorSeverity.high,
      message: message,
      details: details,
      stackTrace: stackTrace,
      timestamp: DateTime.now(),
      context: context,
    );
  }

  /// Создать ошибку конфигурации
  factory ProjectError.configuration({
    required String projectId,
    required String message,
    String? details,
    String? context,
  }) {
    return ProjectError(
      id: _generateId(),
      projectId: projectId,
      category: ProjectErrorCategory.configuration,
      severity: ProjectErrorSeverity.medium,
      message: message,
      details: details,
      timestamp: DateTime.now(),
      context: context,
    );
  }

  /// Создать неизвестную ошибку
  factory ProjectError.unknown({
    required String projectId,
    required String message,
    String? details,
    String? stackTrace,
    String? context,
  }) {
    return ProjectError(
      id: _generateId(),
      projectId: projectId,
      category: ProjectErrorCategory.unknown,
      severity: ProjectErrorSeverity.medium,
      message: message,
      details: details,
      stackTrace: stackTrace,
      timestamp: DateTime.now(),
      context: context,
    );
  }

  /// Создать копию с обновленными полями
  ProjectError copyWith({
    String? id,
    String? projectId,
    ProjectErrorCategory? category,
    ProjectErrorSeverity? severity,
    String? message,
    String? details,
    String? stackTrace,
    DateTime? timestamp,
    String? context,
    Map<String, dynamic>? metadata,
  }) {
    return ProjectError(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      category: category ?? this.category,
      severity: severity ?? this.severity,
      message: message ?? this.message,
      details: details ?? this.details,
      stackTrace: stackTrace ?? this.stackTrace,
      timestamp: timestamp ?? this.timestamp,
      context: context ?? this.context,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Преобразовать в Map для сериализации
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'project_id': projectId,
      'category': category.name,
      'severity': severity.name,
      'message': message,
      'details': details,
      'stack_trace': stackTrace,
      'timestamp': timestamp.toIso8601String(),
      'context': context,
      'metadata': metadata,
    };
  }

  /// Создать из Map
  factory ProjectError.fromMap(Map<String, dynamic> map) {
    return ProjectError(
      id: map['id'],
      projectId: map['project_id'],
      category: ProjectErrorCategory.values.firstWhere(
        (e) => e.name == map['category'],
        orElse: () => ProjectErrorCategory.unknown,
      ),
      severity: ProjectErrorSeverity.values.firstWhere(
        (e) => e.name == map['severity'],
        orElse: () => ProjectErrorSeverity.medium,
      ),
      message: map['message'],
      details: map['details'],
      stackTrace: map['stack_trace'],
      timestamp: DateTime.parse(map['timestamp']),
      context: map['context'],
      metadata: map['metadata'],
    );
  }

  /// Проверить, является ли ошибка критической
  bool get isCritical => severity == ProjectErrorSeverity.critical;

  /// Проверить, требует ли ошибка немедленного внимания
  bool get requiresImmediateAttention => 
      severity == ProjectErrorSeverity.critical || 
      severity == ProjectErrorSeverity.high;

  /// Получить локализованное название категории
  String get categoryDisplayName {
    switch (category) {
      case ProjectErrorCategory.accessibility:
        return 'Доступность';
      case ProjectErrorCategory.permission:
        return 'Права доступа';
      case ProjectErrorCategory.network:
        return 'Сеть';
      case ProjectErrorCategory.validation:
        return 'Валидация';
      case ProjectErrorCategory.synchronization:
        return 'Синхронизация';
      case ProjectErrorCategory.fileSystem:
        return 'Файловая система';
      case ProjectErrorCategory.configuration:
        return 'Конфигурация';
      case ProjectErrorCategory.unknown:
        return 'Неизвестно';
    }
  }

  /// Получить локализованное название уровня критичности
  String get severityDisplayName {
    switch (severity) {
      case ProjectErrorSeverity.low:
        return 'Низкая';
      case ProjectErrorSeverity.medium:
        return 'Средняя';
      case ProjectErrorSeverity.high:
        return 'Высокая';
      case ProjectErrorSeverity.critical:
        return 'Критическая';
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ProjectError && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'ProjectError(id: $id, category: $category, severity: $severity, message: $message)';
  }

  /// Сгенерировать уникальный ID
  static String _generateId() {
    return '${DateTime.now().millisecondsSinceEpoch}_${Object().hashCode}';
  }
}