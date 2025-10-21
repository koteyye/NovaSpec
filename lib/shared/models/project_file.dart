enum ProjectFileType {
  dart,
  json,
  markdown,
  text,
  yaml,
  other,
}

class ProjectFile {
  final String name;
  final String path;
  final int size;
  final DateTime modifiedAt;
  final ProjectFileType type;

  const ProjectFile({
    required this.name,
    required this.path,
    required this.size,
    required this.modifiedAt,
    required this.type,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ProjectFile && 
           other.name == name &&
           other.path == path;
  }

  @override
  int get hashCode => Object.hash(name, path);

  @override
  String toString() {
    return 'ProjectFile(name: $name, path: $path, type: $type)';
  }
}