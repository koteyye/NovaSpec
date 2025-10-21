// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'navigation_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NavigationState _$NavigationStateFromJson(Map<String, dynamic> json) =>
    NavigationState(
      currentRoute: json['currentRoute'] as String,
      history: (json['history'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      parameters: json['parameters'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$NavigationStateToJson(NavigationState instance) =>
    <String, dynamic>{
      'currentRoute': instance.currentRoute,
      'history': instance.history,
      'parameters': instance.parameters,
    };
