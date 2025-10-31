import 'dart:io';
import 'project_status.dart';
import 'project_settings.dart';

class Project {
  final String id;                    // Уникальный идентификатор
  final String name;                  // Имя проекта
  final String filePath;              // Путь к файлу проекта (для файловых)
  final String directory;             // Директория проекта (для папочных)
  final ProjectSettings projectSettings; // Настройки проекта
  final ProjectStatus status;         // Текущий статус
  final DateTime lastModified;       // Время последнего изменения
  final bool isAccessible;            // Флаг доступности
  final DateTime createdAt;
  final DateTime modifiedAt;
  final Map<String, dynamic> settings;
  final Map<String, dynamic> content;
  final bool hasUnsavedChanges;
  final bool isEmpty;

  const Project({
    required this.id,
    required this.name,
    required this.filePath,
    required this.directory,
    required this.projectSettings,
    required this.status,
    required this.lastModified,
    required this.isAccessible,
    required this.createdAt,
    required this.modifiedAt,
    this.settings = const {},
    this.content = const {},
    this.hasUnsavedChanges = false,
    this.isEmpty = false,
  });

  // Factory constructor for creating a new project
  factory Project.createNew({
    required String name,
    required String directory,
    bool isFolderProject = false,
  }) {
    final now = DateTime.now();
    final id = _generateId();
    final filePath = isFolderProject ? '' : '$directory/${name.toLowerCase().replaceAll(' ', '_')}.novaspec';
    final projectSettings = ProjectSettings(
      isFolderProject: isFolderProject,
    );
    
    return Project(
      id: id,
      name: name,
      filePath: filePath,
      directory: directory,
      projectSettings: projectSettings,
      status: ProjectStatus.accessible,
      lastModified: now,
      isAccessible: true,
      createdAt: now,
      modifiedAt: now,
      settings: {
        'theme': 'light',
        'language': 'ru',
        'version': '1.0.0',
        'is_folder_project': isFolderProject,
      },
      content: {
        'sections': [],
        'specifications': [],
      },
      hasUnsavedChanges: true,
      isEmpty: false,
    );
  }

  // Factory constructor for loading existing project
  factory Project.fromFile({
    required String name,
    required String filePath,
    required String directory,
    required Map<String, dynamic> data,
  }) {
    final now = DateTime.now();
    final id = data['id'] ?? _generateId();
    final createdAt = DateTime.tryParse(data['created'] ?? '') ?? now;
    final modifiedAt = DateTime.tryParse(data['modified'] ?? '') ?? now;
    final lastModified = DateTime.tryParse(data['last_modified'] ?? '') ?? modifiedAt;
    final projectSettings = ProjectSettings.fromMap(data['project_settings'] ?? {});
    final status = ProjectStatus.values.firstWhere(
      (e) => e.name == (data['status'] ?? 'accessible'),
      orElse: () => ProjectStatus.accessible,
    );
    final isAccessible = data['is_accessible'] ?? true;
    
    return Project(
      id: id,
      name: name,
      filePath: filePath,
      directory: directory,
      projectSettings: projectSettings,
      status: status,
      lastModified: lastModified,
      isAccessible: isAccessible,
      createdAt: createdAt,
      modifiedAt: modifiedAt,
      settings: data['settings'] ?? {},
      content: data['content'] ?? {},
      hasUnsavedChanges: false,
      isEmpty: false,
    );
  }

  // Factory constructor for creating project from path (for loading existing projects)
  factory Project.fromPath({
    required String name,
    required String directory,
  }) {
    final now = DateTime.now();
    final id = _generateId();
    final projectSettings = const ProjectSettings(
      isFolderProject: true, // Assume folder project when loading from path
    );
    
    return Project(
      id: id,
      name: name,
      filePath: '',
      directory: directory,
      projectSettings: projectSettings,
      status: ProjectStatus.accessible,
      lastModified: now,
      isAccessible: true,
      createdAt: now,
      modifiedAt: now,
      settings: {
        'theme': 'light',
        'language': 'ru',
        'version': '1.0.0',
        'is_folder_project': true,
      },
      content: {
        'sections': [],
        'specifications': [],
      },
      hasUnsavedChanges: false,
      isEmpty: false,
    );
  }

  // Factory constructor for empty project (when onboarding is cancelled)
  factory Project.empty() {
    final now = DateTime.now();
    final id = _generateId();
    final projectSettings = const ProjectSettings();
    
    return Project(
      id: id,
      name: '',
      filePath: '',
      directory: '',
      projectSettings: projectSettings,
      status: ProjectStatus.accessible,
      lastModified: now,
      isAccessible: true,
      createdAt: now,
      modifiedAt: now,
      settings: {
        'theme': 'light',
        'language': 'ru',
        'version': '1.0.0',
      },
      content: {
        'sections': [],
        'specifications': [],
      },
      hasUnsavedChanges: false,
      isEmpty: true,
    );
  }

