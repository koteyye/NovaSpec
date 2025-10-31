# Research: Fix Project Accessibility Error

**Feature**: 009-fix-project-accessibility  
**Date**: 2025-10-29  
**Status**: Complete

## Research Tasks & Findings

### Task 1: File System Monitoring Patterns for Flutter

**Research Question**: Как реализовать постоянный мониторинг файловой системы в Flutter без периодических проверок?

**Decision**: Использовать `Stream<FileSystemEvent>` из `dart:io` для мониторинга изменений в директориях проекта.

**Rationale**: 
- Нативная поддержка в Dart без дополнительных зависимостей
- Реактивный подход - мгновенная реакция на изменения
- Низкое потребление ресурсов по сравнению с таймерами
- Поддержка всех платформ (Windows, Linux, macOS)

**Alternatives Considered**:
- `watcher` пакет - дополнительная зависимость, избыточная функциональность
- Периодические проверки с увеличенным интервалом - не решает проблему ложных срабатываний
- `FileStat.lastModified()` проверки - неэффективно для папок

### Task 2: Project Type Detection Best Practices

**Research Question**: Как надежно определять тип проекта (файл/папка) и обрабатывать сетевые пути?

**Decision**: Использовать комбинацию проверки `project.settings['is_folder_project']` и анализа пути файловой системы.

**Rationale**:
- Соответствует существующей архитектуре проекта
- Позволяет явное управление типом проекта
- Простота валидации и отладки

**Implementation Details**:
```dart
bool isFolderProject(Project project) {
  return project.settings['is_folder_project'] == true;
}

bool isNetworkPath(String path) {
  return path.startsWith('\\\\') || path.startsWith('//') || path.contains(':\\');
}
```

### Task 3: Multi-Instance Synchronization

**Research Question**: Как синхронизировать состояние проекта между несколькими экземплярами приложения?

**Decision**: Использовать файловую блокировку и watch-мониторинг для обнаружения внешних изменений.

**Rationale**:
- Не требует серверной компоненты
- Работает в офлайн-режиме
- Минимальная задержка синхронизации

**Implementation Pattern**:
```dart
class ProjectSyncService {
  final Map<String, DateTime> _lastModified = {};
  
  void watchProject(String projectPath) {
    File(projectPath).watch().listen((event) {
      if (event.type == FileSystemEvent.modify) {
        _notifyOtherInstances(projectPath);
      }
    });
  }
}
```

### Task 4: Error Handling for Permission Issues

**Research Question**: Как корректно обрабатывать ошибки прав доступа без показа ложных уведомлений?

**Decision**: Использовать градуированный подход к ошибкам с категоризацией по критичности.

**Rationale**:
- Разделяет критические ошибки от временных проблем
- Позволяет адаптивную реакцию системы
- Соответствует принципу Graceful Degradation

**Error Categories**:
- **Critical**: Полная потеря доступа к проекту → показать уведомление
- **Temporary**: Временная блокировка файла → повторить попытку
- **Permission**: Недостаточно прав → показать диалог с инструкциями

## Technical Decisions Summary

| Component | Decision | Justification |
|-----------|----------|---------------|
| File Monitoring | `dart:io` FileSystemEvent streams | Нативная поддержка, реактивность |
| Project Type Detection | Settings flag + path analysis | Соответствие архитектуре |
| Multi-Instance Sync | File watching + locking | Офлайн-работоспособность |
| Error Handling | Categorized error responses | Graceful degradation |
| UI Notifications | ModernToast only | Соответствие конституции |

## Dependencies Analysis

**Existing Dependencies** (no changes needed):
- `provider` - для управления состоянием
- `dio` - для HTTP запросов (не используется в этой фиче)
- `file_picker` - для выбора файлов
- `flutter_secure_storage` - для хранения токенов
- `shared_preferences` - для настроек

**No New Dependencies Required** - все функциональность реализуется через стандартную библиотеку Dart.

## Performance Considerations

- **Memory Usage**: Минимальное увеличение за счет stream подписок
- **CPU Usage**: Снижение по сравнению с таймерными проверками
- **Disk I/O**: Оптимизировано через event-driven подход
- **Network Impact**: Нулевой (офлайн-функциональность)

## Risk Assessment

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| File system events missed | Low | Medium | Fallback к периодическим проверкам |
| Permission errors | Medium | Low | Graceful error handling |
| Multi-instance race conditions | Low | High | File locking mechanism |
| Platform-specific behavior | Medium | Medium | Тестирование на всех платформах |

## Implementation Complexity

**Overall Complexity**: Medium
- **Core Logic**: Low-Medium (известные паттерны)
- **Error Handling**: Medium (нужна careful категоризация)
- **Testing**: Medium (ручное тестирование на разных платформах)
- **Integration**: Low (минимальные изменения в существующий код)

## Next Steps

1. Implement `FileMonitorService` с stream-based мониторингом
2. Update `ProjectProvider` для использования нового подхода
3. Add error categorization в `ErrorHandler`
4. Implement multi-instance synchronization
5. Manual testing на всех целевых платформах