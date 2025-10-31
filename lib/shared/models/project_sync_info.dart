import 'dart:io';

class ProjectSyncInfo {
  final String projectId;          // ID проекта
  final String instanceId;         // ID экземпляра приложения
  final DateTime lastSync;        // Время последней синхронизации
  final String lockFilePath;      // Путь к файлу блокировки
  final bool isLocked;            // Флаг блокировки

  const ProjectSyncInfo({
    required this.projectId,
    required this.instanceId,
    required this.lastSync,
    required this.lockFilePath,
    this.isLocked = false,
  });

  ProjectSyncInfo copyWith({
    String? projectId,
    String? instanceId,
    DateTime? lastSync,
    String? lockFilePath,
    bool? isLocked,
  }) {
    return ProjectSyncInfo(
      projectId: projectId ?? this.projectId,
      instanceId: instanceId ?? this.instanceId,
      lastSync: lastSync ?? this.lastSync,
      lockFilePath: lockFilePath ?? this.lockFilePath,
      isLocked: isLocked ?? this.isLocked,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'project_id': projectId,
      'instance_id': instanceId,
      'last_sync': lastSync.toIso8601String(),
      'lock_file_path': lockFilePath,
      'is_locked': isLocked,
    };
  }

  factory ProjectSyncInfo.fromMap(Map<String, dynamic> map) {
    return ProjectSyncInfo(
      projectId: map['project_id'],
      instanceId: map['instance_id'],
      lastSync: DateTime.parse(map['last_sync']),
      lockFilePath: map['lock_file_path'],
      isLocked: map['is_locked'] ?? false,
    );
  }

  /// Создает информацию о синхронизации для нового проекта
  factory ProjectSyncInfo.create({
    required String projectId,
    required String projectPath,
  }) {
    final instanceId = _generateInstanceId();
    final lockFilePath = _getLockFilePath(projectPath, projectId);
    
    return ProjectSyncInfo(
      projectId: projectId,
      instanceId: instanceId,
      lastSync: DateTime.now(),
      lockFilePath: lockFilePath,
      isLocked: false,
    );
  }

  /// Генерирует уникальный ID экземпляра приложения
  static String _generateInstanceId() {
    return '${DateTime.now().millisecondsSinceEpoch}_${_getProcessId()}';
  }

  /// Получает ID процесса (упрощенная версия)
  static int _getProcessId() {
    return DateTime.now().hashCode;
  }

  /// Генерирует путь к файлу блокировки
  static String _getLockFilePath(String projectPath, String projectId) {
    final projectDir = Directory(projectPath);
    final lockDir = Directory('${projectDir.path}/.novaspec');
    return '${lockDir.path}/sync_$projectId.lock';
  }

  /// Проверяет, устарела ли синхронизация
  bool isSyncStale({Duration maxAge = const Duration(minutes: 5)}) {
    return DateTime.now().difference(lastSync) > maxAge;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ProjectSyncInfo &&
        other.projectId == projectId &&
        other.instanceId == instanceId &&
        other.lastSync == lastSync &&
        other.lockFilePath == lockFilePath &&
        other.isLocked == isLocked;
  }

  @override
  int get hashCode {
    return projectId.hashCode ^
        instanceId.hashCode ^
        lastSync.hashCode ^
        lockFilePath.hashCode ^
        isLocked.hashCode;
  }

  @override
  String toString() {
    return 'ProjectSyncInfo(projectId: $projectId, instanceId: $instanceId, lastSync: $lastSync, lockFilePath: $lockFilePath, isLocked: $isLocked)';
  }
}