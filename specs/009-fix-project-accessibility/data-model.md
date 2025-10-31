# Data Model: Fix Project Accessibility Error

**Feature**: 009-fix-project-accessibility  
**Date**: 2025-10-29  
**Status**: Complete

## Entity Definitions

### Project

**Purpose**: Представляет проект с поддержкой файловых и папочных проектов

**Fields**:
```dart
class Project {
  final String id;                    // Уникальный идентификатор
  final String name;                  // Имя проекта
  final String filePath;              // Путь к файлу проекта (для файловых)
  final String directory;             // Директория проекта (для папочных)
  final Map<String, dynamic> settings; // Настройки проекта
  final ProjectStatus status;         // Текущий статус
  final DateTime lastModified;       // Время последнего изменения
  final bool isAccessible;            // Флаг доступности
}
```

**Validation Rules**:
- `id` - не пустой, уникальный
- `name` - не пустой, макс 100 символов
- `filePath` - валидный путь к файлу (для файловых проектов)
- `directory` - валидный путь к директории (для папочных проектов)
- `settings['is_folder_project']` - boolean, обязательное поле

**State Transitions**:
```
Created → Accessible → Inaccessible → Accessible
    ↓         ↓           ↓           ↓
  Error    Monitoring   Error      Monitoring
```

### ProjectSettings

**Purpose**: Конфигурация проекта с типом и параметрами мониторинга

**Fields**:
```dart
class ProjectSettings {
  final bool isFolderProject;         // Тип проекта (файл/папка)
  final bool enableMonitoring;        // Включить мониторинг изменений
  final Duration checkInterval;       // Интервал проверок (только для файлов)
  final List<String> ignorePatterns;  // Паттерны игнорируемых файлов
  final bool syncAcrossInstances;     // Синхронизация между экземплярами
}
```

**Default Values**:
```dart
ProjectSettings({
  this.isFolderProject = false,
  this.enableMonitoring = true,
  this.checkInterval = const Duration(seconds: 30),
  this.ignorePatterns = const ['*.tmp', '*.lock'],
  this.syncAcrossInstances = true,
});
```

### ProjectStatus

**Purpose**: Статус доступности проекта

**Enum Values**:
```dart
enum ProjectStatus {
  accessible,      // Проект доступен
  inaccessible,    // Проект недоступен
  checking,        // Проверка доступности
  error           // Критическая ошибка
}
```

### FileMonitorEvent

**Purpose**: Событие мониторинга файловой системы

**Fields**:
```dart
class FileMonitorEvent {
  final String path;              // Путь к файлу/папке
  final FileSystemEventType type;  // Тип события
  final DateTime timestamp;       // Время события
  final String? projectId;        // ID проекта (если применимо)
}
```

**Event Types**:
```dart
enum FileSystemEventType {
  created,     // Файл/папка создан
  modified,    // Файл/папка изменен
  deleted,     // Файл/папка удален
  moved        // Файл/папка перемещен
}
```

### ProjectSyncInfo

**Purpose**: Информация для синхронизации между экземплярами

**Fields**:
```dart
class ProjectSyncInfo {
  final String projectId;          // ID проекта
  final String instanceId;         // ID экземпляра приложения
  final DateTime lastSync;        // Время последней синхронизации
  final String lockFilePath;      // Путь к файлу блокировки
  final bool isLocked;            // Флаг блокировки
}
```

## Relationships

```
Project 1..1 ProjectSettings
Project 1..* FileMonitorEvent
Project 1..1 ProjectSyncInfo
Project 1..1 ProjectStatus
```

## Data Flow

### Project Opening Flow
```
1. User selects project
2. ProjectService.validateProject()
3. Create Project entity with settings
4. Start monitoring (if enabled)
5. Update ProjectStatus.accessible
```

### Monitoring Flow
```
1. FileMonitorService detects change
2. Create FileMonitorEvent
3. ProjectService.processEvent()
4. Update Project.lastModified
5. Notify other instances (if sync enabled)
```

### Accessibility Check Flow
```
1. User action triggers check
2. ProjectService.checkAccessibility()
3. Update Project.isAccessible
4. Update ProjectStatus accordingly
5. Show notification (if needed)
```

## Validation Rules Summary

### Project Validation
- Путь должен существовать и быть доступным
- Тип проекта должен соответствовать файловой структуре
- Сетевые пути запрещены для папочных проектов
- Права доступа должны быть достаточными

### Settings Validation
- `isFolderProject` должен соответствовать фактической структуре
- `checkInterval` должен быть >= 5 секунд
- `ignorePatterns` должен быть валидным regex

### Event Validation
- Путь должен быть абсолютным
- Тип события должен соответствовать фактическому изменению
- ProjectId должен существовать в системе

## Storage Requirements

### In-Memory Storage
- Active projects with monitoring
- Recent file monitor events (last 100)
- Current sync information

### Persistent Storage
- Project configurations (SharedPreferences)
- Sync lock files (file system)
- Monitoring state (recovery on restart)

## Performance Considerations

### Memory Usage
- ~1KB per active project
- ~100B per monitor event
- ~500B per sync info

### Disk I/O
- Minimal - only for lock files and state persistence
- Event-driven, no periodic scans
- Efficient file watching

### Network Usage
- None - fully offline capable
- Optional sync via file system only