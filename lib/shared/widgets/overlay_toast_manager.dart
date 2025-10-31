import 'package:flutter/material.dart';
import '../../features/project/providers/project_provider.dart';

/// Менеджер для отображения тостов в оверлее поверх всех окон
class OverlayToastManager {
  static OverlayEntry? _overlayEntry;
  static bool _isInserted = false;

  /// Показать оверлей с тостами используя глобальный navigatorKey
  static void showOverlay() {
    // Временно отключаем, так как используем простой подход с Positioned
    _isInserted = true;
  }

  /// Скрыть оверлей
  static void hideOverlay() {
    if (_overlayEntry != null && _isInserted) {
      _overlayEntry?.remove();
      _overlayEntry = null;
      _isInserted = false;
    }
  }

  /// Проверить, отображен ли оверлей
  static bool get isOverlayShown => _isInserted;

  /// Обновить оверлей (пересоздать)
  static void refreshOverlay() {
    hideOverlay();
    showOverlay();
  }
}

/// Виджет-обертка для автоматического управления оверлеем тостов
class ToastOverlayProvider extends StatefulWidget {
  final Widget child;

  const ToastOverlayProvider({
    super.key,
    required this.child,
  });

  @override
  State<ToastOverlayProvider> createState() => _ToastOverlayProviderState();
}

class _ToastOverlayProviderState extends State<ToastOverlayProvider> 
    with WidgetsBindingObserver {
  bool _isOverlayShown = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    // Показываем оверлей после инициализации навигации
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Проверяем готовность navigatorKey и пробуем несколько раз
      _tryShowOverlay();
    });
  }

  void _tryShowOverlay() {
    if (!mounted) return;
    
    final navigatorState = ProjectProvider.navigatorKey.currentState;
    if (navigatorState != null && navigatorState.context.mounted) {
      _showToastOverlay();
    } else {
      // Если еще не готово, пробуем через небольшую задержку
      Future.delayed(const Duration(milliseconds: 200), () {
        _tryShowOverlay();
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    OverlayToastManager.hideOverlay();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        if (!_isOverlayShown) {
          _showToastOverlay();
        }
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        OverlayToastManager.hideOverlay();
        _isOverlayShown = false;
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
        break;
    }
  }

  void _showToastOverlay() {
    if (mounted && !_isOverlayShown) {
      OverlayToastManager.showOverlay();
      _isOverlayShown = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
