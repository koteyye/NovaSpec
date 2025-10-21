import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextField extends StatefulWidget {
  final String? label;
  final String? hint;
  final String? initialValue;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final bool obscureText;
  final bool readOnly;
  final bool enabled;
  final int? maxLines;
  final int? minLines;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final Color? fillColor;
  final Color? borderColor;
  final double borderRadius;
  final EdgeInsetsGeometry? contentPadding;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final VoidCallback? onEditingComplete;
  final ValueChanged<String>? onSubmitted;
  final bool autofocus;
  final int? maxLength;
  final bool showCounter;

  const CustomTextField({
    super.key,
    this.label,
    this.hint,
    this.initialValue,
    this.controller,
    this.onChanged,
    this.onTap,
    this.obscureText = false,
    this.readOnly = false,
    this.enabled = true,
    this.maxLines = 1,
    this.minLines,
    this.keyboardType,
    this.inputFormatters,
    this.validator,
    this.prefixIcon,
    this.suffixIcon,
    this.fillColor,
    this.borderColor,
    this.borderRadius = 10.0,
    this.contentPadding,
    this.focusNode,
    this.textInputAction,
    this.onEditingComplete,
    this.onSubmitted,
    this.autofocus = false,
    this.maxLength,
    this.showCounter = false,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late bool _obscureText;
  late FocusNode _focusNode;
  late ThemeData _theme;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _theme = Theme.of(context);
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _onFocusChange() {
    // Focus changed, UI updates automatically through FocusNode
  }

  void _toggleObscureText() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: _theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
        ],
        TextFormField(
          controller: widget.controller,
          initialValue: widget.initialValue,
          onChanged: widget.onChanged,
          onTap: widget.onTap,
          obscureText: _obscureText,
          readOnly: widget.readOnly,
          enabled: widget.enabled,
          maxLines: widget.maxLines,
          minLines: widget.minLines,
          keyboardType: widget.keyboardType,
          inputFormatters: widget.inputFormatters,
          validator: widget.validator,
          focusNode: _focusNode,
          textInputAction: widget.textInputAction,
          onEditingComplete: widget.onEditingComplete,
          onFieldSubmitted: widget.onSubmitted,
          autofocus: widget.autofocus,
          maxLength: widget.maxLength,
          decoration: InputDecoration(
            hintText: widget.hint,
            prefixIcon: widget.prefixIcon,
            suffixIcon: _buildSuffixIcon(),
            fillColor: widget.fillColor,
            filled: true,
            contentPadding: widget.contentPadding ?? 
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              borderSide: BorderSide(color: widget.borderColor ?? Colors.grey),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              borderSide: BorderSide(
                color: widget.borderColor ?? Colors.grey,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              borderSide: BorderSide(
                color: _theme.primaryColor,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              borderSide: const BorderSide(color: Colors.red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              borderSide: BorderSide(
                color: Colors.grey.shade300,
              ),
            ),
            counterText: widget.showCounter ? null : '',
          ),
        ),
      ],
    );
  }

  Widget? _buildSuffixIcon() {
    if (widget.obscureText) {
      return IconButton(
        icon: Icon(
          _obscureText ? Icons.visibility_off : Icons.visibility,
          color: Colors.grey,
        ),
        onPressed: _toggleObscureText,
      );
    }
    return widget.suffixIcon;
  }
}

// Поле для поиска
class CustomSearchField extends StatefulWidget {
  final String? hint;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;
  final TextEditingController? controller;
  final bool autofocus;
  final Widget? prefixIcon;

  const CustomSearchField({
    super.key,
    this.hint,
    this.onChanged,
    this.onClear,
    this.controller,
    this.autofocus = false,
    this.prefixIcon,
  });

  @override
  State<CustomSearchField> createState() => _CustomSearchFieldState();
}

class _CustomSearchFieldState extends State<CustomSearchField> {
  late TextEditingController _controller;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _controller.addListener(_onTextChanged);
    _hasText = _controller.text.isNotEmpty;
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = _controller.text.isNotEmpty;
    if (hasText != _hasText) {
      setState(() {
        _hasText = hasText;
      });
    }
    widget.onChanged?.call(_controller.text);
  }

  void _onClear() {
    _controller.clear();
    widget.onClear?.call();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return TextField(
      controller: _controller,
      autofocus: widget.autofocus,
      decoration: InputDecoration(
        hintText: widget.hint ?? 'Поиск...',
        prefixIcon: widget.prefixIcon ?? const Icon(Icons.search),
        suffixIcon: _hasText
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: _onClear,
              )
            : null,
        filled: true,
        fillColor: theme.inputDecorationTheme.fillColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(color: theme.dividerColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(color: theme.dividerColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(color: theme.primaryColor, width: 2),
        ),
      ),
    );
  }
}