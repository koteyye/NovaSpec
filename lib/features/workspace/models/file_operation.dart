enum FileOperationType {
  create,
  copy,
  move,
  delete,
  rename,
}

enum FileOperationStatus {
  pending,
  inProgress,
  completed,
  failed,
}

class FileOperation {
  final String id;
  final FileOperationType type;
  final String sourcePath;
  final String? destinationPath;
  final String? newName;
  final FileOperationStatus status;
  final DateTime createdAt;
  final DateTime? completedAt;
  final String? errorMessage;
  final double progress;

  const FileOperation({
    required this.id,
    required this.type,
    required this.sourcePath,
    this.destinationPath,
    this.newName,
    required this.status,
    required this.createdAt,
    this.completedAt,
    this.errorMessage,
    this.progress = 0.0,
  });

  FileOperation copyWith({
    String? id,
    FileOperationType? type,
    String? sourcePath,
    String? destinationPath,
    String? newName,
    FileOperationStatus? status,
    DateTime? createdAt,
    DateTime? completedAt,
    String? errorMessage,
    double? progress,
  }) {
    return FileOperation(
      id: id ?? this.id,
      type: type ?? this.type,
      sourcePath: sourcePath ?? this.sourcePath,
      destinationPath: destinationPath ?? this.destinationPath,
      newName: newName ?? this.newName,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      errorMessage: errorMessage ?? this.errorMessage,
      progress: progress ?? this.progress,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FileOperation &&
        other.id == id &&
        other.type == type &&
        other.sourcePath == sourcePath &&
        other.destinationPath == destinationPath &&
        other.newName == newName &&
        other.status == status &&
        other.createdAt == createdAt &&
        other.completedAt == completedAt &&
        other.errorMessage == errorMessage &&
        other.progress == progress;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      type,
      sourcePath,
      destinationPath,
      newName,
      status,
      createdAt,
      completedAt,
      errorMessage,
      progress,
    );
  }

  @override
  String toString() {
    return 'FileOperation(id: $id, type: $type, sourcePath: $sourcePath, status: $status, progress: $progress)';
  }
}
