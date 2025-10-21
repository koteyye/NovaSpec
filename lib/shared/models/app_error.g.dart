// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_error.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AppError _$AppErrorFromJson(Map<String, dynamic> json) => AppError(
  type: $enumDecode(_$ErrorTypeEnumMap, json['type']),
  severity: $enumDecode(_$ErrorSeverityEnumMap, json['severity']),
  code: json['code'] as String,
  message: json['message'] as String,
  details: json['details'] as String?,
  timestamp: DateTime.parse(json['timestamp'] as String),
  stackTrace: json['stackTrace'] as String?,
);

Map<String, dynamic> _$AppErrorToJson(AppError instance) => <String, dynamic>{
  'type': _$ErrorTypeEnumMap[instance.type]!,
  'severity': _$ErrorSeverityEnumMap[instance.severity]!,
  'code': instance.code,
  'message': instance.message,
  'details': instance.details,
  'timestamp': instance.timestamp.toIso8601String(),
  'stackTrace': instance.stackTrace,
};

const _$ErrorTypeEnumMap = {
  ErrorType.validation: 'validation',
  ErrorType.network: 'network',
  ErrorType.storage: 'storage',
  ErrorType.fileSystem: 'fileSystem',
  ErrorType.authentication: 'authentication',
  ErrorType.permission: 'permission',
  ErrorType.configuration: 'configuration',
  ErrorType.memory: 'memory',
  ErrorType.async: 'async',
  ErrorType.system: 'system',
  ErrorType.unknown: 'unknown',
};

const _$ErrorSeverityEnumMap = {
  ErrorSeverity.low: 'low',
  ErrorSeverity.medium: 'medium',
  ErrorSeverity.high: 'high',
  ErrorSeverity.critical: 'critical',
};
