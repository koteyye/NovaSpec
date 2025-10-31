import 'workspace_tab.dart';

class OpenFile {
  final String id;
  final String path;
  final String name;
  final FileContentType contentType;
  final String content;
  final int size;
  final DateTime lastModified;
  final bool isTextFile;
  final Map<String, dynamic> metadata;

  const OpenFile({
    required this.id,
    required this.path,
    required this.name,
    required this.contentType,
    required this.content,
    required this.size,
    required this.lastModified,
    required this.isTextFile,
    required this.metadata,
  });

  OpenFile copyWith({
    String? id,
    String? path,
    String? name,
    FileContentType? contentType,
    String? content,
    int? size,
    DateTime? lastModified,
    bool? isTextFile,
    Map<String, dynamic>? metadata,
  }) {
    return OpenFile(
      id: id ?? this.id,
      path: path ?? this.path,
      name: name ?? this.name,
      contentType: contentType ?? this.contentType,
      content: content ?? this.content,
      size: size ?? this.size,
      lastModified: lastModified ?? this.lastModified,
      isTextFile: isTextFile ?? this.isTextFile,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OpenFile &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  bool get isLargeFile => size > 10 * 1024 * 1024; // > 10MB

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'path': path,
      'name': name,
      'contentType': contentType.name,
      'content': content,
      'size': size,
      'lastModified': lastModified.toIso8601String(),
      'isTextFile': isTextFile,
      'metadata': metadata,
    };
  }

  factory OpenFile.fromJson(Map<String, dynamic> json) {
    return OpenFile(
      id: json['id'] as String,
      path: json['path'] as String,
      name: json['name'] as String,
      contentType: FileContentType.values.firstWhere(
        (e) => e.name == json['contentType'],
        orElse: () => FileContentType.unknown,
      ),
      content: json['content'] as String,
      size: json['size'] as int,
      lastModified: DateTime.parse(json['lastModified'] as String),
      isTextFile: json['isTextFile'] as bool,
      metadata: json['metadata'] as Map<String, dynamic>,
    );
  }
}
