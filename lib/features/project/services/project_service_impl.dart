import 'dart:io';
import 'package:path/path.dart' as path;
import '../../../core/services/project_service.dart';
import '../../../shared/models/project.dart';

/// Реализация ProjectService с улучшенной логикой проверки доступности
class ProjectServiceImpl extends ProjectService {
  static const Duration _defaultFileCheckInterval = Duration(seconds: 30);

  /// Проверить доступность файла проекта с расширенной диагностикой
  @override
  Future<bool> isProjectAccessible(Project project) async {
    try {
      if (project.isFolderProject) {
        return await _checkFolderProjectAccessibility(project);
      } else {
        return await _checkFileProjectAccessibility(project);
      }
    } catch (e) {
      return false;
    }
  }

  /// Проверить доступность файлового проекта
  Future<bool> _checkFileProjectAccessibility(Project project) async {
    if (project.filePath.isEmpty) {
      return false;
    }

    final file = File(project.filePath);
    
    // Проверяем существование файла
    if (!await file.exists()) {
      return false;
    }

    // Проверяем, что это действительно файл, а не директория
    final stat = await file.stat();
    if (stat.type == FileSystemEntityType.directory) {
      return false;
    }

    // Проверяем права на чтение
    try {
      await file.openRead().first;
    } catch (e) {
      if (e is FileSystemException) {
        // Проверяем конкретные ошибки доступа
        if (e.osError?.errorCode == 5) { // Access denied
          return false;
        }
        if (e.osError?.errorCode == 2) { // File not found
          return false;
        }
        if (e.osError?.errorCode == 32) { // File in use
          return false;
        }
      }
      return false;
    }

    // Проверяем права на запись (для сохранения проекта)
    try {
      // Пытаемся открыть файл для записи
      final randomAccessFile = await file.open(mode: FileMode.append);
      await randomAccessFile.close();
    } catch (e) {
      // Если не можем записать, но можем читать - проект доступен только для чтения
      // Возвращаем true, но в будущем можно добавить статус "только для чтения"
      if (e is FileSystemException && e.osError?.errorCode == 5) {
        // Access denied для записи, но чтение работает
        return true;
      }
      return false;
    }

    // Проверяем, что файл не заблокирован другим процессом
    try {
      final content = await file.readAsString();
      // Базовая проверка валидности JSON
      if (content.trim().startsWith('{') && content.trim().endsWith('}')) {
        return true;
      }
    } catch (e) {
      // Файл существует, но не может быть прочитан (возможно, заблокирован)
      return false;
    }

    return true;
  }

  /// Проверить доступность папочного проекта
  Future<bool> _checkFolderProjectAccessibility(Project project) async {
    if (project.directory.isEmpty) {
      return false;
    }

    final directory = Directory(project.directory);
    
    // Проверяем существование директории
    if (!await directory.exists()) {
      return false;
    }

    // Проверяем, что это действительно директория
    final stat = await directory.stat();
    if (stat.type != FileSystemEntityType.directory) {
      return false;
    }

    // Проверяем права на чтение
    try {
      await directory.list().first;
    } catch (e) {
      if (e is FileSystemException) {
        if (e.osError?.errorCode == 5) { // Access denied
          return false;
        }
      }
      return false;
    }

    // Проверяем права на запись
    try {
      final testFile = File(path.join(project.directory, '.novaspec_access_test'));
      await testFile.writeAsString('test');
      await testFile.delete();
    } catch (e) {
      if (e is FileSystemException && e.osError?.errorCode == 5) {
        // Access denied для записи
        return false;
      }
      return false;
    }

    return true;
  }

  /// Получить детальную информацию о доступности проекта
  Future<Map<String, dynamic>> getProjectAccessibilityDetails(Project project) async {
    final details = <String, dynamic>{
      'isAccessible': false,
      'type': project.isFolderProject ? 'folder' : 'file',
      'path': project.isFolderProject ? project.directory : project.filePath,
      'errors': <String>[],
      'warnings': <String>[],
      'canRead': false,
      'canWrite': false,
    };

    try {
      if (project.isFolderProject) {
        await _analyzeFolderAccessibility(project, details);
      } else {
        await _analyzeFileAccessibility(project, details);
      }
    } catch (e) {
      details['errors'].add('Ошибка анализа доступности: $e');
    }

    return details;
  }

