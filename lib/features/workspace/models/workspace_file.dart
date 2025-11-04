import 'dart:io';
import 'package:equatable/equatable.dart';

enum FileExtension {
  markdown,
  html,
  yaml,
  json,
  mp3,
  wav,
  unknown,
}

enum FileViewMode {
  view,
  edit,
  preview,
}

class WorkspaceFile extends Equatable {
  final String id;
  final String path;
  final String name;
  final FileExtension extension;
  final DateTime lastModified;
  final int size;
  final FileViewMode viewMode;
  final bool isModified;
  final String? content;

  const WorkspaceFile({
    required this.id,
    required this.path,
    required this.name,
    required this.extension,
    required this.lastModified,
    required this.size,
    required this.viewMode,
    required this.isModified,
    this.content,
  });

  factory WorkspaceFile.fromFile(File file, {String? id}) {
    final fileName = file.path.split(Platform.pathSeparator).last;
    final extension = _parseExtension(fileName);
    
    return WorkspaceFile(
      id: id ?? _generateId(),
      path: file.path,
      name: fileName,
      extension: extension,
      lastModified: file.lastModifiedSync(),
      size: file.lengthSync(),
      viewMode: FileViewMode.view,
      isModified: false,
    );
  }

  static FileExtension _parseExtension(String fileName) {
    final extension = fileName.toLowerCase().split('.').last;
    
    switch (extension) {
      case 'md':
      case 'markdown':
        return FileExtension.markdown;
      case 'html':
      case 'htm':
        return FileExtension.html;
      case 'yaml':
      case 'yml':
        return FileExtension.yaml;
      case 'json':
        return FileExtension.json;
      case 'mp3':
        return FileExtension.mp3;
      case 'wav':
        return FileExtension.wav;
      default:
        return FileExtension.unknown;
    }
  }

  static String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  WorkspaceFile copyWith({
    String? id,
    String? path,
    String? name,
    FileExtension? extension,
    DateTime? lastModified,
    int? size,
    FileViewMode? viewMode,
    bool? isModified,
    String? content,
  }) {
    return WorkspaceFile(
      id: id ?? this.id,
      path: path ?? this.path,
      name: name ?? this.name,
      extension: extension ?? this.extension,
      lastModified: lastModified ?? this.lastModified,
      size: size ?? this.size,
      viewMode: viewMode ?? this.viewMode,
      isModified: isModified ?? this.isModified,
      content: content ?? this.content,
    );
  }

  Future<String> readContent() async {
    if (content != null) {
      return content!;
    }
    
    try {
      final file = File(path);
      if (await file.exists()) {
        return await file.readAsString();
      }
      throw Exception('File not found: $path');
    } catch (e) {
      throw Exception('Failed to read file: $e');
    }
  }

  Future<void> saveContent(String newContent) async {
    try {
      final file = File(path);
      await file.writeAsString(newContent);
    } catch (e) {
      throw Exception('Failed to save file: $e');
    }
  }

  bool get isValid => path.isNotEmpty && size > 0;
  bool get isLargeFile => size > 10 * 1024 * 1024; // >10MB
  bool get isTextFile => [
    FileExtension.markdown,
    FileExtension.html,
    FileExtension.yaml,
    FileExtension.json,
  ].contains(extension);

  bool get isAudioFile => [
    FileExtension.mp3,
    FileExtension.wav,
  ].contains(extension);

  bool get isSupported => extension != FileExtension.unknown;

  @override
  List<Object?> get props => [
        id,
        path,
        name,
        extension,
        lastModified,
        size,
        viewMode,
        isModified,
        content,
      ];

  @override
  String toString() {
    return 'WorkspaceFile(id: $id, name: $name, extension: $extension)';
  }
}