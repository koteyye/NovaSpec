enum FileContentType {
  markdown,
  html,
  audio,
  swagger,
  text,
  binary,
  unknown,
}

enum TabMode {
  render,
  edit,
}

class WorkspaceTab {
  final String id;
  final String filePath;
  final String fileName;
  final FileContentType contentType;
  final TabMode mode;
  final bool isModified;
  final DateTime lastModified;
  final String? content;
  final String? language;

  const WorkspaceTab({
    required this.id,
    required this.filePath,
    required this.fileName,
    required this.contentType,
    required this.mode,
    required this.isModified,
    required this.lastModified,
    this.content,
    this.language,
  });

  WorkspaceTab copyWith({
    String? id,
    String? filePath,
    String? fileName,
    FileContentType? contentType,
    TabMode? mode,
    bool? isModified,
    DateTime? lastModified,
    String? content,
    String? language,
  }) {
    return WorkspaceTab(
      id: id ?? this.id,
      filePath: filePath ?? this.filePath,
      fileName: fileName ?? this.fileName,
      contentType: contentType ?? this.contentType,
      mode: mode ?? this.mode,
      isModified: isModified ?? this.isModified,
      lastModified: lastModified ?? this.lastModified,
      content: content ?? this.content,
      language: language ?? this.language,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorkspaceTab &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  // Convenience getters
  String get path => filePath;
  String get title => fileName;
  bool get isActive => false; // This will be managed by provider

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'filePath': filePath,
      'fileName': fileName,
      'contentType': contentType.name,
      'mode': mode.name,
      'isModified': isModified,
      'lastModified': lastModified.toIso8601String(),
      'content': content,
      'language': language,
    };
  }

  factory WorkspaceTab.fromJson(Map<String, dynamic> json) {
    return WorkspaceTab(
      id: json['id'] as String,
      filePath: json['filePath'] as String,
      fileName: json['fileName'] as String,
      contentType: FileContentType.values.firstWhere(
        (e) => e.name == json['contentType'],
        orElse: () => FileContentType.unknown,
      ),
      mode: TabMode.values.firstWhere(
        (e) => e.name == json['mode'],
        orElse: () => TabMode.render,
      ),
      isModified: json['isModified'] as bool,
      lastModified: DateTime.parse(json['lastModified'] as String),
      content: json['content'] as String?,
      language: json['language'] as String?,
    );
  }
}
