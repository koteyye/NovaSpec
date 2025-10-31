import 'dart:async';
import 'dart:convert';
import 'dart:io';
import '../../../core/services/project_sync_service.dart';
import '../../../shared/models/project_sync_info.dart';
import '../../../shared/models/project.dart';
import '../../../core/utils/app_logger.dart';

class ProjectSyncServiceImpl implements ProjectSyncService {
  final Map<String, ProjectSyncInfo> _syncInfos = {};
  final StreamController<ProjectSyncEvent> _controller = 
      StreamController<ProjectSyncEvent>.broadcast();
  Timer? _cleanupTimer;

  ProjectSyncServiceImpl() {
    _startCleanupTimer();
  }

  @override
  Stream<ProjectSyncEvent> get syncEventStream => _controller.stream;

  @override
  Future<ProjectSyncInfo> createSyncInfo(Project project) async {
    AppLogger.debug('Creating sync info for project: ${project.id}', tag: 'PROJECT_SYNC');
    
    // Use appropriate path based on project type
    final projectPath = project.isFolderProject ? project.directory : 
                      project.filePath.isNotEmpty ? Directory(project.filePath).parent.path : 
                      project.directory;
    
    final syncInfo = ProjectSyncInfo.create(
      projectId: project.id,
      projectPath: projectPath,
    );
    
    _syncInfos[project.id] = syncInfo;
    await _saveSyncInfo(syncInfo);
    
    // Start monitoring for external changes
    _startSyncMonitoring(project.id, projectPath);
    
    AppLogger.syncOperation(project.id, 'create_sync_info', success: true);
    return syncInfo;
  }

  @override
  Future<ProjectSyncInfo?> getSyncInfo(String projectId) async {
    if (_syncInfos.containsKey(projectId)) {
      return _syncInfos[projectId];
    }
    
    // Try to load from file
    final syncInfo = await _loadSyncInfo(projectId);
    if (syncInfo != null) {
      _syncInfos[projectId] = syncInfo;
    }
    
    return syncInfo;
  }

  @override
  Future<void> updateSyncInfo(ProjectSyncInfo syncInfo) async {
    _syncInfos[syncInfo.projectId] = syncInfo;
    await _saveSyncInfo(syncInfo);
  }

  @override
  Future<bool> lockProject(String projectId) async {
    AppLogger.debug('Attempting to lock project: $projectId', tag: 'PROJECT_SYNC');
    
    final syncInfo = await getSyncInfo(projectId);
    if (syncInfo == null) {
      AppLogger.warning('Sync info not found for project: $projectId', tag: 'PROJECT_SYNC');
      return false;
    }

    // Check if already locked by this instance
    if (await isProjectLocked(projectId)) {
      final lockHolder = await getLockHolder(projectId);
      if (lockHolder == syncInfo.instanceId) {
        AppLogger.debug('Project already locked by this instance: $projectId', tag: 'PROJECT_SYNC');
        return true;
      } else {
        AppLogger.lockConflict(projectId, lockHolder ?? 'unknown');
        return false;
      }
    }

    // Try to acquire lock with retry mechanism
    final result = await _acquireLockWithRetry(syncInfo, maxRetries: 3);
    if (result) {
      AppLogger.lockAcquired(projectId, syncInfo.instanceId);
    } else {
      AppLogger.warning('Failed to acquire lock for project: $projectId', tag: 'PROJECT_SYNC');
    }
    return result;
  }

