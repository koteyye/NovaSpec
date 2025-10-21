import 'dart:async';
import 'dart:io';

class FileMonitorService {
  final Map<String, FileMonitor> _monitors = {};
  final Map<String, StreamController<FileChangeEvent>> _controllers = {};
  
  // Monitor a file for changes
  Stream<FileChangeEvent> monitorFile(String filePath) {
    if (_controllers.containsKey(filePath)) {
      return _controllers[filePath]!.stream;
    }

    final controller = StreamController<FileChangeEvent>.broadcast();
    _controllers[filePath] = controller;

    final monitor = FileMonitor(filePath, controller);
    _monitors[filePath] = monitor;
    monitor.start();

    return controller.stream;
  }

  // Stop monitoring a file
  void stopMonitoring(String filePath) {
    final monitor = _monitors.remove(filePath);
    monitor?.stop();

    final controller = _controllers.remove(filePath);
    controller?.close();
  }

  // Stop all monitoring
  void stopAllMonitoring() {
    for (final monitor in _monitors.values) {
      monitor.stop();
    }
    _monitors.clear();

    for (final controller in _controllers.values) {
      controller.close();
    }
    _controllers.clear();
  }

  // Check if file is currently monitored
  bool isMonitoring(String filePath) {
    return _monitors.containsKey(filePath);
  }

  // Get list of monitored files
  List<String> get monitoredFiles => _monitors.keys.toList();
}

class FileMonitor {
  final String filePath;
  final StreamController<FileChangeEvent> controller;
  Timer? _timer;
  DateTime? _lastModified;
  int? _lastSize;
  bool _exists = false;

  FileMonitor(this.filePath, this.controller);

  void start() {
    _checkFile(); // Initial check
    _timer = Timer.periodic(const Duration(seconds: 5), (_) => _checkFile());
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  void _checkFile() {
    try {
      final file = File(filePath);
      final exists = file.existsSync();
      final modified = exists ? file.lastModifiedSync() : null;
      final size = exists ? file.lengthSync() : null;

      // Check if file existence changed
      if (_exists != exists) {
        _exists = exists;
        if (exists) {
          controller.add(FileChangeEvent(filePath, FileChangeType.created, modified, size));
        } else {
          controller.add(FileChangeEvent(filePath, FileChangeType.deleted, null, null));
        }
        return;
      }

      if (!exists) return;

      // Check if file was modified
      if (_lastModified != null && modified != null && modified.isAfter(_lastModified!)) {
        controller.add(FileChangeEvent(filePath, FileChangeType.modified, modified, size));
      }

      // Check if file size changed (another indicator of modification)
      if (_lastSize != null && size != null && size != _lastSize) {
        controller.add(FileChangeEvent(filePath, FileChangeType.modified, modified, size));
      }

      _lastModified = modified;
      _lastSize = size;
    } catch (e) {
      // If we can't access the file, report it as inaccessible
      if (_exists) {
        controller.add(FileChangeEvent(filePath, FileChangeType.inaccessible, null, null));
        _exists = false;
      }
    }
  }
}

class FileChangeEvent {
  final String filePath;
  final FileChangeType changeType;
  final DateTime? timestamp;
  final int? size;

  const FileChangeEvent(
    this.filePath,
    this.changeType,
    this.timestamp,
    this.size,
  );

  @override
  String toString() {
    return 'FileChangeEvent(filePath: $filePath, changeType: $changeType, timestamp: $timestamp)';
  }
}

enum FileChangeType {
  created,
  modified,
  deleted,
  inaccessible,
}