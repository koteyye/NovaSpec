import 'dart:io';

enum FileSystemEventType {
  created,     // Файл/папка создан
  modified,    // Файл/папка изменен
  deleted,     // Файл/папка удален
  moved,       // Файл/папка перемещен
  error        // Ошибка мониторинга
}

class FileMonitorEvent {
  final String path;              // Путь к файлу/папке
  final FileSystemEventType type;  // Тип события
  final DateTime timestamp;       // Время события
  final String? projectId;        // ID проекта (если применимо)
  final String? error;            // Текст ошибки (для типа error)
  final String? destinationPath;  // Путь назначения (для типа moved)

  const FileMonitorEvent({
    required this.path,
    required this.type,
    required this.timestamp,
    this.projectId,
    this.error,
    this.destinationPath,
  });

  factory FileMonitorEvent.fromFileSystemEvent(FileSystemEvent event, {String? projectId}) {
    FileSystemEventType type;
    switch (event.type) {
      case FileSystemEvent.create:
        type = FileSystemEventType.created;
        break;
      case FileSystemEvent.modify:
        type = FileSystemEventType.modified;
        break;
      case FileSystemEvent.delete:
        type = FileSystemEventType.deleted;
        break;
      case FileSystemEvent.move:
        type = FileSystemEventType.moved;
        break;
      default:
        type = FileSystemEventType.modified;
        break;
    }

    return FileMonitorEvent(
      path: event.path,
      type: type,
      timestamp: DateTime.now(),
      projectId: projectId,
      destinationPath: event is FileSystemMoveEvent ? event.destination : null,
    );
  }

  FileMonitorEvent copyWith({
    String? path,
    FileSystemEventType? type,
    DateTime? timestamp,
    String? projectId,
  }) {
    return FileMonitorEvent(
      path: path ?? this.path,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      projectId: projectId ?? this.projectId,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'path': path,
      'type': type.name,
      'timestamp': timestamp.toIso8601String(),
      'project_id': projectId,
    };
  }

  factory FileMonitorEvent.fromMap(Map<String, dynamic> map) {
    return FileMonitorEvent(
      path: map['path'],
      type: FileSystemEventType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => FileSystemEventType.modified,
      ),
      timestamp: DateTime.parse(map['timestamp']),
      projectId: map['project_id'],
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FileMonitorEvent &&
        other.path == path &&
        other.type == type &&
        other.timestamp == timestamp &&
        other.projectId == projectId;
  }

  @override
  int get hashCode {
    return path.hashCode ^
        type.hashCode ^
        timestamp.hashCode ^
        projectId.hashCode;
  }

  @override
  String toString() {
    return 'FileMonitorEvent(path: $path, type: $type, timestamp: $timestamp, projectId: $projectId)';
  }
}