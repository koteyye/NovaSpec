import 'dart:io';

class Project {
  final String name;
  final String filePath;
  final String directory;
  final DateTime createdAt;
  final DateTime modifiedAt;
  final ProjectStatus status;
  final Map<String, dynamic> settings;
  final Map<String, dynamic> content;
  final bool hasUnsavedChanges;
  final bool isEmpty;

  const Project({
    required this.name,
    required this.filePath,
    required this.directory,
    required this.createdAt,
    required this.modifiedAt,
    this.status = ProjectStatus.saved,
    this.settings = const {},
    this.content = const {},
    this.hasUnsavedChanges = false,
    this.isEmpty = false,
  });

  // Factory constructor for creating a new project
  factory Project.createNew({
    required String name,
    required String directory,
  }) {
    final now = DateTime.now();
    final filePath = '$directory/${name.toLowerCase().replaceAll(' ', '_')}.novaspec';
    
    return Project(
      name: name,
      filePath: filePath,
      directory: directory,
      createdAt: now,
      modifiedAt: now,
      status: ProjectStatus.modified,
      settings: {
        'theme': 'light',
        'language': 'ru',
        'version': '1.0.0',
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
    final createdAt = DateTime.tryParse(data['created'] ?? '') ?? DateTime.now();
    final modifiedAt = DateTime.tryParse(data['modified'] ?? '') ?? DateTime.now();
    
    return Project(
      name: name,
      filePath: filePath,
      directory: directory,
      createdAt: createdAt,
      modifiedAt: modifiedAt,
      status: ProjectStatus.saved,
      settings: data['settings'] ?? {},
      content: data['content'] ?? {},
      hasUnsavedChanges: false,
      isEmpty: false,
    );
  }

  // Factory constructor for empty project (when onboarding is cancelled)
  factory Project.empty() {
    final now = DateTime.now();
    
    return Project(
      name: '',
      filePath: '',
      directory: '',
      createdAt: now,
      modifiedAt: now,
      status: ProjectStatus.empty,
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
    String? name,
    String? filePath,
    String? directory,
    DateTime? createdAt,
    DateTime? modifiedAt,
    ProjectStatus? status,
    Map<String, dynamic>? settings,
    Map<String, dynamic>? content,
    bool? hasUnsavedChanges,
    bool? isEmpty,
  }) {
    return Project(
      name: name ?? this.name,
      filePath: filePath ?? this.filePath,
      directory: directory ?? this.directory,
      createdAt: createdAt ?? this.createdAt,
      modifiedAt: modifiedAt ?? this.modifiedAt,
      status: status ?? this.status,
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
      status: ProjectStatus.modified,
    );
  }

  // Mark project as saved
  Project markAsSaved() {
    return copyWith(
      modifiedAt: DateTime.now(),
      status: ProjectStatus.saved,
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
      'version': settings['version'] ?? '1.0.0',
      'name': name,
      'created': createdAt.toIso8601String(),
      'modified': modifiedAt.toIso8601String(),
      'settings': settings,
      'content': content,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Project && other.filePath == filePath;
  }

  @override
  int get hashCode => filePath.hashCode;

  bool get isAccessible => status != ProjectStatus.corrupted && status != ProjectStatus.inaccessible;
  
  DateTime get lastModified => modifiedAt;

  @override
  String toString() {
    return 'Project(name: $name, filePath: $filePath, status: $status)';
  }
}

enum ProjectStatus {
  empty,      // No project loaded (onboarding cancelled)
  saved,      // Project is saved
  modified,   // Project has unsaved changes
  corrupted,  // Project file is corrupted
  inaccessible, // Project file is not accessible
}

extension ProjectStatusExtension on ProjectStatus {
  String get displayName {
    switch (this) {
      case ProjectStatus.empty:
        return 'Пустой проект';
      case ProjectStatus.saved:
        return 'Сохранено';
      case ProjectStatus.modified:
        return 'Изменено';
      case ProjectStatus.corrupted:
        return 'Поврежден';
      case ProjectStatus.inaccessible:
        return 'Недоступен';
    }
  }

  bool get isAccessible {
    return this != ProjectStatus.corrupted && this != ProjectStatus.inaccessible;
  }
}