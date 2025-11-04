import 'dart:io';

class MarkdownService {
  static const List<String> supportedExtensions = ['md', 'markdown'];

  Future<String> parseMarkdown(String content) async {
    // Basic validation
    if (content.trim().isEmpty) {
      return '';
    }

    try {
      // The actual parsing will be done by flutter_markdown widget
      // This method can be used for preprocessing if needed
      return content;
    } catch (e) {
      throw Exception('Failed to parse markdown: $e');
    }
  }

  Future<String> loadFromFile(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('Markdown file not found: $filePath');
      }

      final content = await file.readAsString();
      return content;
    } catch (e) {
      throw Exception('Failed to load markdown file: $e');
    }
  }

  Future<void> saveToFile(String filePath, String content) async {
    try {
      final file = File(filePath);
      await file.writeAsString(content);
    } catch (e) {
      throw Exception('Failed to save markdown file: $e');
    }
  }

  bool isValidMarkdownFile(String filePath) {
    final extension = filePath.toLowerCase().split('.').last;
    return supportedExtensions.contains(extension);
  }

  bool isValidMarkdownContent(String content) {
    // Basic validation - check if it contains markdown syntax
    if (content.trim().isEmpty) return false;

    // Check for common markdown patterns
    final markdownPatterns = [
      RegExp(r'^#{1,6}\s'), // Headers
      RegExp(r'\*\*.*?\*\*'), // Bold
      RegExp(r'\*.*?\*'), // Italic
      RegExp(r'^\s*[-*+]\s'), // Lists
      RegExp(r'^\s*\d+\.\s'), // Numbered lists
      RegExp(r'\[.*?\]\(.*?\)'), // Links
      RegExp(r'```'), // Code blocks
      RegExp(r'^>'), // Blockquotes
    ];

    return markdownPatterns.any((pattern) => pattern.hasMatch(content));
  }

  String preprocessContent(String content) {
    // Preprocess content for better rendering
    return content
        .trim()
        .replaceAll('\r\n', '\n') // Normalize line endings
        .replaceAll('\r', '\n');
  }

  Map<String, dynamic> extractMetadata(String content) {
    // Extract YAML front matter if present
    final frontMatterRegex = RegExp(r'^---\s*\n(.*?)\n---\s*\n', dotAll: true);
    final match = frontMatterRegex.firstMatch(content);

    if (match != null) {
      final yamlContent = match.group(1)!;
      // Parse YAML if needed (requires yaml package)
      return {
        'hasFrontMatter': true,
        'frontMatter': yamlContent,
        'content': content.substring(match.end),
      };
    }

    return {
      'hasFrontMatter': false,
      'content': content,
    };
  }

  int getWordCount(String content) {
    final words = content
        .replaceAll(RegExp(r'[^\w\s]'), '')
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .length;
    return words;
  }

  int getReadingTimeMinutes(String content) {
    final wordCount = getWordCount(content);
    // Average reading speed: 200 words per minute
    return (wordCount / 200).ceil();
  }
}