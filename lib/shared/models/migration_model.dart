import 'component_model.dart';

class FlutterEquivalent {
  final String widgetType;
  final String? package;
  final bool customImplementation;
  final String? description;
  final List<String> requiredDependencies;

  FlutterEquivalent({
    required this.widgetType,
    this.package,
    this.customImplementation = false,
    this.description,
    this.requiredDependencies = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'widgetType': widgetType,
      'package': package,
      'customImplementation': customImplementation,
      'description': description,
      'requiredDependencies': requiredDependencies,
    };
  }

  factory FlutterEquivalent.fromJson(Map<String, dynamic> json) {
    return FlutterEquivalent(
      widgetType: json['widgetType'],
      package: json['package'],
      customImplementation: json['customImplementation'] ?? false,
      description: json['description'],
      requiredDependencies: List<String>.from(json['requiredDependencies'] ?? []),
    );
  }
}

class EffortEstimate {
  final double hours;
  final ComplexityLevel complexity;
  final String? notes;

  EffortEstimate({
    required this.hours,
    required this.complexity,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'hours': hours,
      'complexity': complexity.name,
      'notes': notes,
    };
  }

  factory EffortEstimate.fromJson(Map<String, dynamic> json) {
    return EffortEstimate(
      hours: json['hours'].toDouble(),
      complexity: ComplexityLevel.values.firstWhere(
        (e) => e.name == json['complexity'],
        orElse: () => ComplexityLevel.low,
      ),
      notes: json['notes'],
    );
  }
}

class MigrationMapping {
  final TypeScriptComponent tsComponent;
  final FlutterEquivalent flutterEquivalent;
  final String migrationNotes;
  final bool customCodeRequired;
  final String testingApproach;
  final EffortEstimate estimatedEffort;
  final List<String> potentialIssues;
  final List<String> recommendations;

  MigrationMapping({
    required this.tsComponent,
    required this.flutterEquivalent,
    required this.migrationNotes,
    required this.customCodeRequired,
    required this.testingApproach,
    required this.estimatedEffort,
    this.potentialIssues = const [],
    this.recommendations = const [],
  });

  MigrationMapping copyWith({
    TypeScriptComponent? tsComponent,
    FlutterEquivalent? flutterEquivalent,
    String? migrationNotes,
    bool? customCodeRequired,
    String? testingApproach,
    EffortEstimate? estimatedEffort,
    List<String>? potentialIssues,
    List<String>? recommendations,
  }) {
    return MigrationMapping(
      tsComponent: tsComponent ?? this.tsComponent,
      flutterEquivalent: flutterEquivalent ?? this.flutterEquivalent,
      migrationNotes: migrationNotes ?? this.migrationNotes,
      customCodeRequired: customCodeRequired ?? this.customCodeRequired,
      testingApproach: testingApproach ?? this.testingApproach,
      estimatedEffort: estimatedEffort ?? this.estimatedEffort,
      potentialIssues: potentialIssues ?? this.potentialIssues,
      recommendations: recommendations ?? this.recommendations,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tsComponent': tsComponent.toJson(),
      'flutterEquivalent': flutterEquivalent.toJson(),
      'migrationNotes': migrationNotes,
      'customCodeRequired': customCodeRequired,
      'testingApproach': testingApproach,
      'estimatedEffort': estimatedEffort.toJson(),
      'potentialIssues': potentialIssues,
      'recommendations': recommendations,
    };
  }

  factory MigrationMapping.fromJson(Map<String, dynamic> json) {
    return MigrationMapping(
      tsComponent: TypeScriptComponent.fromJson(json['tsComponent']),
      flutterEquivalent: FlutterEquivalent.fromJson(json['flutterEquivalent']),
      migrationNotes: json['migrationNotes'],
      customCodeRequired: json['customCodeRequired'] ?? false,
      testingApproach: json['testingApproach'],
      estimatedEffort: EffortEstimate.fromJson(json['estimatedEffort']),
      potentialIssues: List<String>.from(json['potentialIssues'] ?? []),
      recommendations: List<String>.from(json['recommendations'] ?? []),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MigrationMapping && 
           other.tsComponent.id == tsComponent.id;
  }

  @override
  int get hashCode => tsComponent.id.hashCode;

  @override
  String toString() {
    return 'MigrationMapping(${tsComponent.name} -> ${flutterEquivalent.widgetType})';
  }
}

class MigrationPlan {
  final List<MigrationMapping> mappings;
  final DateTime createdAt;
  final DateTime? lastModified;
  final String version;
  final Map<String, dynamic> statistics;
  final List<String> globalRecommendations;

