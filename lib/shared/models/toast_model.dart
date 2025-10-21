import 'package:flutter/material.dart';

enum ToastVariant {
  info,
  destructive,
  success,
  warning,
}

class ToastModel {
  final String id;
  final String? title;
  final String? description;
  final ToastVariant variant;
  final Duration duration;
  final bool dismissible;
  final VoidCallback? onDismiss;
  final Widget? action;

  ToastModel({
    required this.id,
    this.title,
    this.description,
    this.variant = ToastVariant.info,
    this.duration = const Duration(seconds: 5),
    this.dismissible = true,
    this.onDismiss,
    this.action,
  });

  ToastModel copyWith({
    String? id,
    String? title,
    String? description,
    ToastVariant? variant,
    Duration? duration,
    bool? dismissible,
    VoidCallback? onDismiss,
    Widget? action,
  }) {
    return ToastModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      variant: variant ?? this.variant,
      duration: duration ?? this.duration,
      dismissible: dismissible ?? this.dismissible,
      onDismiss: onDismiss ?? this.onDismiss,
      action: action ?? this.action,
    );
  }
}