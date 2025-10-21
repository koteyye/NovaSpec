// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ui_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UIComponentState _$UIComponentStateFromJson(Map<String, dynamic> json) =>
    UIComponentState(
      isLoading: json['isLoading'] as bool,
      isDisabled: json['isDisabled'] as bool,
      isVisible: json['isVisible'] as bool,
      errorMessage: json['errorMessage'] as String?,
      validationMessage: json['validationMessage'] as String?,
    );

Map<String, dynamic> _$UIComponentStateToJson(UIComponentState instance) =>
    <String, dynamic>{
      'isLoading': instance.isLoading,
      'isDisabled': instance.isDisabled,
      'isVisible': instance.isVisible,
      'errorMessage': instance.errorMessage,
      'validationMessage': instance.validationMessage,
    };
