# Project Service API Contract

**Feature**: 009-fix-project-accessibility  
**Version**: 1.0.0  
**Date**: 2025-10-29

## Overview

API для управления проектами с поддержкой файловых и папочных проектов, мониторингом доступности и синхронизацией между экземплярами.

## Service Interface

### ProjectService

```dart
abstract class ProjectService {
  // Project Management
  Future<Project> openProject(String path);
  Future<void> closeProject(String projectId);
  Future<List<Project>> getRecentProjects();
  
  // Accessibility
  Future<bool> checkProjectAccessibility(String projectId);
  Stream<ProjectStatus> watchProjectStatus(String projectId);
  
  // Monitoring
  Future<void> startMonitoring(String projectId);
  Future<void> stopMonitoring(String projectId);
  Stream<FileMonitorEvent> watchProjectChanges(String projectId);
  
  // Synchronization
  Future<void> enableSync(String projectId);
  Future<void> disableSync(String projectId);
  Future<bool> isProjectLocked(String projectId);
}
```

### FileMonitorService

```dart
abstract class FileMonitorService {
  // Monitoring Control
  Future<void> watchDirectory(String path, String projectId);
  Future<void> stopWatching(String path);
  
  // Event Stream
  Stream<FileMonitorEvent> get eventStream;
  
  // Configuration
  void setIgnorePatterns(List<String> patterns);
  void setPollingInterval(Duration interval);
}
```

### ProjectSyncService

```dart
abstract class ProjectSyncService {
  // Lock Management
  Future<bool> acquireLock(String projectId);
  Future<void> releaseLock(String projectId);
  Future<bool> isLockedByOther(String projectId);
  
  // Sync Communication
  Future<void> notifyChange(String projectId, ProjectSyncInfo info);
  Stream<ProjectSyncInfo> watchSyncEvents(String projectId);
  
  // Instance Management
  String get currentInstanceId;
  Future<List<String>> getActiveInstances(String projectId);
}
```

## Data Models

### Project
```dart
class Project {
  final String id;
  final String name;
  final String filePath;
  final String directory;
  final Map<String, dynamic> settings;
  final ProjectStatus status;
  final DateTime lastModified;
  final bool isAccessible;
  
  const Project({
    required this.id,
    required this.name,
    required this.filePath,
    required this.directory,
    required this.settings,
    required this.status,
    required this.lastModified,
    required this.isAccessible,
  });
  
  bool get isFolderProject => settings['is_folder_project'] == true;
  String get effectivePath => isFolderProject ? directory : filePath;
}
```

### ProjectSettings
```dart
class ProjectSettings {
  final bool isFolderProject;
  final bool enableMonitoring;
  final Duration checkInterval;
  final List<String> ignorePatterns;
  final bool syncAcrossInstances;
  
  const ProjectSettings({
    this.isFolderProject = false,
    this.enableMonitoring = true,
    this.checkInterval = const Duration(seconds: 30),
    this.ignorePatterns = const ['*.tmp', '*.lock'],
    this.syncAcrossInstances = true,
  });
}
```

### FileMonitorEvent
```dart
class FileMonitorEvent {
  final String path;
  final FileSystemEventType type;
  final DateTime timestamp;
  final String? projectId;
  
  const FileMonitorEvent({
    required this.path,
    required this.type,
    required this.timestamp,
    this.projectId,
  });
}
```

### ProjectSyncInfo
```dart
class ProjectSyncInfo {
  final String projectId;
  final String instanceId;
  final DateTime lastSync;
  final String lockFilePath;
  final bool isLocked;
  
  const ProjectSyncInfo({
    required this.projectId,
    required this.instanceId,
    required this.lastSync,
    required this.lockFilePath,
    required this.isLocked,
  });
}
```

## Error Handling

### Error Types
```dart
enum ProjectErrorType {
  projectNotFound,
  accessDenied,
  invalidPath,
  networkPathNotAllowed,
  syncLockFailed,
  monitoringFailed,
}

class ProjectError implements Exception {
  final ProjectErrorType type;
  final String message;
  final String? projectId;
  final String? path;
  
  const ProjectError({
    required this.type,
    required this.message,
    this.projectId,
    this.path,
  });
}
```

