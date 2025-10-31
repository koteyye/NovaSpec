enum PanelType {
  fileExplorer,
  openFiles,
  outline,
  terminal,
  output,
  problems,
  aiChat,
}

class WorkspacePanel {
  final String id;
  final PanelType type;
  final double width;
  final bool isVisible;
  final bool isResizable;
  final double minWidth;
  final double maxWidth;

  const WorkspacePanel({
    required this.id,
    required this.type,
    required this.width,
    required this.isVisible,
    required this.isResizable,
    required this.minWidth,
    required this.maxWidth,
  });

  WorkspacePanel copyWith({
    String? id,
    PanelType? type,
    double? width,
    bool? isVisible,
    bool? isResizable,
    double? minWidth,
    double? maxWidth,
  }) {
    return WorkspacePanel(
      id: id ?? this.id,
      type: type ?? this.type,
      width: width ?? this.width,
      isVisible: isVisible ?? this.isVisible,
      isResizable: isResizable ?? this.isResizable,
      minWidth: minWidth ?? this.minWidth,
      maxWidth: maxWidth ?? this.maxWidth,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorkspacePanel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'width': width,
      'isVisible': isVisible,
      'isResizable': isResizable,
      'minWidth': minWidth,
      'maxWidth': maxWidth,
    };
  }

  factory WorkspacePanel.fromJson(Map<String, dynamic> json) {
    return WorkspacePanel(
      id: json['id'] as String,
      type: PanelType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => PanelType.fileExplorer,
      ),
      width: (json['width'] as num).toDouble(),
      isVisible: json['isVisible'] as bool,
      isResizable: json['isResizable'] as bool,
      minWidth: (json['minWidth'] as num).toDouble(),
      maxWidth: (json['maxWidth'] as num).toDouble(),
    );
  }
}
