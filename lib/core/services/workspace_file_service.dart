import 'dart:io';
import 'package:path/path.dart' as path;
import '../../features/workspace/models/file_explorer_node.dart';
import '../../features/workspace/models/file_operation.dart';
import 'clipboard_service.dart';
import '../../shared/models/file_creation_context.dart';
import '../../shared/models/file_creation_result.dart';

class WorkspaceFileService {
  final ClipboardService _clipboardService;
  String _currentDirectory = '';

  WorkspaceFileService({required ClipboardService clipboardService})
    : _clipboardService = clipboardService;

  Future<void> initialize() async {
    // Инициализируем с пустой директорией, будет установлена при открытии проекта
    _currentDirectory = '';
  }

  void setCurrentProject(String projectPath) {
    _currentDirectory = projectPath;
  }

  String get currentDirectory => _currentDirectory;

  // Directory operations
  Future<List<FileExplorerNode>> getDirectoryContents(String dirPath) async {
    try {
      final directory = Directory(
        dirPath.isEmpty ? _currentDirectory : dirPath,
      );

      if (!await directory.exists()) {
        throw Exception('Directory does not exist: $dirPath');
      }

      final entities = await directory.list().toList();
      final nodes = <FileExplorerNode>[];

      for (final entity in entities) {
        final name = path.basename(entity.path);
        final isDirectory = entity is Directory;
        await entity.stat();

        nodes.add(
          FileExplorerNode(
            id: entity.path,
            name: name,
            path: entity.path,
            type: isDirectory ? FileNodeType.folder : FileNodeType.file,
            children: [],
            isExpanded: false,
            isRenaming: false,
          ),
        );
      }

      // Sort: directories first, then files, both alphabetically
      nodes.sort((a, b) {
        if (a.isFolder && !b.isFolder) return -1;
        if (!a.isFolder && b.isFolder) return 1;
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      });

      return nodes;
    } catch (e) {
      throw Exception('Failed to read directory: $e');
    }
  }

  // File operations
  Future<void> createDirectory(String dirPath) async {
    try {
      final directory = Directory(dirPath);
      await directory.create(recursive: true);
    } catch (e) {
      throw Exception('Failed to create directory: $e');
    }
  }

  Future<void> createFile(String filePath) async {
    try {
      final file = File(filePath);
      await file.create(recursive: true);
    } catch (e) {
      throw Exception('Failed to create file: $e');
    }
  }

  Future<void> delete(String entityPath, {required bool isFolder}) async {
    try {
      if (isFolder) {
        final directory = Directory(entityPath);
        await directory.delete(recursive: true);
      } else {
        final file = File(entityPath);
        await file.delete();
      }
    } catch (e) {
      throw Exception('Failed to delete: $e');
    }
  }

  Future<void> rename(String oldPath, String newPath) async {
    try {
      if (Platform.isWindows) {
        // Windows doesn't allow renaming if newPath exists
        final newEntity = File(newPath);
        if (await newEntity.exists()) {
          throw Exception('Destination already exists: $newPath');
        }
      }

      final oldEntity = File(oldPath);
      await oldEntity.rename(newPath);
    } catch (e) {
      throw Exception('Failed to rename: $e');
    }
  }

  Future<void> copy(String sourcePath, String destinationPath) async {
    try {
      if (await Directory(sourcePath).exists()) {
        await _copyDirectory(sourcePath, destinationPath);
      } else {
        await _copyFile(sourcePath, destinationPath);
      }
    } catch (e) {
      throw Exception('Failed to copy: $e');
    }
  }

  Future<void> move(String sourcePath, String destinationPath) async {
    try {
      await copy(sourcePath, destinationPath);
      await delete(sourcePath, isFolder: await Directory(sourcePath).exists());
    } catch (e) {
      throw Exception('Failed to move: $e');
    }
  }

  Future<void> _copyFile(String sourcePath, String destinationPath) async {
    final sourceFile = File(sourcePath);
    await sourceFile.copy(destinationPath);
  }

  Future<void> _copyDirectory(String sourcePath, String destinationPath) async {
    final sourceDir = Directory(sourcePath);
    final destinationDir = Directory(destinationPath);

    if (!await destinationDir.exists()) {
      await destinationDir.create(recursive: true);
    }

    await for (final entity in sourceDir.list()) {
      final newPath = path.join(destinationPath, path.basename(entity.path));

      if (entity is Directory) {
        await _copyDirectory(entity.path, newPath);
      } else {
        await _copyFile(entity.path, newPath);
      }
    }
  }