  MigrationPlan({
    required this.mappings,
    required this.createdAt,
    this.lastModified,
    required this.version,
    required this.statistics,
    this.globalRecommendations = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'mappings': mappings.map((m) => m.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'lastModified': lastModified?.toIso8601String(),
      'version': version,
      'statistics': statistics,
      'globalRecommendations': globalRecommendations,
    };
  }

  factory MigrationPlan.fromJson(Map<String, dynamic> json) {
    return MigrationPlan(
      mappings: (json['mappings'] as List<dynamic>)
          .map((m) => MigrationMapping.fromJson(m))
          .toList(),
      createdAt: DateTime.parse(json['createdAt']),
      lastModified: json['lastModified'] != null 
          ? DateTime.parse(json['lastModified']) 
          : null,
      version: json['version'],
      statistics: Map<String, dynamic>.from(json['statistics']),
      globalRecommendations: List<String>.from(json['globalRecommendations'] ?? []),
    );
  }

  double get totalEstimatedHours {
    return mappings.fold(0.0, (sum, mapping) => sum + mapping.estimatedEffort.hours);
  }

  Map<ComplexityLevel, int> get componentsByComplexity {
    final Map<ComplexityLevel, int> result = {};
    for (final complexity in ComplexityLevel.values) {
      result[complexity] = mappings
          .where((m) => m.tsComponent.complexity == complexity)
          .length;
    }
    return result;
  }

  List<MigrationMapping> get customCodeRequired {
    return mappings.where((m) => m.customCodeRequired).toList();
  }

  List<MigrationMapping> get highComplexityMappings {
    return mappings
        .where((m) => m.tsComponent.complexity == ComplexityLevel.high)
        .toList();
  }
}

class MigrationProgress {
  final String migrationId;
  final DateTime startedAt;
  final DateTime? completedAt;
  final int totalComponents;
  final int completedComponents;
  final int failedComponents;
  final List<String> errors;
  final Map<String, dynamic> metadata;

  MigrationProgress({
    required this.migrationId,
    required this.startedAt,
    this.completedAt,
    required this.totalComponents,
    this.completedComponents = 0,
    this.failedComponents = 0,
    this.errors = const [],
    this.metadata = const {},
  });

  double get completionPercentage {
    if (totalComponents == 0) return 0.0;
    return (completedComponents / totalComponents) * 100;
  }

  bool get isCompleted => completedAt != null;

  bool get hasErrors => errors.isNotEmpty;

  MigrationProgress copyWith({
    DateTime? completedAt,
    int? completedComponents,
    int? failedComponents,
    List<String>? errors,
    Map<String, dynamic>? metadata,
  }) {
    return MigrationProgress(
      migrationId: migrationId,
      startedAt: startedAt,
      completedAt: completedAt ?? this.completedAt,
      totalComponents: totalComponents,
      completedComponents: completedComponents ?? this.completedComponents,
      failedComponents: failedComponents ?? this.failedComponents,
      errors: errors ?? this.errors,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'migrationId': migrationId,
      'startedAt': startedAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'totalComponents': totalComponents,
      'completedComponents': completedComponents,
      'failedComponents': failedComponents,
      'errors': errors,
      'metadata': metadata,
    };
  }

  factory MigrationProgress.fromJson(Map<String, dynamic> json) {
    return MigrationProgress(
      migrationId: json['migrationId'],
      startedAt: DateTime.parse(json['startedAt']),
      completedAt: json['completedAt'] != null 
          ? DateTime.parse(json['completedAt']) 
          : null,
      totalComponents: json['totalComponents'],
      completedComponents: json['completedComponents'] ?? 0,
      failedComponents: json['failedComponents'] ?? 0,
      errors: List<String>.from(json['errors'] ?? []),
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
    );
  }
}
