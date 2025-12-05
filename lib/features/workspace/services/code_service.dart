import 'dart:io';

class CodeService {
  static const List<String> supportedExtensions = [
    'js', 'jsx', 'ts', 'tsx', 'py', 'java', 'cpp', 'cc', 'cxx', 'c', 'cs',
    'php', 'rb', 'go', 'rs', 'swift', 'kt', 'scala', 'html', 'css', 'scss',
    'sass', 'less', 'json', 'xml', 'yaml', 'yml', 'toml', 'ini', 'sql',
    'sh', 'bash', 'ps1', 'dockerfile', 'dart', 'vue', 'svelte', 'txt',
    'md', 'markdown', 'gitignore', 'env', 'config', 'conf', 'log'
  ];

  Future<String> loadFromFile(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('Code file not found: $filePath');
      }

      final content = await file.readAsString();
      return content;
    } catch (e) {
      throw Exception('Failed to load code file: $e');
    }
  }

  Future<void> saveToFile(String filePath, String content) async {
    try {
      final file = File(filePath);
      await file.writeAsString(content);
    } catch (e) {
      throw Exception('Failed to save code file: $e');
    }
  }

  bool isValidCodeFile(String filePath) {
    final extension = filePath.toLowerCase().split('.').last;
    return supportedExtensions.contains(extension);
  }

  String detectLanguage(String filePath) {
    final extension = filePath.toLowerCase().split('.').last;
    final fileName = filePath.toLowerCase().split('/').last;
    
    // Special cases for files without extensions or specific names
    if (fileName == 'dockerfile') return 'dockerfile';
    if (fileName == '.gitignore') return 'gitignore';
    if (fileName.endsWith('.env')) return 'env';
    if (fileName.endsWith('.config') || fileName.endsWith('.conf')) return 'config';
    if (fileName.endsWith('.log')) return 'log';
    
    switch (extension) {
      case 'js':
      case 'jsx':
        return 'javascript';
      case 'ts':
      case 'tsx':
        return 'typescript';
      case 'py':
        return 'python';
      case 'java':
        return 'java';
      case 'cpp':
      case 'cc':
      case 'cxx':
        return 'cpp';
      case 'c':
        return 'c';
      case 'cs':
        return 'csharp';
      case 'php':
        return 'php';
      case 'rb':
        return 'ruby';
      case 'go':
        return 'go';
      case 'rs':
        return 'rust';
      case 'swift':
        return 'swift';
      case 'kt':
        return 'kotlin';
      case 'scala':
        return 'scala';
      case 'html':
      case 'htm':
        return 'html';
      case 'css':
        return 'css';
      case 'scss':
        return 'scss';
      case 'sass':
        return 'sass';
      case 'less':
        return 'less';
      case 'json':
        return 'json';
      case 'xml':
        return 'xml';
      case 'yaml':
      case 'yml':
        return 'yaml';
      case 'toml':
        return 'toml';
      case 'ini':
        return 'ini';
      case 'sql':
        return 'sql';
      case 'sh':
      case 'bash':
        return 'shell';
      case 'ps1':
        return 'powershell';
      case 'dart':
        return 'dart';
      case 'vue':
        return 'vue';
      case 'svelte':
        return 'svelte';
      case 'md':
      case 'markdown':
        return 'markdown';
      case 'txt':
        return 'plaintext';
      case 'gitignore':
        return 'gitignore';
      case 'env':
        return 'env';
      case 'config':
      case 'conf':
        return 'config';
      case 'log':
        return 'log';
      default:
        return 'plaintext';
    }
  }

  String preprocessContent(String content) {
    // Preprocess content for better rendering
    return content
        .trim()
        .replaceAll('\r\n', '\n') // Normalize line endings
        .replaceAll('\r', '\n');
  }

  Map<String, dynamic> extractMetadata(String content) {
    final lines = content.split('\n');
    final metadata = <String, dynamic>{};
    
    // Extract common metadata patterns
    for (int i = 0; i < lines.length && i < 20; i++) {
      final line = lines[i].trim();
      
      // Look for common comment patterns with metadata
      if (line.startsWith('//') || line.startsWith('#') || line.startsWith('/*') || line.startsWith('*')) {
        final cleanLine = line.replaceAll(RegExp(r'^[\/\*\#\s]+'), '').trim();
        
        // Look for key: value patterns
        final match = RegExp(r'^(\w+):\s*(.+)$').firstMatch(cleanLine);
        if (match != null) {
          metadata[match.group(1)!] = match.group(2)!;
        }
      }
    }
    
    return {
      'metadata': metadata,
      'content': content,
    };
  }

  int getLineCount(String content) {
    return content.split('\n').length;
  }

  int getCharacterCount(String content) {
    return content.length;
  }

  int getWordCount(String content) {
    final words = content
        .replaceAll(RegExp(r'[^\w\s]'), '')
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .length;
    return words;
  }

  Map<String, int> getLanguageStats(String content) {
    // Simple language statistics - could be enhanced
    final lines = content.split('\n');
    final stats = <String, int>{
      'totalLines': lines.length,
      'codeLines': 0,
      'commentLines': 0,
      'blankLines': 0,
    };

    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) {
        stats['blankLines'] = (stats['blankLines'] ?? 0) + 1;
      } else if (trimmed.startsWith('//') || 
                 trimmed.startsWith('#') || 
                 trimmed.startsWith('/*') || 
                 trimmed.startsWith('*') ||
                 trimmed.startsWith('<!--')) {
        stats['commentLines'] = (stats['commentLines'] ?? 0) + 1;
      } else {
        stats['codeLines'] = (stats['codeLines'] ?? 0) + 1;
      }
    }

    return stats;
  }

  List<String> getCommonKeywords(String language) {
    switch (language.toLowerCase()) {
      case 'javascript':
      case 'typescript':
        return ['function', 'const', 'let', 'var', 'if', 'else', 'for', 'while', 'return', 'class', 'import', 'export'];
      case 'python':
        return ['def', 'class', 'if', 'else', 'for', 'while', 'return', 'import', 'from', 'as', 'try', 'except'];
      case 'java':
        return ['public', 'private', 'static', 'final', 'class', 'interface', 'if', 'else', 'for', 'while', 'return'];
      case 'dart':
        return ['class', 'void', 'final', 'const', 'if', 'else', 'for', 'while', 'return', 'import', 'export'];
      default:
        return ['if', 'else', 'for', 'while', 'return', 'function', 'class'];
    }
  }

  bool isValidSyntax(String content, String language) {
    // Basic syntax validation - could be enhanced with language-specific parsers
    if (content.trim().isEmpty) return false;
    
    // Check for balanced brackets
    final brackets = {
      '(': ')',
      '[': ']',
      '{': '}',
      '<': '>',
    };
    
    final stack = <String>[];
    for (final char in content.split('')) {
      if (brackets.containsKey(char)) {
        stack.add(brackets[char]!);
      } else if (brackets.containsValue(char)) {
        if (stack.isEmpty || stack.removeLast() != char) {
          return false;
        }
      }
    }
    
    return stack.isEmpty;
  }
}