  // Search functionality
  Future<List<FileExplorerNode>> search(String dirPath, String query) async {
    try {
      final results = <FileExplorerNode>[];
      final directory = Directory(
        dirPath.isEmpty ? _currentDirectory : dirPath,
      );

      await _searchRecursive(directory, query, results);

      return results;
    } catch (e) {
      throw Exception('Search failed: $e');
    }
  }

  Future<void> _searchRecursive(
    Directory directory,
    String query,
    List<FileExplorerNode> results,
  ) async {
    try {
      await for (final entity in directory.list()) {
        final name = path.basename(entity.path);

        if (name.toLowerCase().contains(query.toLowerCase())) {
          final isDirectory = entity is Directory;
          await entity.stat();

          results.add(
            FileExplorerNode(
              id: entity.path,
              name: name,
              path: entity.path,
              type: isDirectory ? FileNodeType.folder : FileNodeType.file,
              children: [],
              isExpanded: false,
              isRenaming: false,
            ),
          );
        }

        if (entity is Directory) {
          await _searchRecursive(entity, query, results);
        }
      }
    } catch (e) {
      // Skip directories we can't access
    }
  }

  // Clipboard operations
  Future<void> copyToClipboard(List<String> paths) async {
    await _clipboardService.copy(paths);
  }

  Future<void> cutToClipboard(List<String> paths) async {
    await _clipboardService.cut(paths);
  }

  Future<void> pasteFromClipboard(String destinationPath) async {
    final clipboardData = await _clipboardService.getClipboardData();

    if (clipboardData == null) return;

    for (final sourcePath in clipboardData.paths) {
      final fileName = path.basename(sourcePath);
      final destination = path.join(destinationPath, fileName);

      try {
        if (clipboardData.isCut) {
          await move(sourcePath, destination);
        } else {
          await copy(sourcePath, destination);
        }
      } catch (e) {
        // Continue with other files if one fails
        continue;
      }
    }

    if (clipboardData.isCut) {
      await _clipboardService.clear();
    }
  }

  // File operation execution
  Future<void> performOperation(FileOperation operation) async {
    switch (operation.type) {
      case FileOperationType.create:
        if (operation.newName != null) {
          final fullPath = path.join(operation.sourcePath, operation.newName!);
          await createFile(fullPath);
        }
        break;

      case FileOperationType.copy:
        if (operation.destinationPath != null) {
          await copy(operation.sourcePath, operation.destinationPath!);
        }
        break;

      case FileOperationType.move:
        if (operation.destinationPath != null) {
          await move(operation.sourcePath, operation.destinationPath!);
        }
        break;

      case FileOperationType.delete:
        await delete(operation.sourcePath, isFolder: false);
        break;

      case FileOperationType.rename:
        if (operation.newName != null) {
          final newPath = path.join(
            path.dirname(operation.sourcePath),
            operation.newName!,
          );
          await rename(operation.sourcePath, newPath);
        }
        break;
    }
  }

  // Path utilities
  String getParentDirectory(String dirPath) {
    return path.dirname(dirPath);
  }

  String joinPath(String base, String relative) {
    return path.join(base, relative);
  }

  String getFileName(String filePath) {
    return path.basename(filePath);
  }

  String getFileExtension(String filePath) {
    final ext = path.extension(filePath);
    return ext.isEmpty ? '' : ext.substring(1); // Убираем точку из расширения
  }

  bool isAbsolutePath(String pathStr) {
    return path.isAbsolute(pathStr);
  }

  // File info
  Future<bool> exists(String entityPath) async {
    return await File(entityPath).exists() ||
        await Directory(entityPath).exists();
  }

  Future<bool> isDirectory(String entityPath) async {
    return await Directory(entityPath).exists();
  }

  Future<int> getFileSize(String filePath) async {
    try {
      final file = File(filePath);
      final stat = await file.stat();
      return stat.size;
    } catch (e) {
      return 0;
    }
  }

  Future<DateTime> getLastModified(String entityPath) async {
    try {
      final file = File(entityPath);
      final stat = await file.stat();
      return stat.modified;
    } catch (e) {
      return DateTime.now();
    }
  }

  // File content operations
  Future<String> readFile(String filePath) async {
    try {
      final file = File(filePath);
      return await file.readAsString();
    } catch (e) {
      throw Exception('Failed to read file: $e');
    }
  }

  Future<void> writeFile(String filePath, String content) async {
    try {
      final file = File(filePath);
      await file.writeAsString(content);
    } catch (e) {
      throw Exception('Failed to write file: $e');
    }
  }

