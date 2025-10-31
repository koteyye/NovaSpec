import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'validation_error.g.dart';

enum ValidationRule {
  @JsonValue('required')
  required,
  @JsonValue('minLength')
  minLength,
  @JsonValue('maxLength')
  maxLength,
  @JsonValue('pattern')
  pattern,
  @JsonValue('email')
  email,
  @JsonValue('url')
  url,
  @JsonValue('numeric')
  numeric,
  @JsonValue('range')
  range,
  @JsonValue('custom')
  custom,
}

@JsonSerializable()
class ValidationError extends Equatable {
  @JsonKey(name: 'field')
  final String field;
  
  @JsonKey(name: 'rule')
  final ValidationRule rule;
  
  @JsonKey(name: 'message')
  final String message;
  
  @JsonKey(name: 'value')
  final dynamic value;
  
  @JsonKey(name: 'parameters')
  final Map<String, dynamic>? parameters;
  
  const ValidationError({
    required this.field,
    required this.rule,
    required this.message,
    this.value,
    this.parameters,
  });
  
  factory ValidationError.fromJson(Map<String, dynamic> json) =>
      _$ValidationErrorFromJson(json);
  
  Map<String, dynamic> toJson() => _$ValidationErrorToJson(this);
  
  ValidationError copyWith({
    String? field,
    ValidationRule? rule,
    String? message,
    dynamic value,
    Map<String, dynamic>? parameters,
  }) {
    return ValidationError(
      field: field ?? this.field,
      rule: rule ?? this.rule,
      message: message ?? this.message,
      value: value ?? this.value,
      parameters: parameters ?? this.parameters,
    );
  }
  
  @override
  List<Object?> get props => [
    field,
    rule,
    message,
    value,
    parameters,
  ];
}

@JsonSerializable()
class ValidationResult extends Equatable {
  @JsonKey(name: 'isValid')
  final bool isValid;
  
  @JsonKey(name: 'errors')
  final List<ValidationError> errors;
  
  const ValidationResult({
    required this.isValid,
    required this.errors,
  });
  
  factory ValidationResult.fromJson(Map<String, dynamic> json) =>
      _$ValidationResultFromJson(json);
  
  Map<String, dynamic> toJson() => _$ValidationResultToJson(this);
  
  ValidationResult copyWith({
    bool? isValid,
    List<ValidationError>? errors,
  }) {
    return ValidationResult(
      isValid: isValid ?? this.isValid,
      errors: errors ?? this.errors,
    );
  }
  
  @override
  List<Object?> get props => [isValid, errors];
}
