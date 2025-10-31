import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class FileIconService {
  static const Map<String, String> _fileIconMap = {
    // Code files
    '.dart': 'assets/images/file-icons/code.svg',
    '.js': 'assets/images/file-icons/javascript.svg',
    '.jsx': 'assets/images/file-icons/javascript.svg',
    '.ts': 'assets/images/file-icons/typescript.svg',
    '.tsx': 'assets/images/file-icons/typescript.svg',
    '.py': 'assets/images/file-icons/python.svg',
    '.java': 'assets/images/file-icons/code.svg',
    '.cpp': 'assets/images/file-icons/code.svg',
    '.c': 'assets/images/file-icons/code.svg',
    '.h': 'assets/images/file-icons/code.svg',
    '.cs': 'assets/images/file-icons/code.svg',
    '.php': 'assets/images/file-icons/code.svg',
    '.rb': 'assets/images/file-icons/code.svg',
    '.go': 'assets/images/file-icons/code.svg',
    '.rs': 'assets/images/file-icons/code.svg',
    '.swift': 'assets/images/file-icons/code.svg',
    '.kt': 'assets/images/file-icons/code.svg',
    '.scala': 'assets/images/file-icons/code.svg',
    '.r': 'assets/images/file-icons/code.svg',
    '.m': 'assets/images/file-icons/code.svg',
    '.sh': 'assets/images/file-icons/code.svg',
    '.bash': 'assets/images/file-icons/code.svg',
    '.zsh': 'assets/images/file-icons/code.svg',
    '.fish': 'assets/images/file-icons/code.svg',
    '.ps1': 'assets/images/file-icons/code.svg',
    '.bat': 'assets/images/file-icons/code.svg',
    '.cmd': 'assets/images/file-icons/code.svg',
    
    // Web files
    '.html': 'assets/images/file-icons/html.svg',
    '.htm': 'assets/images/file-icons/html.svg',
    '.css': 'assets/images/file-icons/css.svg',
    '.scss': 'assets/images/file-icons/css.svg',
    '.sass': 'assets/images/file-icons/css.svg',
    '.less': 'assets/images/file-icons/css.svg',
    
    // Data files
    '.json': 'assets/images/file-icons/json.svg',
    '.xml': 'assets/images/file-icons/json.svg',
    '.yaml': 'assets/images/file-icons/yaml.svg',
    '.yml': 'assets/images/file-icons/yaml.svg',
    '.toml': 'assets/images/file-icons/json.svg',
    '.ini': 'assets/images/file-icons/json.svg',
    '.cfg': 'assets/images/file-icons/json.svg',
    '.conf': 'assets/images/file-icons/json.svg',
    
    // Documentation
    '.md': 'assets/images/file-icons/markdown.svg',
    '.markdown': 'assets/images/file-icons/markdown.svg',
    '.txt': 'assets/images/file-icons/code.svg',
    '.rst': 'assets/images/file-icons/markdown.svg',
    '.adoc': 'assets/images/file-icons/markdown.svg',
    
    // Database
    '.sql': 'assets/images/file-icons/code.svg',
    '.db': 'assets/images/file-icons/json.svg',
    '.sqlite': 'assets/images/file-icons/json.svg',
    '.sqlite3': 'assets/images/file-icons/json.svg',
    
    // Config files
    '.env': 'assets/images/file-icons/json.svg',
    '.gitignore': 'assets/images/file-icons/code.svg',
    '.dockerfile': 'assets/images/file-icons/code.svg',
    'docker-compose.yml': 'assets/images/file-icons/yaml.svg',
    'docker-compose.yaml': 'assets/images/file-icons/yaml.svg',
    'package.json': 'assets/images/file-icons/json.svg',
    'pubspec.yaml': 'assets/images/file-icons/yaml.svg',
    'tsconfig.json': 'assets/images/file-icons/json.svg',
    'webpack.config.js': 'assets/images/file-icons/javascript.svg',
    
    // Media files
    '.mp3': 'assets/images/file-icons/audio.svg',
    '.wav': 'assets/images/file-icons/audio.svg',
    '.flac': 'assets/images/file-icons/audio.svg',
    '.aac': 'assets/images/file-icons/audio.svg',
    '.ogg': 'assets/images/file-icons/audio.svg',
    '.m4a': 'assets/images/file-icons/audio.svg',
    '.wma': 'assets/images/file-icons/audio.svg',
    
    '.mp4': 'assets/images/file-icons/image.svg',
    '.avi': 'assets/images/file-icons/image.svg',
    '.mkv': 'assets/images/file-icons/image.svg',
    '.mov': 'assets/images/file-icons/image.svg',
    '.wmv': 'assets/images/file-icons/image.svg',
    '.flv': 'assets/images/file-icons/image.svg',
    '.webm': 'assets/images/file-icons/image.svg',
    
    '.jpg': 'assets/images/file-icons/image.svg',
    '.jpeg': 'assets/images/file-icons/image.svg',
    '.png': 'assets/images/file-icons/image.svg',
    '.gif': 'assets/images/file-icons/image.svg',
    '.bmp': 'assets/images/file-icons/image.svg',
    '.svg': 'assets/images/file-icons/image.svg',
    '.webp': 'assets/images/file-icons/image.svg',
    '.ico': 'assets/images/file-icons/image.svg',
    
    // Archives
    '.zip': 'assets/images/file-icons/folder.svg',
    '.rar': 'assets/images/file-icons/folder.svg',
    '.7z': 'assets/images/file-icons/folder.svg',
    '.tar': 'assets/images/file-icons/folder.svg',
    '.gz': 'assets/images/file-icons/folder.svg',
    '.bz2': 'assets/images/file-icons/folder.svg',
    '.xz': 'assets/images/file-icons/folder.svg',
    
    // Documents
    '.pdf': 'assets/images/file-icons/folder.svg',
    '.doc': 'assets/images/file-icons/folder.svg',
    '.docx': 'assets/images/file-icons/folder.svg',
    '.xls': 'assets/images/file-icons/folder.svg',
    '.xlsx': 'assets/images/file-icons/folder.svg',
    '.ppt': 'assets/images/file-icons/folder.svg',
    '.pptx': 'assets/images/file-icons/folder.svg',
    '.odt': 'assets/images/file-icons/folder.svg',
    '.ods': 'assets/images/file-icons/folder.svg',
    '.odp': 'assets/images/file-icons/folder.svg',
  };

  static const Map<String, String> _specialFileMap = {
    'Dockerfile': 'assets/images/file-icons/code.svg',
    'Makefile': 'assets/images/file-icons/code.svg',
    'README': 'assets/images/file-icons/markdown.svg',
    'LICENSE': 'assets/images/file-icons/code.svg',
    'CHANGELOG': 'assets/images/file-icons/markdown.svg',
    'CONTRIBUTING': 'assets/images/file-icons/markdown.svg',
    'requirements.txt': 'assets/images/file-icons/python.svg',
    'Pipfile': 'assets/images/file-icons/python.svg',
    'poetry.lock': 'assets/images/file-icons/python.svg',
    'Cargo.toml': 'assets/images/file-icons/code.svg',
    'Cargo.lock': 'assets/images/file-icons/code.svg',
    'composer.json': 'assets/images/file-icons/json.svg',
    'composer.lock': 'assets/images/file-icons/json.svg',
    'Gemfile': 'assets/images/file-icons/code.svg',
    'Gemfile.lock': 'assets/images/file-icons/code.svg',
    'package.json': 'assets/images/file-icons/json.svg',
    'package-lock.json': 'assets/images/file-icons/json.svg',
    'yarn.lock': 'assets/images/file-icons/json.svg',
    'pnpm-lock.yaml': 'assets/images/file-icons/yaml.svg',
    'tsconfig.json': 'assets/images/file-icons/json.svg',
    'webpack.config.js': 'assets/images/file-icons/javascript.svg',
    'vite.config.js': 'assets/images/file-icons/javascript.svg',
    'vite.config.ts': 'assets/images/file-icons/typescript.svg',
    'next.config.js': 'assets/images/file-icons/javascript.svg',
    'nuxt.config.js': 'assets/images/file-icons/javascript.svg',
    'angular.json': 'assets/images/file-icons/json.svg',
    'vue.config.js': 'assets/images/file-icons/javascript.svg',
    'pubspec.yaml': 'assets/images/file-icons/yaml.svg',
    'pubspec.lock': 'assets/images/file-icons/json.svg',
    'analysis_options.yaml': 'assets/images/file-icons/yaml.svg',
    'build.gradle': 'assets/images/file-icons/code.svg',
    'gradle.properties': 'assets/images/file-icons/json.svg',
    'settings.gradle': 'assets/images/file-icons/code.svg',
    'pom.xml': 'assets/images/file-icons/json.svg',
    'build.xml': 'assets/images/file-icons/json.svg',
  };

  static String getIconPath(String fileName) {
    // Check special files first (exact name match)
    final specialFileName = fileName.split('/').last;
    if (_specialFileMap.containsKey(specialFileName)) {
      return _specialFileMap[specialFileName]!;
    }

    // Check by extension
    final extension = _getFileExtension(fileName);
    if (_fileIconMap.containsKey(extension)) {
      return _fileIconMap[extension]!;
    }

    // Default icon
    return 'assets/images/file-icons/code.svg';
  }

  static String getFileType(String fileName) {
    final specialFileName = fileName.split('/').last;
    
    // Check special files first
    if (_specialFileMap.containsKey(specialFileName)) {
      return _getFileTypeFromIcon(_specialFileMap[specialFileName]!);
    }

    // Check by extension
    final extension = _getFileExtension(fileName);
    if (_fileIconMap.containsKey(extension)) {
      return _getFileTypeFromIcon(_fileIconMap[extension]!);
    }

    return 'text';
  }

  static Widget getIconWidget(String fileName, {double size = 16, Color? color}) {
    final iconPath = getIconPath(fileName);
    
    return SvgPicture.asset(
      iconPath,
      width: size,
      height: size,
      colorFilter: color != null 
          ? ColorFilter.mode(color, BlendMode.srcIn)
          : null,
    );
  }

  static Color getIconColor(String fileName, BuildContext context) {
    final fileType = getFileType(fileName);
    
    switch (fileType) {
      case 'dart':
        return Colors.blue;
      case 'javascript':
        return Colors.yellow[700]!;
      case 'typescript':
        return Colors.blue[700]!;
      case 'python':
        return Colors.green[700]!;
      case 'java':
        return Colors.orange[700]!;
      case 'html':
        return Colors.orange;
      case 'css':
        return Colors.blue[600]!;
      case 'json':
      case 'xml':
        return Colors.grey[600]!;
      case 'markdown':
        return Colors.grey[700]!;
      case 'yaml':
        return Colors.red[600]!;
      case 'shell':
        return Colors.green[600]!;
      case 'powershell':
        return Colors.blue[800]!;
      case 'sql':
        return Colors.purple[600]!;
      case 'image':
        return Colors.pink[600]!;
      case 'audio':
        return Colors.deepPurple[600]!;
      case 'video':
        return Colors.red[600]!;
      case 'document':
        return Colors.indigo[600]!;
      case 'archive':
        return Colors.brown[600]!;
      default:
        return Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7);
    }
  }

  static Widget getFolderIcon({bool isOpen = false, double size = 16, Color? color}) {
    final iconPath = isOpen 
        ? 'assets/images/file-icons/folder-open.svg'
        : 'assets/images/file-icons/folder.svg';
    
    return SvgPicture.asset(
      iconPath,
      width: size,
      height: size,
      colorFilter: color != null 
          ? ColorFilter.mode(color, BlendMode.srcIn)
          : null,
    );
  }

  static String _getFileExtension(String fileName) {
    final lastDotIndex = fileName.lastIndexOf('.');
    if (lastDotIndex == -1) return '';
    return fileName.substring(lastDotIndex).toLowerCase();
  }

  static String _getFileTypeFromIcon(String iconPath) {
    if (iconPath.contains('javascript')) return 'javascript';
    if (iconPath.contains('typescript')) return 'typescript';
    if (iconPath.contains('python')) return 'python';
    if (iconPath.contains('html')) return 'html';
    if (iconPath.contains('css')) return 'css';
    if (iconPath.contains('json')) return 'json';
    if (iconPath.contains('yaml')) return 'yaml';
    if (iconPath.contains('markdown')) return 'markdown';
    if (iconPath.contains('audio')) return 'audio';
    if (iconPath.contains('image')) return 'image';
    if (iconPath.contains('folder')) return 'folder';
    if (iconPath.contains('code')) return 'code';
    return 'text';
  }
}
