import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'app_error.g.dart';

enum ErrorType {
  @JsonValue('validation')
  validation,
  @JsonValue('network')
  network,
  @JsonValue('storage')
  storage,
  @JsonValue('fileSystem')
  fileSystem,
  @JsonValue('authentication')
  authentication,
  @JsonValue('permission')
  permission,
  @JsonValue('configuration')
  configuration,
  @JsonValue('memory')
  memory,
  @JsonValue('async')
  async,
  @JsonValue('system')
  system,
  @JsonValue('unknown')
  unknown,
}

enum ErrorSeverity {
  @JsonValue('low')
  low,
  @JsonValue('medium')
  medium,
  @JsonValue('high')
  high,
  @JsonValue('critical')
  critical,
}

@JsonSerializable()
class AppError extends Equatable {
  @JsonKey(name: 'type')
  final ErrorType type;
  
  @JsonKey(name: 'severity')
  final ErrorSeverity severity;
  
  @JsonKey(name: 'code')
  final String code;
  
  @JsonKey(name: 'message')
  final String message;
  
  @JsonKey(name: 'details')
  final String? details;
  
  @JsonKey(name: 'timestamp')
  final DateTime timestamp;
  
  @JsonKey(name: 'stackTrace')
  final String? stackTrace;
  
  const AppError({
    required this.type,
    required this.severity,
    required this.code,
    required this.message,
    this.details,
    required this.timestamp,
    this.stackTrace,
  });
  
  factory AppError.fromJson(Map<String, dynamic> json) =>
      _$AppErrorFromJson(json);
  
  Map<String, dynamic> toJson() => _$AppErrorToJson(this);
  
  AppError copyWith({
    ErrorType? type,
    ErrorSeverity? severity,
    String? code,
    String? message,
    String? details,
    DateTime? timestamp,
    String? stackTrace,
  }) {
    return AppError(
      type: type ?? this.type,
      severity: severity ?? this.severity,
      code: code ?? this.code,
      message: message ?? this.message,
      details: details ?? this.details,
      timestamp: timestamp ?? this.timestamp,
      stackTrace: stackTrace ?? this.stackTrace,
    );
  }
  
  @override
  List<Object?> get props => [
    type,
    severity,
    code,
    message,
    details,
    timestamp,
    stackTrace,
  ];
}
