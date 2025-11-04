import 'package:equatable/equatable.dart';

class APIEndpoint extends Equatable {
  final String path;
  final String method;
  final String? summary;
  final String? description;
  final List<String> tags;
  final Map<String, dynamic>? parameters;
  final Map<String, dynamic>? responses;

  const APIEndpoint({
    required this.path,
    required this.method,
    this.summary,
    this.description,
    this.tags = const [],
    this.parameters,
    this.responses,
  });

  factory APIEndpoint.fromJson(Map<String, dynamic> json) {
    // Extract endpoints from OpenAPI paths object
    final path = json['path'] as String;
    final method = json['method'] as String;
    final operation = json['operation'] as Map<String, dynamic>?;

    return APIEndpoint(
      path: path,
      method: method.toUpperCase(),
      summary: operation?['summary'] as String?,
      description: operation?['description'] as String?,
      tags: (operation?['tags'] as List<dynamic>?)?.cast<String>() ?? [],
      parameters: operation?['parameters'] as Map<String, dynamic>?,
      responses: operation?['responses'] as Map<String, dynamic>?,
    );
  }

  @override
  List<Object?> get props => [
        path,
        method,
        summary,
        description,
        tags,
        parameters,
        responses,
      ];

  @override
  String toString() {
    return 'APIEndpoint($method $path)';
  }
}

class OpenAPISpec extends Equatable {
  final String filePath;
  final Map<String, dynamic> spec;
  final String version;
  final String? title;
  final String? description;
  final List<APIEndpoint> endpoints;
  final bool isValid;

  const OpenAPISpec({
    required this.filePath,
    required this.spec,
    required this.version,
    this.title,
    this.description,
    this.endpoints = const [],
    this.isValid = false,
  });

  factory OpenAPISpec.fromMap(String filePath, Map<String, dynamic> spec) {
    final info = spec['info'] as Map<String, dynamic>? ?? {};
    final version = info['version'] as String? ?? '1.0.0';
    final title = info['title'] as String?;
    final description = info['description'] as String?;
    
    // Extract endpoints from paths
    final paths = spec['paths'] as Map<String, dynamic>? ?? {};
    final endpoints = <APIEndpoint>[];
    
    for (final pathEntry in paths.entries) {
      final path = pathEntry.key;
      final pathItem = pathEntry.value as Map<String, dynamic>;
      
      // Extract methods (get, post, put, delete, etc.)
      for (final methodEntry in pathItem.entries) {
        final method = methodEntry.key;
        if (['get', 'post', 'put', 'delete', 'patch', 'head', 'options'].contains(method)) {
          final operation = methodEntry.value as Map<String, dynamic>?;
          if (operation != null) {
            endpoints.add(APIEndpoint.fromJson({
              'path': path,
              'method': method,
              'operation': operation,
            }));
          }
        }
      }
    }

    // Basic validation for OpenAPI spec
    final isValid = _validateOpenAPISpec(spec);

    return OpenAPISpec(
      filePath: filePath,
      spec: spec,
      version: version,
      title: title,
      description: description,
      endpoints: endpoints,
      isValid: isValid,
    );
  }

  static bool _validateOpenAPISpec(Map<String, dynamic> spec) {
    // Check for required OpenAPI fields
    if (!spec.containsKey('openapi') && !spec.containsKey('swagger')) {
      return false;
    }

    if (!spec.containsKey('info')) {
      return false;
    }

    final info = spec['info'] as Map<String, dynamic>?;
    if (info == null || !info.containsKey('version')) {
      return false;
    }

    if (!spec.containsKey('paths')) {
      return false;
    }

    return true;
  }

  OpenAPISpec copyWith({
    String? filePath,
    Map<String, dynamic>? spec,
    String? version,
    String? title,
    String? description,
    List<APIEndpoint>? endpoints,
    bool? isValid,
  }) {
    return OpenAPISpec(
      filePath: filePath ?? this.filePath,
      spec: spec ?? this.spec,
      version: version ?? this.version,
      title: title ?? this.title,
      description: description ?? this.description,
      endpoints: endpoints ?? this.endpoints,
      isValid: isValid ?? this.isValid,
    );
  }

  String get specType {
    if (spec.containsKey('openapi')) {
      return 'OpenAPI ${spec['openapi']}';
    } else if (spec.containsKey('swagger')) {
      return 'Swagger ${spec['swagger']}';
    }
    return 'Unknown';
  }

  int get endpointCount => endpoints.length;

  @override
  List<Object?> get props => [
        filePath,
        spec,
        version,
        title,
        description,
        endpoints,
        isValid,
      ];

  @override
  String toString() {
    return 'OpenAPISpec(title: $title, version: $version, endpoints: $endpointCount)';
  }
}