  // Create a copy with updated values
  Project copyWith({
    String? id,
    String? name,
    String? filePath,
    String? directory,
    ProjectSettings? projectSettings,
    ProjectStatus? status,
    DateTime? lastModified,
    bool? isAccessible,
    DateTime? createdAt,
    DateTime? modifiedAt,
    Map<String, dynamic>? settings,
    Map<String, dynamic>? content,
    bool? hasUnsavedChanges,
    bool? isEmpty,
  }) {
    return Project(
      id: id ?? this.id,
      name: name ?? this.name,
      filePath: filePath ?? this.filePath,
      directory: directory ?? this.directory,
      projectSettings: projectSettings ?? this.projectSettings,
      status: status ?? this.status,
      lastModified: lastModified ?? this.lastModified,
      isAccessible: isAccessible ?? this.isAccessible,
      createdAt: createdAt ?? this.createdAt,
      modifiedAt: modifiedAt ?? this.modifiedAt,
      settings: settings ?? this.settings,
      content: content ?? this.content,
      hasUnsavedChanges: hasUnsavedChanges ?? this.hasUnsavedChanges,
      isEmpty: isEmpty ?? this.isEmpty,
    );
  }

  // Mark project as modified
  Project markAsModified() {
    return copyWith(
      modifiedAt: DateTime.now(),
      lastModified: DateTime.now(),
    );
  }

  // Mark project as saved
  Project markAsSaved() {
    return copyWith(
      modifiedAt: DateTime.now(),
      lastModified: DateTime.now(),
      hasUnsavedChanges: false,
    );
  }

  // Update project accessibility
  Project updateAccessibility(bool accessible) {
    return copyWith(
      isAccessible: accessible,
      status: accessible ? ProjectStatus.accessible : ProjectStatus.inaccessible,
      lastModified: DateTime.now(),
    );
  }

  // Update project status
  Project updateStatus(ProjectStatus newStatus) {
    return copyWith(
      status: newStatus,
      lastModified: DateTime.now(),
    );
  }

  // Check if project file exists
  bool get fileExists {
    if (filePath.isEmpty) return false;
    return File(filePath).existsSync();
  }



  // Convert to JSON for file storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'version': settings['version'] ?? '1.0.0',
      'name': name,
      'file_path': filePath,
      'directory': directory,
      'project_settings': projectSettings.toMap(),
      'status': status.name,
      'last_modified': lastModified.toIso8601String(),
      'is_accessible': isAccessible,
      'created': createdAt.toIso8601String(),
      'modified': modifiedAt.toIso8601String(),
      'settings': settings,
      'content': content,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Project && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  // Helper method to generate unique ID
  static String _generateId() {
    return '${DateTime.now().millisecondsSinceEpoch}_${Object().hashCode}';
  }

  // Check if project is folder-based
  bool get isFolderProject => projectSettings.isFolderProject;

  // Check if project is file-based
  bool get isFileProject => !projectSettings.isFolderProject;

  // Convert to Map for serialization
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'file_path': filePath,
      'directory': directory,
      'project_settings': projectSettings.toMap(),
      'status': status.name,
      'last_modified': lastModified.toIso8601String(),
      'is_accessible': isAccessible,
      'created': createdAt.toIso8601String(),
      'modified': modifiedAt.toIso8601String(),
      'settings': settings,
      'content': content,
      'has_unsaved_changes': hasUnsavedChanges,
      'is_empty': isEmpty,
    };
  }

  // Create from Map
  factory Project.fromMap(Map<String, dynamic> map) {
    return Project(
      id: map['id'] ?? _generateId(),
      name: map['name'] ?? '',
      filePath: map['file_path'] ?? '',
      directory: map['directory'] ?? '',
      projectSettings: ProjectSettings.fromMap(map['project_settings'] ?? {}),
      status: ProjectStatus.values.firstWhere(
        (e) => e.name == (map['status'] ?? 'accessible'),
        orElse: () => ProjectStatus.accessible,
      ),
      lastModified: DateTime.tryParse(map['last_modified'] ?? '') ?? DateTime.now(),
      isAccessible: map['is_accessible'] ?? true,
      createdAt: DateTime.tryParse(map['created'] ?? '') ?? DateTime.now(),
      modifiedAt: DateTime.tryParse(map['modified'] ?? '') ?? DateTime.now(),
      settings: Map<String, dynamic>.from(map['settings'] ?? {}),
      content: Map<String, dynamic>.from(map['content'] ?? {}),
      hasUnsavedChanges: map['has_unsaved_changes'] ?? false,
      isEmpty: map['is_empty'] ?? false,
    );
  }

  @override
  String toString() {
    return 'Project(id: $id, name: $name, filePath: $filePath, status: $status, isAccessible: $isAccessible)';
  }
}
