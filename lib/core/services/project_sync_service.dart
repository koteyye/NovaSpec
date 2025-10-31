import 'dart:async';
import '../../shared/models/project_sync_info.dart';
import '../../shared/models/project.dart';

abstract class ProjectSyncService {
  /// Stream событий синхронизации
  Stream<ProjectSyncEvent> get syncEventStream;

  /// Создать информацию о синхронизации для проекта
  Future<ProjectSyncInfo> createSyncInfo(Project project);

  /// Получить информацию о синхронизации проекта
  Future<ProjectSyncInfo?> getSyncInfo(String projectId);

  /// Обновить информацию о синхронизации
  Future<void> updateSyncInfo(ProjectSyncInfo syncInfo);

  /// Заблокировать проект для эксклюзивного доступа
  Future<bool> lockProject(String projectId);

  /// Разблокировать проект
  Future<void> unlockProject(String projectId);

  /// Проверить, заблокирован ли проект
  Future<bool> isProjectLocked(String projectId);

  /// Получить ID экземпляра, который заблокировал проект
  Future<String?> getLockHolder(String projectId);

  /// Синхронизировать изменения с другими экземплярами
  Future<void> syncChanges(String projectId, Map<String, dynamic> changes);

  /// Проверить наличие изменений от других экземпляров
  Future<Map<String, dynamic>?> checkForUpdates(String projectId);

  /// Очистить устаревшие блокировки
  Future<void> cleanupStaleLocks({Duration maxAge = const Duration(minutes: 5)});

  /// Получить список активных синхронизаций
  Future<List<ProjectSyncInfo>> getActiveSyncs();

  /// Принудительно разблокировать проект (только для администрирования)
  Future<void> forceUnlockProject(String projectId);

  /// Проверить состояние синхронизации
  Future<SyncStatus> getSyncStatus(String projectId);

  /// Dispose сервиса
  void dispose();
}

/// События синхронизации
class ProjectSyncEvent {
  final String projectId;
  final SyncEventType type;
  final String? instanceId;
  final DateTime timestamp;
  final Map<String, dynamic>? data;

  const ProjectSyncEvent({
    required this.projectId,
    required this.type,
    this.instanceId,
    required this.timestamp,
    this.data,
  });
}

/// Типы событий синхронизации
enum SyncEventType {
  locked,          // Проект заблокирован
  unlocked,        // Проект разблокирован
  conflict,        // Конфликт изменений
  updated,         // Проект обновлен
  error,           // Ошибка синхронизации
}

/// Статус синхронизации
enum SyncStatus {
  synced,          // Синхронизирован
  pending,        // Ожидает синхронизации
  conflict,        // Конфликт
  error,           // Ошибка
  offline,         // Офлайн
}