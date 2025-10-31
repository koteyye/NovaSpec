import 'package:flutter/material.dart';
import '../models/toast_model.dart';
import '../../core/constants/app_constants.dart';
import '../../core/services/toast_service.dart';

class ModernToast extends StatefulWidget {
  final ToastModel toast;
  final VoidCallback? onDismiss;

  const ModernToast({
    super.key,
    required this.toast,
    this.onDismiss,
  });

  @override
  State<ModernToast> createState() => _ModernToastState();
}

class _ModernToastState extends State<ModernToast>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: AppConstants.mediumAnimation,
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 1.0), // Снизу вверх
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _dismiss() {
    _animationController.reverse().then((_) {
      widget.onDismiss?.call();
    });
  }

  Color _getBackgroundColor(BuildContext context) {
    final theme = Theme.of(context);
    switch (widget.toast.variant) {
      case ToastVariant.info:
        return theme.colorScheme.surface;
      case ToastVariant.destructive:
        return const Color(AppConstants.errorColorValue);
      case ToastVariant.success:
        return const Color(AppConstants.successColorValue);
      case ToastVariant.warning:
        return const Color(AppConstants.warningColorValue);
    }
  }

  Color _getForegroundColor(BuildContext context) {
    final theme = Theme.of(context);
    switch (widget.toast.variant) {
      case ToastVariant.info:
        return theme.colorScheme.onSurface;
      case ToastVariant.destructive:
      case ToastVariant.success:
      case ToastVariant.warning:
        return Colors.white;
    }
  }

  Color _getBorderColor(BuildContext context) {
    final theme = Theme.of(context);
    switch (widget.toast.variant) {
      case ToastVariant.info:
        return theme.dividerColor;
      case ToastVariant.destructive:
        return const Color(AppConstants.errorColorValue);
      case ToastVariant.success:
        return const Color(AppConstants.successColorValue);
      case ToastVariant.warning:
        return const Color(AppConstants.warningColorValue);
    }
  }

  IconData _getIcon() {
    switch (widget.toast.variant) {
      case ToastVariant.info:
        return Icons.info_outline;
      case ToastVariant.destructive:
        return Icons.error_outline;
      case ToastVariant.success:
        return Icons.check_circle_outline;
      case ToastVariant.warning:
        return Icons.warning_amber_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = _getBackgroundColor(context);
    final foregroundColor = _getForegroundColor(context);
    final borderColor = _getBorderColor(context);

    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          constraints: const BoxConstraints(
            minWidth: 300,
            maxWidth: 400,
          ),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
            border: Border.all(
              color: borderColor,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
              onTap: widget.toast.dismissible ? _dismiss : null,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Иконка
                    Icon(
                      _getIcon(),
                      color: foregroundColor,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    
                    // Контент
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (widget.toast.title != null) ...[
                            Text(
                              widget.toast.title!,
                              style: TextStyle(
                                color: foregroundColor,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                          ],
                          if (widget.toast.description != null)
                            Text(
                              widget.toast.description!,
                              style: TextStyle(
                                color: foregroundColor.withValues(alpha: 0.9),
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          if (widget.toast.action != null) ...[
                            const SizedBox(height: 8),
                            widget.toast.action!,
                          ],
                        ],
                      ),
                    ),
                    
                    // Кнопка закрытия
                    if (widget.toast.dismissible)
                      GestureDetector(
                        onTap: _dismiss,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          child: Icon(
                            Icons.close,
                            color: foregroundColor.withValues(alpha: 0.7),
                            size: 16,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ToastContainer extends StatefulWidget {
  const ToastContainer({super.key});

  @override
  State<ToastContainer> createState() => _ToastContainerState();
}

class _ToastContainerState extends State<ToastContainer> {
  final ToastService _toastService = ToastService();

  @override
  void initState() {
    super.initState();
    _toastService.addListener(_onToastsChanged);
  }

  @override
  void dispose() {
    _toastService.removeListener(_onToastsChanged);
    super.dispose();
  }

  void _onToastsChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final toasts = _toastService.toasts;
    
    if (toasts.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return SafeArea(
      child: Material(
        color: Colors.transparent,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width - 32,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            // Разворачиваем список, чтобы новые тосты появлялись снизу
            children: toasts.reversed.map((toast) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: ModernToast(
                  key: ValueKey(toast.id),
                  toast: toast,
                  onDismiss: () => _toastService.removeToast(toast.id),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
