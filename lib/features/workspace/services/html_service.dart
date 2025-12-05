import 'dart:io';

class HtmlService {
  static const List<String> supportedExtensions = ['html', 'htm'];

  Future<String> parseHtml(String content) async {
    // Basic validation
    if (content.trim().isEmpty) {
      return '';
    }

    try {
      // The actual parsing will be done by flutter_html widget
      // This method can be used for preprocessing if needed
      return content;
    } catch (e) {
      throw Exception('Failed to parse HTML: $e');
    }
  }

  Future<String> loadFromFile(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('HTML file not found: $filePath');
      }

      final content = await file.readAsString();
      return content;
    } catch (e) {
      throw Exception('Failed to load HTML file: $e');
    }
  }

  Future<void> saveToFile(String filePath, String content) async {
    try {
      final file = File(filePath);
      await file.writeAsString(content);
    } catch (e) {
      throw Exception('Failed to save HTML file: $e');
    }
  }

  bool isValidHtmlFile(String filePath) {
    final extension = filePath.toLowerCase().split('.').last;
    return supportedExtensions.contains(extension);
  }

  bool isValidHtmlContent(String content) {
    // Basic validation - check if it contains HTML syntax
    if (content.trim().isEmpty) return false;

    // Check for common HTML patterns
    final htmlPatterns = [
      RegExp(r'<html[^>]*>', caseSensitive: false),
      RegExp(r'<head[^>]*>', caseSensitive: false),
      RegExp(r'<body[^>]*>', caseSensitive: false),
      RegExp(r'<div[^>]*>', caseSensitive: false),
      RegExp(r'<p[^>]*>', caseSensitive: false),
      RegExp(r'<a[^>]*>', caseSensitive: false),
      RegExp(r'<img[^>]*>', caseSensitive: false),
      RegExp(r'<script[^>]*>', caseSensitive: false),
      RegExp(r'<style[^>]*>', caseSensitive: false),
    ];

    return htmlPatterns.any((pattern) => pattern.hasMatch(content));
  }

  String preprocessContent(String content) {
    // Preprocess content for better rendering
    return content
        .trim()
        .replaceAll('\r\n', '\n') // Normalize line endings
        .replaceAll('\r', '\n');
  }

  Map<String, dynamic> extractMetadata(String content) {
    // Extract title if present
    final titleRegex = RegExp(r'<title[^>]*>(.*?)</title>', caseSensitive: false, dotAll: true);
    final titleMatch = titleRegex.firstMatch(content);

    // Extract meta tags if present
    final metaRegex = RegExp(r'<meta[^>]*>', caseSensitive: false);
    final metaMatches = metaRegex.allMatches(content);

    return {
      'title': titleMatch?.group(1)?.trim() ?? '',
      'metaTags': metaMatches.map((match) => match.group(0)!).toList(),
      'content': content,
    };
  }

  String sanitizeContent(String content) {
    // Basic sanitization - remove potentially dangerous content
    // This is a simple implementation, in production you might want more robust sanitization
    return content
        .replaceAll(RegExp(r'<script[^>]*>.*?</script>', caseSensitive: false, dotAll: true), '')
        .replaceAll(RegExp(r'<iframe[^>]*>.*?</iframe>', caseSensitive: false, dotAll: true), '')
        .replaceAll(RegExp(r'<object[^>]*>.*?</object>', caseSensitive: false, dotAll: true), '')
        .replaceAll(RegExp(r'<embed[^>]*>', caseSensitive: false), '');
  }

  int getWordCount(String content) {
    // Remove HTML tags for word count
    final plainText = content.replaceAll(RegExp(r'<[^>]*>'), '');
    final words = plainText
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