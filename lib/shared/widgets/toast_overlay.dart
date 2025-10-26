import 'package:flutter/material.dart';
import 'modern_toast.dart';

/// Оверлей для отображения тостов поверх всех окон включая модалки
class ToastOverlay extends StatefulWidget {
  final Widget child;

  const ToastOverlay({
    super.key,
    required this.child,
  });

  @override
  State<ToastOverlay> createState() => _ToastOverlayState();
}

class _ToastOverlayState extends State<ToastOverlay> {
  bool _overlayInserted = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _insertOverlay();
    });
  }

  void _insertOverlay() {
    if (_overlayInserted) return;

    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
        builder: (context) => const Positioned(
          bottom: 20,
          right: 20,
          child: ToastContainer(),
        ),
      );

    overlay.insert(overlayEntry);
    _overlayInserted = true;
  }

  @override
  void dispose() {
    // Оверлей будет автоматически удален при dispose виджета
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

/// Более простой вариант - используем Material с ключом навигации
class ToastOverlayWrapper extends StatelessWidget {
  final Widget child;
  final GlobalKey<NavigatorState> navigatorKey;

  const ToastOverlayWrapper({
    super.key,
    required this.child,
    required this.navigatorKey,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        // Тосты в оверлее используя тот же контекст навигации
        Positioned(
          bottom: 20,
          right: 20,
          child: Builder(
            builder: (context) => const ToastContainer(),
          ),
        ),
      ],
    );
  }
}
