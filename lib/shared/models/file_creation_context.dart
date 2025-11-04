import 'dart:io';

class FileCreationContext {
  final String fileName;
  final String currentDirectory;
  final String projectRoot;
  final String fullPath;
  final DateTime timestamp;

  const FileCreationContext({
    required this.fileName,
    required this.currentDirectory,
    required this.projectRoot,
    required this.fullPath,
    required this.timestamp,
  });

  factory FileCreationContext.create({
    required String fileName,
    required String currentDirectory,
    required String projectRoot,
  }) {
    // Нормализуем имя файла
    final normalizedName = _normalizeFileName(fileName);
    
    // Определяем целевую директорию
    final targetDirectory = currentDirectory.isNotEmpty ? currentDirectory : projectRoot;
    
    // Строим полный путь
    final fullPath = '$targetDirectory${Platform.pathSeparator}$normalizedName';
    
    return FileCreationContext(
      fileName: normalizedName,
      currentDirectory: targetDirectory,
      projectRoot: projectRoot,
      fullPath: fullPath,
      timestamp: DateTime.now(),
    );
  }

  // Валидация имени файла
  bool get isValid => _validateFileName();
  String? get validationError => _getValidationError();

  bool _validateFileName() {
    if (fileName.trim().isEmpty) return false;
    if (fileName.length > 255) return false;
    
    // Проверка на недопустимые символы
    final invalidChars = RegExp(r'[<>:"|?*\\/]');
    if (invalidChars.hasMatch(fileName)) return false;
    
    // Проверка на зарезервированные имена (Windows)
    final reservedNames = [
      'CON', 'PRN', 'AUX', 'NUL',
      'COM1', 'COM2', 'COM3', 'COM4', 'COM5', 'COM6', 'COM7', 'COM8', 'COM9',
      'LPT1', 'LPT2', 'LPT3', 'LPT4', 'LPT5', 'LPT6', 'LPT7', 'LPT8', 'LPT9',
    ];
    
    final nameWithoutExtension = fileName.contains('.') 
        ? fileName.substring(0, fileName.indexOf('.'))
        : fileName;
    
    if (reservedNames.contains(nameWithoutExtension.toUpperCase())) return false;
    
    return true;
  }

  String? _getValidationError() {
    if (fileName.trim().isEmpty) {
      return 'File name cannot be empty';
    }
    
    if (fileName.length > 255) {
      return 'File name is too long (max 255 characters)';
    }
    
    final invalidChars = RegExp(r'[<>:"|?*\\/]');
    if (invalidChars.hasMatch(fileName)) {
      return 'File name contains invalid characters: < > : " | ? * \\ /';
    }
    
    final reservedNames = [
      'CON', 'PRN', 'AUX', 'NUL',
      'COM1', 'COM2', 'COM3', 'COM4', 'COM5', 'COM6', 'COM7', 'COM8', 'COM9',
      'LPT1', 'LPT2', 'LPT3', 'LPT4', 'LPT5', 'LPT6', 'LPT7', 'LPT8', 'LPT9',
    ];
    
    final nameWithoutExtension = fileName.contains('.') 
        ? fileName.substring(0, fileName.indexOf('.'))
        : fileName;
    
    if (reservedNames.contains(nameWithoutExtension.toUpperCase())) {
      return 'File name cannot be a reserved name: $nameWithoutExtension';
    }
    
    return null;
  }

  static String _normalizeFileName(String fileName) {
    // Удаляем лишние пробелы
    String normalized = fileName.trim();
    
    // Заменяем недопустимые символы на подчеркивания
    normalized = normalized.replaceAll(RegExp(r'[<>:"|?*\\/]'), '_');
    
    return normalized;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FileCreationContext &&
        other.fileName == fileName &&
        other.currentDirectory == currentDirectory &&
        other.projectRoot == projectRoot &&
        other.fullPath == fullPath;
  }

  @override
  int get hashCode {
    return fileName.hashCode ^
        currentDirectory.hashCode ^
        projectRoot.hashCode ^
        fullPath.hashCode;
  }

  @override
  String toString() {
    return 'FileCreationContext('
        'fileName: $fileName, '
        'currentDirectory: $currentDirectory, '
        'projectRoot: $projectRoot, '
        'fullPath: $fullPath, '
        'timestamp: $timestamp)';
  }
}