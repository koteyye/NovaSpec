import 'dart:io';
import 'package:path/path.dart' as path;

/// Сервис для работы с файловой системой
class FileService {
  /// Получить все файлы и папки в директории
  Future<List<FileSystemEntity>> scanDirectory(String directoryPath) async {
    try {
      final dir = Directory(directoryPath);
      if (!await dir.exists()) {
        return [];
      }

      final entities = await dir.list().toList();

      // Сортируем: сначала папки, потом файлы
      entities.sort((a, b) {
        final aIsDir = a is Directory;
        final bIsDir = b is Directory;

        if (aIsDir && !bIsDir) return -1;
        if (!aIsDir && bIsDir) return 1;

        return a.path.toLowerCase().compareTo(b.path.toLowerCase());
      });

      return entities;
    } catch (e) {
      return [];
    }
  }

  /// Получить все файлы рекурсивно
  Future<List<File>> scanDirectoryRecursive(
    String directoryPath, {
    List<String>? extensions,
    bool includeHidden = false,
  }) async {
    final files = <File>[];

    try {
      final dir = Directory(directoryPath);
      if (!await dir.exists()) {
        return files;
      }

      await for (final entity in dir.list(recursive: true)) {
        if (entity is File) {
          final fileName = path.basename(entity.path);

          // Пропускаем скрытые файлы если нужно
          if (!includeHidden && fileName.startsWith('.')) {
            continue;
          }

          // Фильтруем по расширениям если указано
          if (extensions != null && extensions.isNotEmpty) {
            final ext = path.extension(entity.path).toLowerCase();
            if (!extensions.contains(ext)) {
              continue;
            }
          }

          files.add(entity);
        }
      }
    } catch (e) {
      // Ignore errors
    }

    return files;
  }

  /// Прочитать файл как строку
  Future<String?> readFile(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        return null;
      }
      return await file.readAsString();
    } catch (e) {
      return null;
    }
  }

  /// Прочитать файл как байты
  Future<List<int>?> readFileBytes(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        return null;
      }
      return await file.readAsBytes();
    } catch (e) {
      return null;
    }
  }

  /// Записать строку в файл
  Future<bool> writeFile(String filePath, String content) async {
    try {
      final file = File(filePath);

      // Создаем родительские директории если нужно
      final dir = Directory(path.dirname(filePath));
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }

      await file.writeAsString(content);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Записать байты в файл
  Future<bool> writeFileBytes(String filePath, List<int> bytes) async {
    try {
      final file = File(filePath);

      // Создаем родительские директории если нужно
      final dir = Directory(path.dirname(filePath));
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }

      await file.writeAsBytes(bytes);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Проверить существование файла/папки
  Future<bool> exists(String path) async {
    try {
      final entity = FileSystemEntity.typeSync(path);
      return entity != FileSystemEntityType.notFound;
    } catch (e) {
      return false;
    }
  }

  /// Удалить файл
  Future<bool> deleteFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Удалить директорию
  Future<bool> deleteDirectory(String directoryPath, {bool recursive = false}) async {
    try {
      final dir = Directory(directoryPath);
      if (await dir.exists()) {
        await dir.delete(recursive: recursive);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Создать директорию
  Future<bool> createDirectory(String directoryPath, {bool recursive = true}) async {
    try {
      final dir = Directory(directoryPath);
      await dir.create(recursive: recursive);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Переименовать/переместить файл
  Future<bool> renameFile(String oldPath, String newPath) async {
    try {
      final file = File(oldPath);
      if (await file.exists()) {
        await file.rename(newPath);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Получить информацию о файле
  Future<FileStat?> getFileStat(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        return await file.stat();
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Получить размер файла в байтах
  Future<int?> getFileSize(String filePath) async {
    try {
      final stat = await getFileStat(filePath);
      return stat?.size;
    } catch (e) {
      return null;
    }
  }

  /// Получить расширение файла
  String getFileExtension(String filePath) {
    return path.extension(filePath).toLowerCase();
  }

  /// Получить имя файла без расширения
  String getFileNameWithoutExtension(String filePath) {
    return path.basenameWithoutExtension(filePath);
  }

  /// Получить имя файла с расширением
  String getFileName(String filePath) {
    return path.basename(filePath);
  }

  /// Получить путь к родительской директории
  String getParentDirectory(String filePath) {
    return path.dirname(filePath);
  }

  /// Объединить пути
  String joinPaths(String part1, String part2, [String? part3, String? part4]) {
    if (part4 != null) {
      return path.join(part1, part2, part3!, part4);
    } else if (part3 != null) {
      return path.join(part1, part2, part3);
    } else {
      return path.join(part1, part2);
    }
  }

  /// Получить относительный путь
  String getRelativePath(String from, String to) {
    return path.relative(to, from: from);
  }

  /// Проверить, является ли путь абсолютным
  bool isAbsolutePath(String filePath) {
    return path.isAbsolute(filePath);
  }

  /// Нормализовать путь
  String normalizePath(String filePath) {
    return path.normalize(filePath);
  }
}