  /// Проанализировать доступность папочного проекта
  Future<void> _analyzeFolderAccessibility(Project project, Map<String, dynamic> details) async {
    final directory = Directory(project.directory);
    
    // Проверяем существование
    if (!await directory.exists()) {
      details['errors'].add('Директория проекта не существует');
      return;
    }

    // Проверяем тип
    final stat = await directory.stat();
    if (stat.type != FileSystemEntityType.directory) {
      details['errors'].add('Указанный путь не является директорией');
      return;
    }

    // Проверяем чтение
    try {
      await directory.list().first;
      details['canRead'] = true;
    } catch (e) {
      details['errors'].add('Нет прав на чтение директории: $e');
    }

    // Проверяем запись
    try {
      final testFile = File(path.join(project.directory, '.novaspec_access_test'));
      await testFile.writeAsString('test');
      await testFile.delete();
      details['canWrite'] = true;
    } catch (e) {
      details['errors'].add('Нет прав на запись в директорию: $e');
    }

    // Проверяем сетевые пути
    if (isNetworkPath(project.directory)) {
      details['warnings'].add('Сетевые пути могут иметь ограничения производительности');
    }

    details['isAccessible'] = details['canRead'] && details['canWrite'];
  }

  /// Проанализировать доступность файлового проекта
  Future<void> _analyzeFileAccessibility(Project project, Map<String, dynamic> details) async {
    final file = File(project.filePath);
    
    // Проверяем существование
    if (!await file.exists()) {
      details['errors'].add('Файл проекта не существует');
      return;
    }

    // Проверяем тип
    final stat = await file.stat();
    if (stat.type != FileSystemEntityType.file) {
      details['errors'].add('Указанный путь не является файлом');
      return;
    }

    // Проверяем чтение
    try {
      await file.openRead().first;
      details['canRead'] = true;
    } catch (e) {
      details['errors'].add('Нет прав на чтение файла: $e');
    }

    // Проверяем запись
    try {
      final randomAccessFile = await file.open(mode: FileMode.append);
      await randomAccessFile.close();
      details['canWrite'] = true;
    } catch (e) {
      details['warnings'].add('Нет прав на запись файла (только чтение): $e');
    }

    // Проверяем валидность содержимого
    try {
      final content = await file.readAsString();
      if (content.trim().isEmpty) {
        details['warnings'].add('Файл проекта пуст');
      } else if (!(content.trim().startsWith('{') && content.trim().endsWith('}'))) {
        details['warnings'].add('Файл проекта может иметь неверный формат');
      }
    } catch (e) {
      details['errors'].add('Ошибка чтения содержимого файла: $e');
    }

    // Проверяем размер файла
    if (stat.size > 50 * 1024 * 1024) { // 50MB
      details['warnings'].add('Файл проекта очень большой (${stat.size} bytes)');
    }

    // Проверяем сетевые пути
    if (isNetworkPath(project.filePath)) {
      details['warnings'].add('Сетевые пути могут иметь ограничения производительности');
    }

    details['isAccessible'] = details['canRead'];
  }

  /// Проверить, является ли путь сетевым
  @override
  bool isNetworkPath(String path) {
    // Windows network paths: \\server\share or //server/share
    if (path.startsWith('\\\\') || path.startsWith('//')) {
      return true;
    }
    
    // Unix network paths: smb://, nfs://, etc.
    if (path.contains('://') && !path.startsWith('file://')) {
      return true;
    }
    
    return false;
  }

  /// Получить рекомендуемый интервал проверки для файлового проекта
  Duration getRecommendedCheckInterval(Project project) {
    if (project.isFolderProject) {
      return Duration.zero; // Не нужно для папочных проектов
    }

    // Для файлов на сетевых дисках увеличиваем интервал
    if (isNetworkPath(project.filePath)) {
      return const Duration(minutes: 1);
    }

    return _defaultFileCheckInterval;
  }

  /// Проверить, нужно ли показывать уведомление о недоступности
  bool shouldShowAccessibilityNotification(Project project, bool wasAccessible, bool isAccessible) {
    // Не показываем уведомления для папочных проектов
    if (project.isFolderProject) {
      return false;
    }

    // Показываем уведомление только если проект был доступен и стал недоступен
    return wasAccessible && !isAccessible;
  }
}