  // File type detection
  String getFileType(String fileName) {
    final extension = getFileExtension(fileName).toLowerCase();

    // Programming languages
    const programmingLanguages = {
      'dart': 'dart',
      'js': 'javascript',
      'mjs': 'javascript',
      'cjs': 'javascript',
      'ts': 'typescript',
      'mts': 'typescript',
      'cts': 'typescript',
      'py': 'python',
      'java': 'java',
      'cpp': 'cpp',
      'cc': 'cpp',
      'cxx': 'cpp',
      'c': 'c',
      'h': 'c',
      'hpp': 'cpp',
      'cs': 'csharp',
      'php': 'php',
      'rb': 'ruby',
      'go': 'go',
      'rs': 'rust',
      'swift': 'swift',
      'kt': 'kotlin',
      'scala': 'scala',
      'r': 'r',
      'sql': 'sql',
      'sh': 'shell',
      'bash': 'shell',
      'zsh': 'shell',
      'fish': 'shell',
      'ps1': 'powershell',
      'bat': 'batch',
      'cmd': 'batch',
    };

    // Web technologies
    const webTech = {
      'html': 'html',
      'htm': 'html',
      'css': 'css',
      'scss': 'scss',
      'sass': 'scss',
      'less': 'less',
      'vue': 'vue',
      'jsx': 'jsx',
      'tsx': 'tsx',
    };

    // Data formats
    const dataFormats = {
      'json': 'json',
      'xml': 'xml',
      'yaml': 'yaml',
      'yml': 'yaml',
      'toml': 'toml',
      'ini': 'ini',
      'csv': 'csv',
      'tsv': 'tsv',
    };

    // Documentation
    const documentation = {
      'md': 'markdown',
      'markdown': 'markdown',
      'txt': 'text',
      'rst': 'rst',
      'adoc': 'asciidoc',
    };

    // Configuration
    const configuration = {
      'config': 'config',
      'conf': 'config',
      'env': 'env',
      'dockerfile': 'dockerfile',
      'gitignore': 'gitignore',
      'eslintrc': 'eslint',
      'prettierrc': 'prettier',
      'babelrc': 'babel',
    };

    // Check each category
    if (programmingLanguages.containsKey(extension)) {
      return programmingLanguages[extension]!;
    }

    if (webTech.containsKey(extension)) {
      return webTech[extension]!;
    }

    if (dataFormats.containsKey(extension)) {
      return dataFormats[extension]!;
    }

    if (documentation.containsKey(extension)) {
      return documentation[extension]!;
    }

    if (configuration.containsKey(extension)) {
      return configuration[extension]!;
    }

    // Special files by name
    final baseFileName = getFileName(fileName).toLowerCase();
    if (baseFileName == 'dockerfile' ||
        baseFileName.startsWith('dockerfile.')) {
      return 'dockerfile';
    }
    if (baseFileName == 'makefile') {
      return 'makefile';
    }
    if (baseFileName == 'readme' || baseFileName.startsWith('readme.')) {
      return 'readme';
    }
    if (baseFileName == 'license' || baseFileName.startsWith('license.')) {
      return 'license';
    }
    if (baseFileName == 'changelog' || baseFileName.startsWith('changelog.')) {
      return 'changelog';
    }

    // API/Swagger files
    if (baseFileName.contains('swagger') || baseFileName.contains('openapi')) {
      return 'swagger';
    }

    // Media files
    const imageExtensions = {
      'png',
      'jpg',
      'jpeg',
      'gif',
      'bmp',
      'svg',
      'webp',
      'ico',
    };
    const audioExtensions = {'mp3', 'wav', 'ogg', 'flac', 'aac', 'm4a'};
    const videoExtensions = {'mp4', 'avi', 'mkv', 'mov', 'wmv', 'flv', 'webm'};

    if (imageExtensions.contains(extension)) return 'image';
    if (audioExtensions.contains(extension)) return 'audio';
    if (videoExtensions.contains(extension)) return 'video';

    // Documents
    const documentExtensions = {
      'pdf',
      'doc',
      'docx',
      'xls',
      'xlsx',
      'ppt',
      'pptx',
    };
    if (documentExtensions.contains(extension)) return 'document';

    // Archives
    const archiveExtensions = {'zip', 'rar', '7z', 'tar', 'gz', 'bz2'};
    if (archiveExtensions.contains(extension)) {
      return 'archive';
    }

    return 'unknown';
  }

