class ProjectSettings {
  final bool isFolderProject;         // Тип проекта (файл/папка)
  final bool enableMonitoring;        // Включить мониторинг изменений
  final Duration checkInterval;       // Интервал проверок (только для файлов)
  final List<String> ignorePatterns;  // Паттерны игнорируемых файлов
  final bool syncAcrossInstances;     // Синхронизация между экземплярами

  const ProjectSettings({
    this.isFolderProject = false,
    this.enableMonitoring = true,
    this.checkInterval = const Duration(seconds: 30),
    this.ignorePatterns = const ['*.tmp', '*.lock'],
    this.syncAcrossInstances = true,
  });

  ProjectSettings copyWith({
    bool? isFolderProject,
    bool? enableMonitoring,
    Duration? checkInterval,
    List<String>? ignorePatterns,
    bool? syncAcrossInstances,
  }) {
    return ProjectSettings(
      isFolderProject: isFolderProject ?? this.isFolderProject,
      enableMonitoring: enableMonitoring ?? this.enableMonitoring,
      checkInterval: checkInterval ?? this.checkInterval,
      ignorePatterns: ignorePatterns ?? this.ignorePatterns,
      syncAcrossInstances: syncAcrossInstances ?? this.syncAcrossInstances,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'is_folder_project': isFolderProject,
      'enable_monitoring': enableMonitoring,
      'check_interval_seconds': checkInterval.inSeconds,
      'ignore_patterns': ignorePatterns,
      'sync_across_instances': syncAcrossInstances,
    };
  }

  factory ProjectSettings.fromMap(Map<String, dynamic> map) {
    return ProjectSettings(
      isFolderProject: map['is_folder_project'] ?? false,
      enableMonitoring: map['enable_monitoring'] ?? true,
      checkInterval: Duration(
        seconds: map['check_interval_seconds'] ?? 30,
      ),
      ignorePatterns: List<String>.from(map['ignore_patterns'] ?? ['*.tmp', '*.lock']),
      syncAcrossInstances: map['sync_across_instances'] ?? true,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ProjectSettings &&
        other.isFolderProject == isFolderProject &&
        other.enableMonitoring == enableMonitoring &&
        other.checkInterval == checkInterval &&
        other.syncAcrossInstances == syncAcrossInstances;
  }

  @override
  int get hashCode {
    return isFolderProject.hashCode ^
        enableMonitoring.hashCode ^
        checkInterval.hashCode ^
        syncAcrossInstances.hashCode;
  }

  // Создать настройки по умолчанию
  static ProjectSettings defaultSettings() {
    return const ProjectSettings();
  }

  @override
  String toString() {
    return 'ProjectSettings(isFolderProject: $isFolderProject, enableMonitoring: $enableMonitoring, checkInterval: $checkInterval, syncAcrossInstances: $syncAcrossInstances)';
  }
}