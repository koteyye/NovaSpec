import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'navigation_state.g.dart';

@JsonSerializable()
class NavigationState extends Equatable {
  @JsonKey(name: 'currentRoute')
  final String currentRoute;
  
  @JsonKey(name: 'history')
  final List<String> history;
  
  @JsonKey(name: 'parameters')
  final Map<String, dynamic> parameters;
  
  const NavigationState({
    required this.currentRoute,
    required this.history,
    required this.parameters,
  });
  
  factory NavigationState.fromJson(Map<String, dynamic> json) =>
      _$NavigationStateFromJson(json);
  
  Map<String, dynamic> toJson() => _$NavigationStateToJson(this);
  
  NavigationState copyWith({
    String? currentRoute,
    List<String>? history,
    Map<String, dynamic>? parameters,
  }) {
    return NavigationState(
      currentRoute: currentRoute ?? this.currentRoute,
      history: history ?? this.history,
      parameters: parameters ?? this.parameters,
    );
  }
  
  @override
  List<Object?> get props => [
    currentRoute,
    history,
    parameters,
  ];
}
