// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'validation_error.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ValidationError _$ValidationErrorFromJson(Map<String, dynamic> json) =>
    ValidationError(
      field: json['field'] as String,
      rule: $enumDecode(_$ValidationRuleEnumMap, json['rule']),
      message: json['message'] as String,
      value: json['value'],
      parameters: json['parameters'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$ValidationErrorToJson(ValidationError instance) =>
    <String, dynamic>{
      'field': instance.field,
      'rule': _$ValidationRuleEnumMap[instance.rule]!,
      'message': instance.message,
      'value': instance.value,
      'parameters': instance.parameters,
    };

const _$ValidationRuleEnumMap = {
  ValidationRule.required: 'required',
  ValidationRule.minLength: 'minLength',
  ValidationRule.maxLength: 'maxLength',
  ValidationRule.pattern: 'pattern',
  ValidationRule.email: 'email',
  ValidationRule.url: 'url',
  ValidationRule.numeric: 'numeric',
  ValidationRule.range: 'range',
  ValidationRule.custom: 'custom',
};

ValidationResult _$ValidationResultFromJson(Map<String, dynamic> json) =>
    ValidationResult(
      isValid: json['isValid'] as bool,
      errors: (json['errors'] as List<dynamic>)
          .map((e) => ValidationError.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ValidationResultToJson(ValidationResult instance) =>
    <String, dynamic>{'isValid': instance.isValid, 'errors': instance.errors};