### Error Responses
```dart
// Accessibility Check Errors
ProjectError(type: ProjectErrorType.accessDenied, message: "Недостаточно прав доступа")
ProjectError(type: ProjectErrorType.networkPathNotAllowed, message: "Сетевые пути не поддерживаются")

// Sync Errors
ProjectError(type: ProjectErrorType.syncLockFailed, message: "Не удалось получить блокировку проекта")
ProjectError(type: ProjectErrorType.projectNotFound, message: "Проект не найден")

// Monitoring Errors
ProjectError(type: ProjectErrorType.monitoringFailed, message: "Ошибка мониторинга файловой системы")
```

## Event Streams

### Project Status Stream
```dart
// Emits ProjectStatus changes
Stream<ProjectStatus> watchProjectStatus(String projectId);

// Example events:
ProjectStatus.accessible
ProjectStatus.inaccessible
ProjectStatus.checking
ProjectStatus.error
```

### File Monitor Stream
```dart
// Emits file system changes
Stream<FileMonitorEvent> watchProjectChanges(String projectId);

// Example events:
FileMonitorEvent(path: "/project/file.dart", type: FileSystemEventType.modified)
FileMonitorEvent(path: "/project/new_file.dart", type: FileSystemEventType.created)
FileMonitorEvent(path: "/project/old_file.dart", type: FileSystemEventType.deleted)
```

### Sync Events Stream
```dart
// Emits synchronization events
Stream<ProjectSyncInfo> watchSyncEvents(String projectId);

// Example events:
ProjectSyncInfo(projectId: "proj1", instanceId: "inst2", isLocked: true)
ProjectSyncInfo(projectId: "proj1", instanceId: "inst2", isLocked: false)
```

## Configuration

### Service Registration
```dart
// In service_locator.dart
void registerProjectServices() {
  getIt.registerSingleton<ProjectService>(ProjectServiceImpl());
  getIt.registerSingleton<FileMonitorService>(FileMonitorServiceImpl());
  getIt.registerSingleton<ProjectSyncService>(ProjectSyncServiceImpl());
}
```

### Default Settings
```dart
const ProjectSettings defaultSettings = ProjectSettings(
  isFolderProject: false,
  enableMonitoring: true,
  checkInterval: Duration(seconds: 30),
  ignorePatterns: ['*.tmp', '*.lock', '.git/*'],
  syncAcrossInstances: true,
);
```

## Performance Requirements

### Response Times
- Project opening: < 500ms
- Accessibility check: < 100ms
- Monitoring start: < 50ms
- Sync lock acquisition: < 200ms

### Resource Limits
- Memory per project: < 1MB
- File handles per project: < 10
- Monitor events buffered: 100 events max

### Scalability
- Concurrent projects: 10+
- Monitor events per second: 100+
- Sync instances per project: 5+

## Security Considerations

### Path Validation
```dart
bool isValidProjectPath(String path) {
  // Reject network paths
  if (path.startsWith('\\\\') || path.startsWith('//')) {
    return false;
  }
  
  // Validate path format
  try {
    final dir = Directory(path);
    return dir.isAbsolute;
  } catch (e) {
    return false;
  }
}
```

### Permission Checks
```dart
Future<bool> hasProjectPermissions(String path) async {
  try {
    final file = File(path);
    await file.readAsString();
    return true;
  } catch (e) {
    return false;
  }
}
```

## Testing Requirements

### Manual Testing Scenarios
1. Open folder project - verify no accessibility notifications
2. Delete project folder - verify error notification
3. Open same project in two instances - verify sync
4. Try network path - verify rejection
5. Modify files externally - verify monitoring

### Performance Testing
1. Monitor 1000+ files in project
2. Rapid file changes (10+ per second)
3. Multiple concurrent projects
4. Long-running monitoring (hours)