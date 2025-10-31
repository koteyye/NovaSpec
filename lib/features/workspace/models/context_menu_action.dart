import 'package:flutter/material.dart';

enum ContextMenuActionType {
  open,
  rename,
  delete,
  copy,
  newFile,
  newFolder,
}

class ContextMenuAction {
  final String id;
  final String title;
  final String icon;
  final ContextMenuActionType type;
  final bool isEnabled;
  final VoidCallback? action;

  const ContextMenuAction({
    required this.id,
    required this.title,
    required this.icon,
    required this.type,
    required this.isEnabled,
    this.action,
  });

  ContextMenuAction copyWith({
    String? id,
    String? title,
    String? icon,
    ContextMenuActionType? type,
    bool? isEnabled,
    VoidCallback? action,
  }) {
    return ContextMenuAction(
      id: id ?? this.id,
      title: title ?? this.title,
      icon: icon ?? this.icon,
      type: type ?? this.type,
      isEnabled: isEnabled ?? this.isEnabled,
      action: action ?? this.action,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ContextMenuAction &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'icon': icon,
      'type': type.name,
      'isEnabled': isEnabled,
    };
  }

  factory ContextMenuAction.fromJson(Map<String, dynamic> json) {
    return ContextMenuAction(
      id: json['id'] as String,
      title: json['title'] as String,
      icon: json['icon'] as String,
      type: ContextMenuActionType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => ContextMenuActionType.open,
      ),
      isEnabled: json['isEnabled'] as bool,
    );
  }
}
