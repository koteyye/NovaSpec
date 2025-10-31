enum ComponentType {
  widget,
  dialog,
  screen,
  container,
  input,
  button,
}

enum StateManagementType {
  none,
  localState,
  redux,
  context,
  customHook,
}

enum ComplexityLevel {
  low,
  medium,
  high,
}

class ComponentProp {
  final String name;
  final String type;
  final bool required;
  final String? defaultValue;

  ComponentProp({
    required this.name,
    required this.type,
    this.required = false,
    this.defaultValue,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'type': type,
      'required': required,
      'defaultValue': defaultValue,
    };
  }

  factory ComponentProp.fromJson(Map<String, dynamic> json) {
    return ComponentProp(
      name: json['name'],
      type: json['type'],
      required: json['required'] ?? false,
      defaultValue: json['defaultValue'],
    );
  }
}

class ComponentStyling {
  final String? className;
  final Map<String, dynamic>? inlineStyles;
  final String? cssFile;

  ComponentStyling({
    this.className,
    this.inlineStyles,
    this.cssFile,
  });

  Map<String, dynamic> toJson() {
    return {
      'className': className,
      'inlineStyles': inlineStyles,
      'cssFile': cssFile,
    };
  }

  factory ComponentStyling.fromJson(Map<String, dynamic> json) {
    return ComponentStyling(
      className: json['className'],
      inlineStyles: json['inlineStyles']?.cast<String, dynamic>(),
      cssFile: json['cssFile'],
    );
  }
}

class TypeScriptComponent {
  final String id;
  final String name;
  final ComponentType type;
  final String filePath;
  final List<String> dependencies;
  final List<ComponentProp> props;
  final ComponentStyling styling;
  final StateManagementType stateManagement;
  final ComplexityLevel complexity;
  final String? description;
  final DateTime? analyzedAt;

  TypeScriptComponent({
    required this.id,
    required this.name,
    required this.type,
    required this.filePath,
    this.dependencies = const [],
    this.props = const [],
    required this.styling,
    required this.stateManagement,
    required this.complexity,
    this.description,
    this.analyzedAt,
  });

  TypeScriptComponent copyWith({
    String? id,
    String? name,
    ComponentType? type,
    String? filePath,
    List<String>? dependencies,
    List<ComponentProp>? props,
    ComponentStyling? styling,
    StateManagementType? stateManagement,
    ComplexityLevel? complexity,
    String? description,
    DateTime? analyzedAt,
  }) {
    return TypeScriptComponent(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      filePath: filePath ?? this.filePath,
      dependencies: dependencies ?? this.dependencies,
      props: props ?? this.props,
      styling: styling ?? this.styling,
      stateManagement: stateManagement ?? this.stateManagement,
      complexity: complexity ?? this.complexity,
      description: description ?? this.description,
      analyzedAt: analyzedAt ?? this.analyzedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.name,
      'filePath': filePath,
      'dependencies': dependencies,
      'props': props.map((prop) => prop.toJson()).toList(),
      'styling': styling.toJson(),
      'stateManagement': stateManagement.name,
      'complexity': complexity.name,
      'description': description,
      'analyzedAt': analyzedAt?.toIso8601String(),
    };
  }

  factory TypeScriptComponent.fromJson(Map<String, dynamic> json) {
    return TypeScriptComponent(
      id: json['id'],
      name: json['name'],
      type: ComponentType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => ComponentType.widget,
      ),
      filePath: json['filePath'],
      dependencies: List<String>.from(json['dependencies'] ?? []),
      props: (json['props'] as List<dynamic>?)
          ?.map((prop) => ComponentProp.fromJson(prop))
          .toList() ?? [],
      styling: ComponentStyling.fromJson(json['styling'] ?? {}),
      stateManagement: StateManagementType.values.firstWhere(
        (e) => e.name == json['stateManagement'],
        orElse: () => StateManagementType.none,
      ),
      complexity: ComplexityLevel.values.firstWhere(
        (e) => e.name == json['complexity'],
        orElse: () => ComplexityLevel.low,
      ),
      description: json['description'],
      analyzedAt: json['analyzedAt'] != null 
          ? DateTime.parse(json['analyzedAt']) 
          : null,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TypeScriptComponent && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'TypeScriptComponent(id: $id, name: $name, type: $type, filePath: $filePath)';
  }
}

class ComponentAnalysisResult {
  final List<TypeScriptComponent> components;
  final DateTime analyzedAt;
  final String projectPath;
  final int totalFiles;
  final int analyzedFiles;
  final List<String> errors;

  ComponentAnalysisResult({
    required this.components,
    required this.analyzedAt,
    required this.projectPath,
    required this.totalFiles,
    required this.analyzedFiles,
    this.errors = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'components': components.map((c) => c.toJson()).toList(),
      'analyzedAt': analyzedAt.toIso8601String(),
      'projectPath': projectPath,
      'totalFiles': totalFiles,
      'analyzedFiles': analyzedFiles,
      'errors': errors,
    };
  }

  factory ComponentAnalysisResult.fromJson(Map<String, dynamic> json) {
    return ComponentAnalysisResult(
      components: (json['components'] as List<dynamic>)
          .map((c) => TypeScriptComponent.fromJson(c))
          .toList(),
      analyzedAt: DateTime.parse(json['analyzedAt']),
      projectPath: json['projectPath'],
      totalFiles: json['totalFiles'],
      analyzedFiles: json['analyzedFiles'],
      errors: List<String>.from(json['errors'] ?? []),
    );
  }

  int getComponentsByComplexity(ComplexityLevel complexity) {
    return components.where((c) => c.complexity == complexity).length;
  }

  List<TypeScriptComponent> getComponentsByType(ComponentType type) {
    return components.where((c) => c.type == type).toList();
  }
}