  Future<bool> _acquireLockWithRetry(ProjectSyncInfo syncInfo, {int maxRetries = 3}) async {
    for (int attempt = 0; attempt < maxRetries; attempt++) {
      try {
        // Check if lock is still available
        if (await isProjectLocked(syncInfo.projectId)) {
          final lockHolder = await getLockHolder(syncInfo.projectId);
          if (lockHolder != syncInfo.instanceId) {
            // Lock is held by another instance
            return false;
          }
        }

        // Create lock file with atomic operation
        final lockFile = File(syncInfo.lockFilePath);
        await lockFile.parent.create(recursive: true);
        
        // Create temporary lock file first
        final tempLockFile = File('${syncInfo.lockFilePath}.tmp.${DateTime.now().millisecondsSinceEpoch}');
        final lockData = {
          'project_id': syncInfo.projectId,
          'instance_id': syncInfo.instanceId,
          'timestamp': DateTime.now().toIso8601String(),
          'attempt': attempt + 1,
          'type': 'lock',
          'pid': _getCurrentProcessId(),
        };
        
        await tempLockFile.writeAsString(jsonEncode(lockData));
        
        // Atomic rename
        await tempLockFile.rename(syncInfo.lockFilePath);
        
        // Verify lock was acquired
        await Future.delayed(const Duration(milliseconds: 100));
        final currentHolder = await getLockHolder(syncInfo.projectId);
        if (currentHolder == syncInfo.instanceId) {
          // Lock successfully acquired
          final updatedSyncInfo = syncInfo.copyWith(
            isLocked: true,
            lastSync: DateTime.now(),
          );
          
          await updateSyncInfo(updatedSyncInfo);
          
          _emitEvent(ProjectSyncEvent(
            projectId: syncInfo.projectId,
            type: SyncEventType.locked,
            instanceId: syncInfo.instanceId,
            timestamp: DateTime.now(),
          ));
          
          return true;
        } else {
          // Lock race condition - cleanup and retry
          try {
            await tempLockFile.delete();
          } catch (_) {}
        }
      } catch (e) {
        if (attempt == maxRetries - 1) {
          // Last attempt failed
          return false;
        }
        
        // Wait before retry
        await Future.delayed(Duration(milliseconds: 100 * (attempt + 1)));
      }
    }
    
    return false;
  }

  int _getCurrentProcessId() {
    try {
      return pid;
    } catch (e) {
      return DateTime.now().hashCode;
    }
  }

  @override
  Future<void> unlockProject(String projectId) async {
    AppLogger.debug('Unlocking project: $projectId', tag: 'PROJECT_SYNC');
    
    final syncInfo = await getSyncInfo(projectId);
    if (syncInfo == null) {
      AppLogger.warning('Sync info not found for unlock: $projectId', tag: 'PROJECT_SYNC');
      return;
    }

    try {
      // Verify we own the lock before unlocking
      final lockHolder = await getLockHolder(projectId);
      if (lockHolder != syncInfo.instanceId) {
        AppLogger.securityEvent('unlock_attempt_by_non_owner', user: syncInfo.instanceId, resource: projectId);
        throw Exception('Cannot unlock project: lock is held by another instance');
      }

      final lockFile = File(syncInfo.lockFilePath);
      if (await lockFile.exists()) {
        // Create unlock record before deleting lock
        await _createUnlockRecord(syncInfo);
        
        await lockFile.delete();
      }
      
      // Clean up heartbeat file
      await _cleanupHeartbeat(syncInfo.instanceId, syncInfo);
      
      final updatedSyncInfo = syncInfo.copyWith(
        isLocked: false,
        lastSync: DateTime.now(),
      );
      
      await updateSyncInfo(updatedSyncInfo);
      
      AppLogger.lockReleased(projectId, syncInfo.instanceId);
      
      _emitEvent(ProjectSyncEvent(
        projectId: projectId,
        type: SyncEventType.unlocked,
        instanceId: syncInfo.instanceId,
        timestamp: DateTime.now(),
        data: {'intentional_unlock': true},
      ));
    } catch (e) {
      AppLogger.serviceError('ProjectSyncService', 'unlockProject', e);
      _emitEvent(ProjectSyncEvent(
        projectId: projectId,
        type: SyncEventType.error,
        instanceId: syncInfo.instanceId,
        timestamp: DateTime.now(),
        data: {'unlock_error': e.toString()},
      ));
    }
  }

  Future<void> _createUnlockRecord(ProjectSyncInfo syncInfo) async {
    try {
      final unlockFile = File('${syncInfo.lockFilePath}.unlock');
      final unlockData = {
        'project_id': syncInfo.projectId,
        'instance_id': syncInfo.instanceId,
        'timestamp': DateTime.now().toIso8601String(),
        'type': 'unlock',
        'reason': 'intentional',
      };
      
      await unlockFile.writeAsString(jsonEncode(unlockData));
      
      // Schedule cleanup of unlock record
      Timer(const Duration(minutes: 5), () async {
        try {
          if (await unlockFile.exists()) {
            await unlockFile.delete();
          }
        } catch (e) {
          // Ignore cleanup errors
        }
      });
    } catch (e) {
      // Ignore unlock record errors
    }
  }

