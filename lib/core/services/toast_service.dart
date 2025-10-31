import 'dart:async';
import 'package:flutter/material.dart';
import '../../shared/models/toast_model.dart';

class ToastService extends ChangeNotifier {
  static final ToastService _instance = ToastService._internal();
  factory ToastService() => _instance;
  ToastService._internal();

  final List<ToastModel> _toasts = [];
  final Map<String, Timer> _timers = {};
  int _toastCounter = 0;

  List<ToastModel> get toasts => List.unmodifiable(_toasts);

  String _generateId() {
    return 'toast_${++_toastCounter}_${DateTime.now().millisecondsSinceEpoch}';
  }

  void showToast({
    String? title,
    String? description,
    ToastVariant variant = ToastVariant.info,
    Duration? duration,
    bool dismissible = true,
    VoidCallback? onDismiss,
    Widget? action,
  }) {
    final id = _generateId();
    final toast = ToastModel(
      id: id,
      title: title,
      description: description,
      variant: variant,
      duration: duration ?? const Duration(seconds: 5),
      dismissible: dismissible,
      onDismiss: onDismiss,
      action: action,
    );

    _addToast(toast);
  }

  void showSuccess({
    String? title,
    String? description,
    Duration? duration,
    VoidCallback? onDismiss,
    Widget? action,
  }) {
    showToast(
      title: title ?? 'Успешно',
      description: description,
      variant: ToastVariant.success,
      duration: duration,
      onDismiss: onDismiss,
      action: action,
    );
  }

  void showError({
    String? title,
    String? description,
    Duration? duration,
    VoidCallback? onDismiss,
    Widget? action,
  }) {
    showToast(
      title: title ?? 'Ошибка',
      description: description,
      variant: ToastVariant.destructive,
      duration: duration ?? const Duration(seconds: 8),
      onDismiss: onDismiss,
      action: action,
    );
  }

  void showWarning({
    String? title,
    String? description,
    Duration? duration,
    VoidCallback? onDismiss,
    Widget? action,
  }) {
    showToast(
      title: title ?? 'Предупреждение',
      description: description,
      variant: ToastVariant.warning,
      duration: duration,
      onDismiss: onDismiss,
      action: action,
    );
  }

  void _addToast(ToastModel toast) {
    // Ограничиваем количество тостов до 3 (как в референсе)
    if (_toasts.length >= 3) {
      final oldestToast = _toasts.removeLast();
      _cancelTimer(oldestToast.id);
    }

    _toasts.insert(0, toast);
    _scheduleRemoval(toast);
    notifyListeners();
  }

  void _scheduleRemoval(ToastModel toast) {
    _cancelTimer(toast.id);
    
    _timers[toast.id] = Timer(toast.duration, () {
      removeToast(toast.id);
    });
  }

  void _cancelTimer(String id) {
    final timer = _timers.remove(id);
    timer?.cancel();
  }

  void removeToast(String id) {
    _toasts.removeWhere((toast) => toast.id == id);
    _cancelTimer(id);
    notifyListeners();
  }

  void dismissToast(String id) {
    final toast = _toasts.where((t) => t.id == id).firstOrNull;
    if (toast != null) {
      toast.onDismiss?.call();
      removeToast(id);
    }
  }

  void clearAll() {
    for (final toast in _toasts) {
      _cancelTimer(toast.id);
    }
    _toasts.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    clearAll();
    super.dispose();
  }
}

// Глобальные методы для удобного доступа
void show({
  String? title,
  String? description,
  ToastVariant variant = ToastVariant.info,
  Duration? duration,
  bool dismissible = true,
  VoidCallback? onDismiss,
  Widget? action,
}) {
  ToastService().showToast(
    title: title,
    description: description,
    variant: variant,
    duration: duration,
    dismissible: dismissible,
    onDismiss: onDismiss,
    action: action,
  );
}

void success({
  String? title,
  String? description,
  Duration? duration,
  VoidCallback? onDismiss,
  Widget? action,
}) {
  ToastService().showSuccess(
    title: title,
    description: description,
    duration: duration,
    onDismiss: onDismiss,
    action: action,
  );
}

void error({
  String? title,
  String? description,
  Duration? duration,
  VoidCallback? onDismiss,
  Widget? action,
}) {
  ToastService().showError(
    title: title,
    description: description,
    duration: duration,
    onDismiss: onDismiss,
    action: action,
  );
}

void warning({
  String? title,
  String? description,
  Duration? duration,
  VoidCallback? onDismiss,
  Widget? action,
}) {
  ToastService().showWarning(
    title: title,
    description: description,
    duration: duration,
    onDismiss: onDismiss,
    action: action,
  );
}