  bool isBinaryFile(String fileName) {
    final extension = getFileExtension(fileName).toLowerCase();

    const binaryExtensions = {
      // Images
      'png', 'jpg', 'jpeg', 'gif', 'bmp', 'webp', 'ico',
      // Audio
      'mp3', 'wav', 'ogg', 'flac', 'aac', 'm4a',
      // Video
      'mp4', 'avi', 'mkv', 'mov', 'wmv', 'flv', 'webm',
      // Documents
      'pdf', 'doc', 'docx', 'xls', 'xlsx', 'ppt', 'pptx',
      // Archives
      'zip', 'rar', '7z', 'tar', 'gz', 'bz2',
      // Executables
      'exe', 'dll', 'so', 'dylib', 'app', 'deb', 'rpm',
      // Fonts
      'ttf', 'otf', 'woff', 'woff2', 'eot',
      // Other binary formats
      'iso', 'dmg', 'img', 'bin',
    };

    return binaryExtensions.contains(extension);
  }

  String getFileIcon(String fileName) {
    final fileType = getFileType(fileName);

    switch (fileType) {
      // Programming languages
      case 'dart':
        return 'code';
      case 'javascript':
      case 'jsx':
        return 'javascript';
      case 'typescript':
      case 'tsx':
        return 'typescript';
      case 'python':
        return 'psychology';
      case 'java':
        return 'coffee';
      case 'cpp':
      case 'c':
        return 'memory';
      case 'csharp':
        return 'developer_board';
      case 'php':
        return 'web';
      case 'ruby':
        return 'diamond';
      case 'go':
        return 'rocket_launch';
      case 'rust':
        return 'construction';
      case 'swift':
        return 'flutter_dash';
      case 'kotlin':
        return 'android';
      case 'scala':
        return 'scatter_plot';
      case 'r':
        return 'bar_chart';

      // Web technologies
      case 'html':
        return 'web';
      case 'css':
        return 'palette';
      case 'scss':
      case 'sass':
      case 'less':
        return 'style';
      case 'vue':
        return 'view_quilt';

      // Data formats
      case 'json':
        return 'data_object';
      case 'xml':
        return 'code';
      case 'yaml':
      case 'yml':
        return 'description';
      case 'toml':
        return 'settings';
      case 'ini':
        return 'tune';
      case 'csv':
      case 'tsv':
        return 'table_chart';

      // Documentation
      case 'markdown':
      case 'md':
        return 'description';
      case 'text':
      case 'txt':
        return 'text_snippet';
      case 'rst':
        return 'menu_book';
      case 'asciidoc':
        return 'article';

      // Configuration
      case 'config':
      case 'conf':
        return 'settings';
      case 'env':
        return 'shield';
      case 'dockerfile':
        return 'sailing';
      case 'gitignore':
        return 'git';
      case 'eslint':
      case 'prettierrc':
      case 'babelrc':
        return 'rule';

      // Shell scripts
      case 'shell':
      case 'bash':
      case 'zsh':
      case 'fish':
        return 'terminal';
      case 'powershell':
        return 'terminal';
      case 'batch':
      case 'bat':
      case 'cmd':
        return 'computer';

      // Databases
      case 'sql':
        return 'storage';

      // Media files
      case 'image':
        return 'image';
      case 'audio':
        return 'audiotrack';
      case 'video':
        return 'videocam';

      // Documents
      case 'document':
        return 'description';

      // Archives
      case 'archive':
        return 'archive';

      // Special files (handled above)
      case 'makefile':
        return 'build';
      case 'readme':
        return 'menu_book';
      case 'license':
        return 'gavel';
      case 'changelog':
        return 'history';

      default:
        return 'insert_drive_file';
    }
  }

  // Новый метод для создания файла с контекстом
  Future<FileCreationResult> createFileWithContext(
    FileCreationContext context,
  ) async {
    try {
      // Валидация контекста
      if (!context.isValid) {
        return FileCreationResult.error(
          FileCreationErrorType.invalidFileName,
          context.validationError ?? 'Invalid file name',
        );
      }

      // Проверяем существование файла
      if (await File(context.fullPath).exists()) {
        return FileCreationResult.error(
          FileCreationErrorType.fileAlreadyExists,
          'File already exists: ${context.fileName}',
        );
      }

      // Создаем файл
      final file = File(context.fullPath);
      await file.writeAsString('');

      return FileCreationResult.success(context.fullPath);
    } catch (e) {
      // Определяем тип ошибки
      final String message = e.toString();

      final FileCreationErrorType errorType;
      if (e is FileSystemException) {
        if (e.message.contains('Permission denied')) {
          errorType = FileCreationErrorType.permissionDenied;
        } else if (e.message.contains('No space left')) {
          errorType = FileCreationErrorType.diskFull;
        } else if (e.message.contains('No such file or directory')) {
          errorType = FileCreationErrorType.directoryNotFound;
        } else {
          errorType = FileCreationErrorType.unknownError;
        }
      } else {
        errorType = FileCreationErrorType.unknownError;
      }

      return FileCreationResult.error(errorType, message);
    }
  }
}
