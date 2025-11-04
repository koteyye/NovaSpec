import 'dart:convert';
import 'dart:io';
import 'package:yaml/yaml.dart';
import '../models/openapi_spec.dart';
import 'dart:async';

class OpenAPIService {
  static const List<String> supportedExtensions = ['yaml', 'yml', 'json'];

  Future<OpenAPISpec> parseOpenAPISpec(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('OpenAPI file not found: $filePath');
      }

      final content = await file.readAsString(encoding: utf8);
      final extension = filePath.toLowerCase().split('.').last;

      Map<String, dynamic> spec;

      if (extension == 'json') {
        spec = jsonDecode(content) as Map<String, dynamic>;
      } else {
        final yamlDoc = loadYaml(content);
        spec = _yamlToMap(yamlDoc);
      }

      return OpenAPISpec.fromMap(filePath, spec);
    } catch (e) {
      throw Exception('Failed to parse OpenAPI spec: $e');
    }
  }

  Future<bool> isValidOpenAPIFile(String filePath) async {
    try {
      final spec = await parseOpenAPISpec(filePath);
      return spec.isValid;
    } catch (e) {
      return false;
    }
  }

  dynamic _yamlToMap(dynamic yaml) {
    if (yaml is YamlMap) {
      final map = <String, dynamic>{};
      for (final entry in yaml.entries) {
        map[entry.key.toString()] = _yamlToMap(entry.value);
      }
      return map;
    } else if (yaml is YamlList) {
      return yaml.map((item) => _yamlToMap(item)).toList();
    } else {
      return yaml;
    }
  }

  Future<String> generateSwaggerHtml(
    String specContent, {
    String specUrl = '/spec.json',
  }) async {
    // Generate HTML for Swagger UI
    return '''
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Swagger UI</title>
    <link rel="stylesheet" type="text/css" href="https://unpkg.com/swagger-ui-dist@5.10.5/swagger-ui.css" />
    <style>
        html {
            box-sizing: border-box;
            overflow: -moz-scrollbars-vertical;
            overflow-y: scroll;
        }
        *, *:before, *:after {
            box-sizing: inherit;
        }
        body {
            margin: 0;
            background: #fafafa;
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif;
        }
        .swagger-ui .topbar {
            display: none;
        }
    </style>
</head>
<body>
    <div id="swagger-ui"></div>
    <script src="https://unpkg.com/swagger-ui-dist@5.10.5/swagger-ui-bundle.js"></script>
    <script src="https://unpkg.com/swagger-ui-dist@5.10.5/swagger-ui-standalone-preset.js"></script>
    <script>
        window.onload = function() {
            console.log('Loading OpenAPI spec from: $specUrl');
            const ui = SwaggerUIBundle({
                url: '$specUrl',
                dom_id: '#swagger-ui',
                deepLinking: true,
                presets: [
                    SwaggerUIBundle.presets.apis,
                    SwaggerUIStandalonePreset
                ],
                plugins: [
                    SwaggerUIBundle.plugins.DownloadUrl
                ],
                layout: "StandaloneLayout",
                validatorUrl: null
            });
        };
    </script>
</body>
</html>
    ''';
  }

  Future<Map<String, dynamic>> validateSpec(String filePath) async {
    try {
      final spec = await parseOpenAPISpec(filePath);

      final validationResults = <String, dynamic>{
        'isValid': spec.isValid,
        'version': spec.version,
        'title': spec.title,
        'endpointCount': spec.endpointCount,
        'errors': <String>[],
        'warnings': <String>[],
      };

      if (!spec.isValid) {
        validationResults['errors'].add(
          'Invalid OpenAPI specification structure',
        );
      }

      if (spec.title == null || spec.title!.isEmpty) {
        validationResults['warnings'].add('Missing API title');
      }

      if (spec.endpointCount == 0) {
        validationResults['warnings'].add('No endpoints defined');
      }

      return validationResults;
    } catch (e) {
      return {
        'isValid': false,
        'errors': ['Failed to validate: $e'],
        'warnings': <String>[],
      };
    }
  }

  List<String> getSupportedExtensions() {
    return List.from(supportedExtensions);
  }

  bool isSupportedExtension(String filePath) {
    final extension = filePath.toLowerCase().split('.').last;
    return supportedExtensions.contains(extension);
  }
}