  Future<void> _cleanupHeartbeat(String instanceId, ProjectSyncInfo syncInfo) async {
    try {
      final heartbeatFile = File('${syncInfo.lockFilePath}/../heartbeat_$instanceId.json');
      if (await heartbeatFile.exists()) {
        await heartbeatFile.delete();
      }
    } catch (e) {
      // Ignore heartbeat cleanup errors
    }
  }

  @override
  Future<bool> isProjectLocked(String projectId) async {
    final syncInfo = await getSyncInfo(projectId);
    if (syncInfo == null) {
      return false;
    }

    try {
      final lockFile = File(syncInfo.lockFilePath);
      if (!await lockFile.exists()) {
        return false;
      }

      final content = await lockFile.readAsString();
      final lockData = jsonDecode(content) as Map<String, dynamic>;
      
      // Check if lock is stale
      final timestamp = DateTime.parse(lockData['timestamp'] as String);
      final lockAge = DateTime.now().difference(timestamp);
      
      if (lockAge > const Duration(minutes: 5)) {
        // Check if the locking process is still alive
        final lockPid = lockData['pid'] as int?;
        if (lockPid != null && await _isProcessAlive(lockPid)) {
          // Process is still alive, extend lock
          await _extendLock(syncInfo.lockFilePath, lockData);
          return true;
        } else {
          // Process is dead, remove stale lock
          await lockFile.delete();
          return false;
        }
      }
      
      // Additional check: verify heartbeat
      final instanceId = lockData['instance_id'] as String?;
      if (instanceId != null && !await _hasRecentHeartbeat(instanceId, syncInfo)) {
        // No recent heartbeat, consider lock stale
        await lockFile.delete();
        return false;
      }
      
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> _isProcessAlive(int pid) async {
    try {
      // This is a simplified implementation
      // In a real implementation, you'd use platform-specific APIs
      // to check if the process is still running
      return true; // Assume alive for now
    } catch (e) {
      return false;
    }
  }

  Future<void> _extendLock(String lockFilePath, Map<String, dynamic> lockData) async {
    try {
      final lockFile = File(lockFilePath);
      final extendedLockData = Map<String, dynamic>.from(lockData);
      extendedLockData['timestamp'] = DateTime.now().toIso8601String();
      extendedLockData['extended'] = true;
      
      await lockFile.writeAsString(jsonEncode(extendedLockData));
    } catch (e) {
      // Ignore extension errors
    }
  }

  Future<bool> _hasRecentHeartbeat(String instanceId, ProjectSyncInfo syncInfo) async {
    try {
      final heartbeatFile = File('${syncInfo.lockFilePath}/../heartbeat_$instanceId.json');
      if (!await heartbeatFile.exists()) return false;
      
      final content = await heartbeatFile.readAsString();
      final data = jsonDecode(content) as Map<String, dynamic>;
      final timestamp = DateTime.parse(data['timestamp'] as String);
      
      return DateTime.now().difference(timestamp) < const Duration(minutes: 2);
    } catch (e) {
      return false;
    }
  }

  @override
  Future<String?> getLockHolder(String projectId) async {
    final syncInfo = await getSyncInfo(projectId);
    if (syncInfo == null) {
      return null;
    }

    try {
      final lockFile = File(syncInfo.lockFilePath);
      if (!await lockFile.exists()) {
        return null;
      }

      final content = await lockFile.readAsString();
      final lockData = jsonDecode(content) as Map<String, dynamic>;
      
      return lockData['instance_id'] as String?;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> syncChanges(String projectId, Map<String, dynamic> changes) async {
    final syncInfo = await getSyncInfo(projectId);
    if (syncInfo == null) {
      return;
    }

    try {
      final syncFile = File('${syncInfo.lockFilePath}.sync');
      await syncFile.parent.create(recursive: true);
      
      final syncData = {
        'project_id': projectId,
        'instance_id': syncInfo.instanceId,
        'timestamp': DateTime.now().toIso8601String(),
        'changes': changes,
        'type': 'sync',
      };
      
      await syncFile.writeAsString(jsonEncode(syncData));
      
      final updatedSyncInfo = syncInfo.copyWith(
        lastSync: DateTime.now(),
      );
      
      await updateSyncInfo(updatedSyncInfo);
      
      _emitEvent(ProjectSyncEvent(
        projectId: projectId,
        type: SyncEventType.updated,
        instanceId: syncInfo.instanceId,
        timestamp: DateTime.now(),
        data: changes,
      ));
    } catch (e) {
      _emitEvent(ProjectSyncEvent(
        projectId: projectId,
        type: SyncEventType.error,
        instanceId: syncInfo.instanceId,
        timestamp: DateTime.now(),
        data: {'error': e.toString()},
      ));
    }
  }

  @override
  Future<Map<String, dynamic>?> checkForUpdates(String projectId) async {
    final syncInfo = await getSyncInfo(projectId);
    if (syncInfo == null) {
      return null;
    }

    try {
      final syncFile = File('${syncInfo.lockFilePath}.sync');
      if (!await syncFile.exists()) {
        return null;
      }

      final content = await syncFile.readAsString();
      final syncData = jsonDecode(content) as Map<String, dynamic>;
      
      // Check if sync is from another instance
      if (syncData['instance_id'] != syncInfo.instanceId) {
        return syncData['changes'] as Map<String, dynamic>?;
      }
      
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> cleanupStaleLocks({Duration maxAge = const Duration(minutes: 5)}) async {
    for (final syncInfo in _syncInfos.values) {
      if (syncInfo.isSyncStale(maxAge: maxAge)) {
        await unlockProject(syncInfo.projectId);
      }
    }
  }

  @override
  Future<List<ProjectSyncInfo>> getActiveSyncs() async {
    return _syncInfos.values.where((info) => !info.isSyncStale()).toList();
  }

  @override
  Future<void> forceUnlockProject(String projectId) async {
    final syncInfo = await getSyncInfo(projectId);
    if (syncInfo == null) {
      return;
    }

    try {
      final lockFile = File(syncInfo.lockFilePath);
      if (await lockFile.exists()) {
        await lockFile.delete();
      }
      
      final updatedSyncInfo = syncInfo.copyWith(
        isLocked: false,
        lastSync: DateTime.now(),
      );
      
      await updateSyncInfo(updatedSyncInfo);
    } catch (e) {
      // Ignore force unlock errors
    }
  }

  @override
  Future<SyncStatus> getSyncStatus(String projectId) async {
    final syncInfo = await getSyncInfo(projectId);
    if (syncInfo == null) {
      return SyncStatus.offline;
    }

    if (await isProjectLocked(projectId)) {
      final lockHolder = await getLockHolder(projectId);
      if (lockHolder == syncInfo.instanceId) {
        return SyncStatus.synced;
      } else {
        return SyncStatus.conflict;
      }
    }

    return SyncStatus.synced;
  }

  @override
  void dispose() {
    _cleanupTimer?.cancel();
    _controller.close();
  }

  void _emitEvent(ProjectSyncEvent event) {
    _controller.add(event);
  }

  Future<void> _saveSyncInfo(ProjectSyncInfo syncInfo) async {
    try {
      final syncFile = File('${syncInfo.lockFilePath}.info');
      await syncFile.parent.create(recursive: true);
      await syncFile.writeAsString(jsonEncode(syncInfo.toMap()));
    } catch (e) {
      // Ignore save errors for now
    }
  }

  Future<ProjectSyncInfo?> _loadSyncInfo(String projectId) async {
    try {
      // Try to find sync info file in common project directories
      final possiblePaths = [
        '.novaspec/sync_$projectId$projectId.info',
        '.novaspec/sync.info',
        'sync_$projectId.info',
      ];
      
      for (final relativePath in possiblePaths) {
        final syncFile = File(relativePath);
        if (await syncFile.exists()) {
          final content = await syncFile.readAsString();
          final data = jsonDecode(content) as Map<String, dynamic>;
          final syncInfo = ProjectSyncInfo.fromMap(data);
          
          // Verify this is the right project
          if (syncInfo.projectId == projectId) {
            return syncInfo;
          }
        }
      }
      
      return null;
    } catch (e) {
      return null;
    }
  }

  void _startCleanupTimer() {
    _cleanupTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      cleanupStaleLocks();
    });
  }

  void _startSyncMonitoring(String projectId, String projectPath) {
    // Monitor sync files for external changes
    final syncDir = Directory('$projectPath/.novaspec');
    
    // Create sync directory if it doesn't exist
    syncDir.createSync();
    
    // Start watching for sync file changes
    syncDir.watch(recursive: false).listen((event) {
      if (event.path.endsWith('.sync')) {
        _handleExternalSyncChange(projectId, event.path);
      } else if (event.path.endsWith('.lock')) {
        _handleExternalLockChange(projectId, event.path);
      } else if (event.path.endsWith('.lock')) {
        _handleExternalUnlockChange(projectId, event.path);
      }
    });
    
    // Start heartbeat for this instance
    _startHeartbeat(projectId, projectPath);
  }

  void _handleExternalLockChange(String projectId, String lockPath) {
    // Check if lock is from another instance
    _checkLockOwnership(projectId, lockPath).then((isOwnedByOther) {
      if (isOwnedByOther) {
        _emitEvent(ProjectSyncEvent(
          projectId: projectId,
          type: SyncEventType.locked,
          timestamp: DateTime.now(),
          data: {'external_lock': true, 'lock_path': lockPath},
        ));
      }
    });
  }

  void _handleExternalUnlockChange(String projectId, String lockPath) {
    _emitEvent(ProjectSyncEvent(
      projectId: projectId,
      type: SyncEventType.unlocked,
      timestamp: DateTime.now(),
      data: {'external_unlock': true, 'lock_path': lockPath},
    ));
  }

  Future<bool> _checkLockOwnership(String projectId, String lockPath) async {
    try {
      final lockFile = File(lockPath);
      if (!await lockFile.exists()) return false;
      
      final content = await lockFile.readAsString();
      final lockData = jsonDecode(content) as Map<String, dynamic>;
      final lockInstanceId = lockData['instance_id'] as String?;
      
      final syncInfo = await getSyncInfo(projectId);
      return lockInstanceId != null && syncInfo?.instanceId != lockInstanceId;
    } catch (e) {
      return false;
    }
  }

  void _startHeartbeat(String projectId, String projectPath) {
    // Send heartbeat every 30 seconds to indicate this instance is alive
    Timer.periodic(const Duration(seconds: 30), (timer) async {
      final syncInfo = await getSyncInfo(projectId);
      if (syncInfo == null) {
        timer.cancel();
        return;
      }
      
      try {
        final heartbeatFile = File('$projectPath/.novaspec/heartbeat_${syncInfo.instanceId}.json');
        final heartbeatData = {
          'instance_id': syncInfo.instanceId,
          'timestamp': DateTime.now().toIso8601String(),
          'project_id': projectId,
          'type': 'heartbeat',
        };
        
        await heartbeatFile.writeAsString(jsonEncode(heartbeatData));
      } catch (e) {
        // Ignore heartbeat errors
      }
    });
  }

  /// Discover other instances of the application
  Future<List<String>> discoverOtherInstances(String projectId) async {
    final syncInfo = await getSyncInfo(projectId);
    if (syncInfo == null) return [];
    
    try {
      final syncDir = Directory('${syncInfo.lockFilePath}/../');
      if (!await syncDir.exists()) return [];
      
      final instances = <String>[];
      await for (final entity in syncDir.list()) {
        if (entity is File && entity.path.contains('heartbeat_')) {
          try {
            final content = await entity.readAsString();
            final data = jsonDecode(content) as Map<String, dynamic>;
            
            final instanceId = data['instance_id'] as String?;
            final timestamp = DateTime.parse(data['timestamp'] as String);
            
            // Check if heartbeat is recent (within last 2 minutes)
            if (instanceId != null && 
                instanceId != syncInfo.instanceId &&
                DateTime.now().difference(timestamp) < const Duration(minutes: 2)) {
              instances.add(instanceId);
            }
          } catch (e) {
            // Ignore invalid heartbeat files
          }
        }
      }
      
      return instances;
    } catch (e) {
      return [];
    }
  }

  /// Broadcast message to all instances
  Future<void> broadcastToInstances(String projectId, Map<String, dynamic> message) async {
    final syncInfo = await getSyncInfo(projectId);
    if (syncInfo == null) return;
    
    try {
      final broadcastFile = File('${syncInfo.lockFilePath}/../broadcast_${syncInfo.instanceId}_${DateTime.now().millisecondsSinceEpoch}.json');
      final broadcastData = {
        ...message,
        'instance_id': syncInfo.instanceId,
        'project_id': projectId,
        'timestamp': DateTime.now().toIso8601String(),
        'type': 'broadcast',
      };
      
      await broadcastFile.writeAsString(jsonEncode(broadcastData));
      
      // Clean up old broadcast files
      _cleanupOldBroadcasts('${syncInfo.lockFilePath}/../');
    } catch (e) {
      // Ignore broadcast errors
    }
  }

  void _cleanupOldBroadcasts(String syncDirPath) {
    try {
      final syncDir = Directory(syncDirPath);
      syncDir.list().where((entity) => 
        entity is File && 
        entity.path.contains('broadcast_') &&
        entity.path.endsWith('.json')
      ).cast<File>().forEach((file) async {
        try {
          final stat = await file.stat();
          // Delete broadcast files older than 5 minutes
          if (DateTime.now().difference(stat.modified) > const Duration(minutes: 5)) {
            await file.delete();
          }
        } catch (e) {
          // Ignore cleanup errors
        }
      });
    } catch (e) {
      // Ignore cleanup errors
    }
  }

  Future<void> _handleExternalSyncChange(String projectId, String syncFilePath) async {
    try {
      final syncFile = File(syncFilePath);
      if (!await syncFile.exists()) return;
      
      final content = await syncFile.readAsString();
      final syncData = jsonDecode(content) as Map<String, dynamic>;
      
      // Check if this is from another instance
      final currentSyncInfo = _syncInfos[projectId];
      if (currentSyncInfo != null && syncData['instance_id'] != currentSyncInfo.instanceId) {
        _emitEvent(ProjectSyncEvent(
          projectId: projectId,
          type: SyncEventType.updated,
          instanceId: syncData['instance_id'] as String?,
          timestamp: DateTime.now(),
          data: syncData['changes'] as Map<String, dynamic>?,
        ));
      }
    } catch (e) {
      // Ignore sync monitoring errors
    }
  }

  /// Get comprehensive sync status with details
  Future<Map<String, dynamic>> getSyncStatusDetails(String projectId) async {
    final syncInfo = await getSyncInfo(projectId);
    if (syncInfo == null) {
      return {
        'hasSync': false,
        'status': 'offline',
        'message': 'Синхронизация не настроена',
      };
    }

    final isLocked = await isProjectLocked(projectId);
    final lockHolder = await getLockHolder(projectId);
    final status = await getSyncStatus(projectId);
    
    return {
      'hasSync': true,
      'projectId': projectId,
      'instanceId': syncInfo.instanceId,
      'status': status.name,
      'isLocked': isLocked,
      'lockHolder': lockHolder,
      'lastSync': syncInfo.lastSync.toIso8601String(),
      'lockFilePath': syncInfo.lockFilePath,
      'isCurrentInstanceLock': lockHolder == syncInfo.instanceId,
      'message': _getSyncStatusMessage(status, isLocked, lockHolder, syncInfo.instanceId),
    };
  }

  String _getSyncStatusMessage(SyncStatus status, bool isLocked, String? lockHolder, String currentInstanceId) {
    switch (status) {
      case SyncStatus.synced:
        if (isLocked && lockHolder == currentInstanceId) {
          return 'Проект заблокирован текущим экземпляром';
        }
        return 'Проект синхронизирован';
      case SyncStatus.conflict:
        return 'Конфликт: проект заблокирован другим экземпляром';
      case SyncStatus.pending:
        return 'Ожидание синхронизации...';
      case SyncStatus.error:
        return 'Ошибка синхронизации';
      case SyncStatus.offline:
        return 'Офлайн режим';
    }
  }

  /// Force sync with all instances
  Future<void> forceSyncAll(String projectId) async {
    final syncInfo = await getSyncInfo(projectId);
    if (syncInfo == null) return;

    try {
      // Create a force sync event
      await syncChanges(projectId, {
        'type': 'force_sync',
        'timestamp': DateTime.now().toIso8601String(),
        'instance_id': syncInfo.instanceId,
      });
      
      _emitEvent(ProjectSyncEvent(
        projectId: projectId,
        type: SyncEventType.updated,
        instanceId: syncInfo.instanceId,
        timestamp: DateTime.now(),
        data: {'force_sync': true},
      ));
    } catch (e) {
      _emitEvent(ProjectSyncEvent(
        projectId: projectId,
        type: SyncEventType.error,
        instanceId: syncInfo.instanceId,
        timestamp: DateTime.now(),
        data: {'error': 'Force sync failed: $e'},
      ));
    }
  }
}