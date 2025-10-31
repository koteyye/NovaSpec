enum FileNodeType {
  file,
  folder,
}

class FileExplorerNode {
  final String id;
  final String name;
  final String path;
  final FileNodeType type;
  final List<FileExplorerNode> children;
  final bool isExpanded;
  final bool isRenaming;
  final String? editingName;
  final bool isModified;
  final bool hasChildren;
  final DateTime? modifiedTime;
  final int? size;

  const FileExplorerNode({
    required this.id,
    required this.name,
    required this.path,
    required this.type,
    required this.children,
    required this.isExpanded,
    required this.isRenaming,
    this.editingName,
    this.isModified = false,
    this.hasChildren = false,
    this.modifiedTime,
    this.size,
  });

  FileExplorerNode copyWith({
    String? id,
    String? name,
    String? path,
    FileNodeType? type,
    List<FileExplorerNode>? children,
    bool? isExpanded,
    bool? isRenaming,
    String? editingName,
    bool? isModified,
    bool? hasChildren,
    DateTime? modifiedTime,
    int? size,
  }) {
    return FileExplorerNode(
      id: id ?? this.id,
      name: name ?? this.name,
      path: path ?? this.path,
      type: type ?? this.type,
      children: children ?? this.children,
      isExpanded: isExpanded ?? this.isExpanded,
      isRenaming: isRenaming ?? this.isRenaming,
      editingName: editingName ?? this.editingName,
      isModified: isModified ?? this.isModified,
      hasChildren: hasChildren ?? this.hasChildren,
      modifiedTime: modifiedTime ?? this.modifiedTime,
      size: size ?? this.size,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FileExplorerNode &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  bool get isFile => type == FileNodeType.file;
  bool get isFolder => type == FileNodeType.folder;
  bool get isDirectory => isFolder;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'path': path,
      'type': type.name,
      'children': children.map((child) => child.toJson()).toList(),
      'isExpanded': isExpanded,
      'isRenaming': isRenaming,
      'editingName': editingName,
      'isModified': isModified,
      'hasChildren': hasChildren,
      'modifiedTime': modifiedTime?.toIso8601String(),
      'size': size,
    };
  }

  factory FileExplorerNode.fromJson(Map<String, dynamic> json) {
    return FileExplorerNode(
      id: json['id'] as String,
      name: json['name'] as String,
      path: json['path'] as String,
      type: FileNodeType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => FileNodeType.file,
      ),
      children: (json['children'] as List<dynamic>)
          .map((child) => FileExplorerNode.fromJson(child as Map<String, dynamic>))
          .toList(),
      isExpanded: json['isExpanded'] as bool? ?? false,
      isRenaming: json['isRenaming'] as bool? ?? false,
      editingName: json['editingName'] as String?,
      isModified: json['isModified'] as bool? ?? false,
      hasChildren: json['hasChildren'] as bool? ?? false,
      modifiedTime: json['modifiedTime'] != null 
          ? DateTime.parse(json['modifiedTime'] as String)
          : null,
      size: json['size'] as int?,
    );
  }
}
