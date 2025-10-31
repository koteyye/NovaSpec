import 'dart:async';
import 'dart:io';
import '../../../core/services/file_monitor_service.dart';
import '../../../shared/models/file_monitor_event.dart';

class FileMonitorServiceImpl implements FileMonitorService {
  final StreamController<FileMonitorEvent> _globalController = 
      StreamController<FileMonitorEvent>.broadcast();
  
  final Map<String, FileMonitor> _monitors = {};

  @override
  Stream<FileMonitorEvent> get fileEvents => _globalController.stream;

  @override
  Future<void> startMonitoring(String path, {String? projectId}) async {
    if (_monitors.containsKey(path)) return;

    final monitor = FileMonitor(
      path,
      StreamController<FileMonitorEvent>.broadcast(),
      _globalController,
      projectId,
    );

    _monitors[path] = monitor;
    await monitor.start();
  }

  @override
  Future<void> stopMonitoring(String path) async {
    final monitor = _monitors.remove(path);
    if (monitor != null) {
      await monitor.stop();
    }
  }

  @override
  Future<void> stopAllMonitoring() async {
    final futures = _monitors.values.map((m) => m.stop());
    await Future.wait(futures);
    _monitors.clear();
  }

  @override
  bool isMonitoring(String path) {
    return _monitors.containsKey(path);
  }

  @override
  List<String> get monitoredPaths => _monitors.keys.toList();

  @override
  void setEventFilter(bool Function(FileMonitorEvent)? filter) {
    // Event filter functionality removed
  }

  @override
  Map<String, dynamic> getMonitoringStats() {
    return {
      'monitored_paths': monitoredPaths.length,
      'total_events': 0, // Simplified - event tracking removed
      'active_monitors': _monitors.length,
    };
  }

  @override
  Future<bool> isPathAccessible(String path) async {
    try {
      final entity = File(path);
      return await entity.exists();
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> validatePath(String path) async {
    try {
      final entity = Directory(path);
      return await entity.exists();
    } catch (e) {
      return false;
    }
  }

  @override
  void dispose() {
    stopAllMonitoring();
    _globalController.close();
  }
}

class FileMonitor {
  final String path;
  final StreamController<FileMonitorEvent> _controller;
  final StreamController<FileMonitorEvent> _globalController;
  final String? projectId;
  StreamSubscription<FileSystemEvent>? _subscription;
  bool _isRunning = false;

  FileMonitor(
    this.path,
    this._controller, 
    this._globalController,
    this.projectId,
  );

  Future<void> start() async {
    if (_isRunning) return;

    try {
      final directory = Directory(path);
      if (!await directory.exists()) {
        throw Exception('Directory does not exist: $path');
      }

      // Lightweight monitoring - only watch for specific events
      _subscription = directory.watch(
        recursive: false, // Don't watch recursively to reduce event spam
        events: FileSystemEvent.modify | FileSystemEvent.move | FileSystemEvent.delete, // Only important events
      ).listen(
        _handleFileSystemEventThrottled, // Use throttled handler
        onError: _handleError,
      );

      _isRunning = true;
    } catch (e) {
      _handleError(e);
    }
  }

  Future<void> stop() async {
    if (!_isRunning) return;

    _throttleTimer?.cancel();
    _throttleTimer = null;
    await _subscription?.cancel();
    _subscription = null;
    _isRunning = false;
  }

  Timer? _throttleTimer;
  static const Duration _throttleDuration = Duration(milliseconds: 500);

  void _handleFileSystemEventThrottled(FileSystemEvent event) {
    // Cancel existing timer
    _throttleTimer?.cancel();
    
    // Set new timer to process events after throttle duration
    _throttleTimer = Timer(_throttleDuration, () {
      _handleFileSystemEvent(event);
    });
  }

  void _handleFileSystemEvent(FileSystemEvent event) {
    final monitorEvent = _convertToFileMonitorEvent(event);
    if (monitorEvent != null) {
      _controller.add(monitorEvent);
      _globalController.add(monitorEvent);
    }
  }

  void _handleError(dynamic error) {
    final monitorEvent = FileMonitorEvent(
      type: FileSystemEventType.error,
      path: path,
      timestamp: DateTime.now(),
      projectId: projectId,
      error: error.toString(),
    );
    _controller.add(monitorEvent);
    _globalController.add(monitorEvent);
  }

  FileMonitorEvent? _convertToFileMonitorEvent(FileSystemEvent event) {
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
        return null;
    }

    return FileMonitorEvent(
      path: event.path,
      type: type,
      timestamp: DateTime.now(),
      projectId: projectId,
      destinationPath: event is FileSystemMoveEvent ? event.destination : null,
    );
  }

  bool get isActive => _isRunning;
}