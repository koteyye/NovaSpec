import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'ui_state.g.dart';

@JsonSerializable()
class UIComponentState extends Equatable {
  @JsonKey(name: 'isLoading')
  final bool isLoading;
  
  @JsonKey(name: 'isDisabled')
  final bool isDisabled;
  
  @JsonKey(name: 'isVisible')
  final bool isVisible;
  
  @JsonKey(name: 'errorMessage')
  final String? errorMessage;
  
  @JsonKey(name: 'validationMessage')
  final String? validationMessage;
  
  const UIComponentState({
    required this.isLoading,
    required this.isDisabled,
    required this.isVisible,
    this.errorMessage,
    this.validationMessage,
  });
  
  factory UIComponentState.fromJson(Map<String, dynamic> json) =>
      _$UIComponentStateFromJson(json);
  
  Map<String, dynamic> toJson() => _$UIComponentStateToJson(this);
  
  UIComponentState copyWith({
    bool? isLoading,
    bool? isDisabled,
    bool? isVisible,
    String? errorMessage,
    String? validationMessage,
    bool clearError = false,
    bool clearValidation = false,
  }) {
    return UIComponentState(
      isLoading: isLoading ?? this.isLoading,
      isDisabled: isDisabled ?? this.isDisabled,
      isVisible: isVisible ?? this.isVisible,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      validationMessage: clearValidation ? null : (validationMessage ?? this.validationMessage),
    );
  }
  
  @override
  List<Object?> get props => [
    isLoading,
    isDisabled,
    isVisible,
    errorMessage,
    validationMessage,
  ];
}