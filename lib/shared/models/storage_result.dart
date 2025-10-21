import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'app_error.dart';

part 'storage_result.g.dart';

@JsonSerializable(genericArgumentFactories: true)
class StorageResult<T> extends Equatable {
  @JsonKey(name: 'isSuccess')
  final bool isSuccess;
  
  @JsonKey(name: 'data')
  final T? data;
  
  @JsonKey(name: 'error')
  final AppError? error;
  
  @JsonKey(name: 'timestamp')
  final DateTime timestamp;
  
  const StorageResult({
    required this.isSuccess,
    this.data,
    this.error,
    required this.timestamp,
  });
  
  factory StorageResult.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) =>
      _$StorageResultFromJson(json, fromJsonT);
  
  Map<String, dynamic> toJson(Object Function(T value) toJsonT) =>
      _$StorageResultToJson(this, toJsonT);
  
  factory StorageResult.success(T data) {
    return StorageResult<T>(
      isSuccess: true,
      data: data,
      timestamp: DateTime.now(),
    );
  }
  
  factory StorageResult.failure(AppError error) {
    return StorageResult<T>(
      isSuccess: false,
      error: error,
      timestamp: DateTime.now(),
    );
  }
  
  @override
  List<Object?> get props => [isSuccess, data, error, timestamp];
}