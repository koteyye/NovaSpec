import 'package:flutter/material.dart';
import 'modern_button.dart';

// Базовый диалог
class CustomDialog extends StatelessWidget {
  final String title;
  final String? content;
  final List<Widget>? actions;
  final Widget? customContent;
  final EdgeInsetsGeometry? contentPadding;
  final double? borderRadius;
  final bool barrierDismissible;

  const CustomDialog({
    super.key,
    required this.title,
    this.content,
    this.actions,
    this.customContent,
    this.contentPadding,
    this.borderRadius,
    this.barrierDismissible = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Padding(
        padding: contentPadding ?? const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Заголовок
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (barrierDismissible)
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                    tooltip: 'Закрыть',
                  ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Контент
            if (customContent != null)
              customContent!
            else if (content != null)
              Text(
                content!,
                style: theme.textTheme.bodyMedium,
              ),
            
            if (actions != null && actions!.isNotEmpty) ...[
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: actions!,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// Диалог подтверждения
class CustomConfirmDialog extends StatelessWidget {
  final String title;
  final String content;
  final String? confirmText;
  final String? cancelText;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final Color? confirmColor;
  final bool barrierDismissible;

  const CustomConfirmDialog({
    super.key,
    required this.title,
    required this.content,
    this.confirmText,
    this.cancelText,
    this.onConfirm,
    this.onCancel,
    this.confirmColor,
    this.barrierDismissible = true,
  });

  @override
  Widget build(BuildContext context) {
    Theme.of(context);
    
    return CustomDialog(
      title: title,
      content: content,
      barrierDismissible: barrierDismissible,
      actions: [
        ModernButton(
          text: cancelText ?? 'Отмена',
          type: ButtonType.secondary,
          onPressed: () {
            Navigator.of(context).pop();
            onCancel?.call();
          },
        ),
        const SizedBox(width: 8),
        ModernButton(
          text: confirmText ?? 'Подтвердить',
          type: ButtonType.primary,
          onPressed: () {
            Navigator.of(context).pop();
            onConfirm?.call();
          },
        ),
      ],
    );
  }
}

// Диалог с вводом текста
class CustomInputDialog extends StatefulWidget {
  final String title;
  final String? content;
  final String? hint;
  final String? initialValue;
  final String? confirmText;
  final String? cancelText;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onConfirm;
  final VoidCallback? onCancel;
  final bool obscureText;
  final TextInputType? keyboardType;

  const CustomInputDialog({
    super.key,
    required this.title,
    this.content,
    this.hint,
    this.initialValue,
    this.confirmText,
    this.cancelText,
    this.validator,
    this.onConfirm,
    this.onCancel,
    this.obscureText = false,
    this.keyboardType,
  });

  @override
  State<CustomInputDialog> createState() => _CustomInputDialogState();
}

class _CustomInputDialogState extends State<CustomInputDialog> {
  late TextEditingController _controller;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleConfirm() {
    if (_formKey.currentState?.validate() ?? false) {
      Navigator.of(context).pop();
      widget.onConfirm?.call(_controller.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomDialog(
      title: widget.title,
      content: widget.content,
      customContent: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.content != null) ...[
              Text(widget.content!),
              const SizedBox(height: 16),
            ],
            TextFormField(
              controller: _controller,
              obscureText: widget.obscureText,
              keyboardType: widget.keyboardType,
              validator: widget.validator,
              decoration: InputDecoration(
                hintText: widget.hint,
                border: const OutlineInputBorder(),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        ModernButton(
          text: widget.cancelText ?? 'Отмена',
          type: ButtonType.secondary,
          onPressed: () {
            Navigator.of(context).pop();
            widget.onCancel?.call();
          },
        ),
        const SizedBox(width: 8),
        ModernButton(
          text: widget.confirmText ?? 'ОК',
          type: ButtonType.primary,
          onPressed: _handleConfirm,
        ),
      ],
    );
  }
}

// Диалог загрузки
class CustomLoadingDialog extends StatelessWidget {
  final String title;
  final String? content;

  const CustomLoadingDialog({
    super.key,
    required this.title,
    this.content,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            if (content != null) ...[
              const SizedBox(height: 8),
              Text(
                content!,
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// Диалог выбора опции
class CustomChoiceDialog<T> extends StatelessWidget {
  final String title;
  final List<CustomChoiceOption<T>> options;
  final T? selectedValue;
  final ValueChanged<T?>? onSelected;
  final String? cancelText;

  const CustomChoiceDialog({
    super.key,
    required this.title,
    required this.options,
    this.selectedValue,
    this.onSelected,
    this.cancelText,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            ...options.map((option) => _buildOption(context, option)),
            const SizedBox(height: 16),
            if (cancelText != null)
              SizedBox(
                width: double.infinity,
                child: ModernButton(
                  text: cancelText!,
                  type: ButtonType.secondary,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildOption(BuildContext context, CustomChoiceOption<T> option) {
    final theme = Theme.of(context);
    final isSelected = option.value == selectedValue;
    
    return InkWell(
      onTap: () {
        Navigator.of(context).pop();
        onSelected?.call(option.value);
      },
      borderRadius: BorderRadius.circular(10.0),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              color: theme.primaryColor,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    option.title,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                  if (option.description != null)
                    Text(
                      option.description!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Модель опции для выбора
class CustomChoiceOption<T> {
  final T value;
  final String title;
  final String? description;

  const CustomChoiceOption({
    required this.value,
    required this.title,
    this.description,
  });
}

// Вспомогательные методы для показа диалогов
class DialogHelper {
  static Future<bool?> showConfirmDialog(
    BuildContext context, {
    required String title,
    required String content,
    String? confirmText,
    String? cancelText,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
    Color? confirmColor,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => CustomConfirmDialog(
        title: title,
        content: content,
        confirmText: confirmText,
        cancelText: cancelText,
        onConfirm: onConfirm,
        onCancel: onCancel,
        confirmColor: confirmColor,
      ),
    );
  }

  static Future<String?> showInputDialog(
    BuildContext context, {
    required String title,
    String? content,
    String? hint,
    String? initialValue,
    String? confirmText,
    String? cancelText,
    String? Function(String?)? validator,
    ValueChanged<String>? onConfirm,
    VoidCallback? onCancel,
    bool obscureText = false,
    TextInputType? keyboardType,
  }) {
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => CustomInputDialog(
        title: title,
        content: content,
        hint: hint,
        initialValue: initialValue,
        confirmText: confirmText,
        cancelText: cancelText,
        validator: validator,
        onConfirm: onConfirm,
        onCancel: onCancel,
        obscureText: obscureText,
        keyboardType: keyboardType,
      ),
    );
  }

  static Future<T?> showChoiceDialog<T>(
    BuildContext context, {
    required String title,
    required List<CustomChoiceOption<T>> options,
    T? selectedValue,
    ValueChanged<T?>? onSelected,
    String? cancelText,
  }) {
    return showDialog<T>(
      context: context,
      builder: (context) => CustomChoiceDialog<T>(
        title: title,
        options: options,
        selectedValue: selectedValue,
        onSelected: onSelected,
        cancelText: cancelText,
      ),
    );
  }

  static void showLoadingDialog(
    BuildContext context, {
    required String title,
    String? content,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => CustomLoadingDialog(
        title: title,
        content: content,
      ),
    );
  }

  static void hideLoadingDialog(BuildContext context) {
    Navigator.of(context).pop();
  }
}
