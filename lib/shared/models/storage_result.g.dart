// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'storage_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StorageResult<T> _$StorageResultFromJson<T>(
  Map<String, dynamic> json,
  T Function(Object? json) fromJsonT,
) => StorageResult<T>(
  isSuccess: json['isSuccess'] as bool,
  data: _$nullableGenericFromJson(json['data'], fromJsonT),
  error: json['error'] == null
      ? null
      : AppError.fromJson(json['error'] as Map<String, dynamic>),
  timestamp: DateTime.parse(json['timestamp'] as String),
);

Map<String, dynamic> _$StorageResultToJson<T>(
  StorageResult<T> instance,
  Object? Function(T value) toJsonT,
) => <String, dynamic>{
  'isSuccess': instance.isSuccess,
  'data': _$nullableGenericToJson(instance.data, toJsonT),
  'error': instance.error,
  'timestamp': instance.timestamp.toIso8601String(),
};

T? _$nullableGenericFromJson<T>(
  Object? input,
  T Function(Object? json) fromJson,
) => input == null ? null : fromJson(input);

Object? _$nullableGenericToJson<T>(
  T? input,
  Object? Function(T value) toJson,
) => input == null ? null : toJson(input);
