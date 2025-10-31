import 'dart:async';
import '../../shared/models/file_monitor_event.dart';

abstract class FileMonitorService {
  /// Stream событий мониторинга файловой системы
  Stream<FileMonitorEvent> get fileEvents;

  /// Начать мониторинг директории
  Future<void> startMonitoring(String path, {String? projectId});

  /// Остановить мониторинг директории
  Future<void> stopMonitoring(String path);

  /// Остановить все мониторинги
  Future<void> stopAllMonitoring();

  /// Проверить, активен ли мониторинг для пути
  bool isMonitoring(String path);

  /// Получить список всех отслеживаемых путей
  List<String> get monitoredPaths;

  /// Установить фильтр событий (опционально)
  void setEventFilter(bool Function(FileMonitorEvent)? filter);

  /// Получить статистику мониторинга
  Map<String, dynamic> getMonitoringStats();

  /// Проверить доступность пути
  Future<bool> isPathAccessible(String path);

  /// Валидировать путь для мониторинга
  Future<bool> validatePath(String path);

  /// Dispose сервиса
  void dispose();
}