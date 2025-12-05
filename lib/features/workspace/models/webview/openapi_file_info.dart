/// Модель информации об OpenAPI файле
class OpenAPIFileInfo {
  final String filePath;
  final String fileName;
  final String fileType; // 'yaml' or 'json'
  final int fileSize;
  final DateTime lastModified;
  final String? swaggerUrl;
  
  OpenAPIFileInfo({
    required this.filePath,
    required this.fileName,
    required this.fileType,
    required this.fileSize,
    required this.lastModified,
    this.swaggerUrl,
  });
  
  /// Создает информацию о файле из пути
  factory OpenAPIFileInfo.fromPath(String filePath, {String? swaggerUrl}) {
    final file = filePath.toLowerCase();
    String fileType;
    
    if (file.endsWith('.yaml') || file.endsWith('.yml')) {
      fileType = 'yaml';
    } else if (file.endsWith('.json')) {
      fileType = 'json';
    } else {
      throw ArgumentError('Unsupported file type. Only .yaml, .yml, and .json files are supported.');
    }
    
    final fileName = filePath.split('/').last;
    
    return OpenAPIFileInfo(
      filePath: filePath,
      fileName: fileName,
      fileType: fileType,
      fileSize: 0, // Будет заполнено при чтении файла
      lastModified: DateTime.now(), // Будет обновлено при чтении файла
      swaggerUrl: swaggerUrl,
    );
  }
  
  /// Валидирует информацию о файле
  bool isValid() {
    // Проверяем расширение файла
    if (!['yaml', 'json'].contains(fileType)) {
      return false;
    }
    
    // Проверяем что путь не пустой
    if (filePath.isEmpty) {
      return false;
    }
    
    // Проверяем размер файла
    if (fileSize < 0) {
      return false;
    }
    
    return true;
  }
  
  /// Проверяет является ли файл YAML
  bool get isYaml => fileType == 'yaml';
  
  /// Проверяет является ли файл JSON
  bool get isJson => fileType == 'json';
  
  /// Возвращает расширение файла
  String get extension => isYaml ? '.yaml' : '.json';
  
  /// Создает копию с обновленным swaggerUrl
  OpenAPIFileInfo withSwaggerUrl(String url) {
    return OpenAPIFileInfo(
      filePath: filePath,
      fileName: fileName,
      fileType: fileType,
      fileSize: fileSize,
      lastModified: lastModified,
      swaggerUrl: url,
    );
  }
  
  /// Создает копию с обновленным размером файла
  OpenAPIFileInfo withFileSize(int size) {
    return OpenAPIFileInfo(
      filePath: filePath,
      fileName: fileName,
      fileType: fileType,
      fileSize: size,
      lastModified: lastModified,
      swaggerUrl: swaggerUrl,
    );
  }
  
  /// Создает копию с обновленным временем модификации
  OpenAPIFileInfo withLastModified(DateTime modified) {
    return OpenAPIFileInfo(
      filePath: filePath,
      fileName: fileName,
      fileType: fileType,
      fileSize: fileSize,
      lastModified: modified,
      swaggerUrl: swaggerUrl,
    );
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OpenAPIFileInfo &&
           other.filePath == filePath &&
           other.fileName == fileName &&
           other.fileType == fileType &&
           other.fileSize == fileSize &&
           other.swaggerUrl == swaggerUrl;
  }
  
  @override
  int get hashCode {
    return filePath.hashCode ^
           fileName.hashCode ^
           fileType.hashCode ^
           fileSize.hashCode ^
           swaggerUrl.hashCode;
  }
  
  @override
  String toString() {
    return 'OpenAPIFileInfo(filePath: $filePath, fileName: $fileName, fileType: $fileType, fileSize: $fileSize)';
  }
}