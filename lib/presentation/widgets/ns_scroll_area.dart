import 'package:flutter/material.dart';
import 'package:novaspec/core/config/theme/ns_colors.dart';

/// Область прокрутки с кастомным скроллбаром NovaSpec
class NsScrollArea extends StatefulWidget {
  final Widget child;
  final ScrollController? controller;
  final Axis scrollDirection;

  const NsScrollArea({
    super.key,
    required this.child,
    this.controller,
    this.scrollDirection = Axis.vertical,
  });

  @override
  State<NsScrollArea> createState() => _NsScrollAreaState();
}

class _NsScrollAreaState extends State<NsScrollArea> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = widget.controller ?? ScrollController();
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _scrollController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      controller: _scrollController,
      thumbVisibility: false,
      thickness: 8,
      radius: const Radius.circular(9999),
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(
          scrollbars: false,
        ),
        child: SingleChildScrollView(
          controller: _scrollController,
          scrollDirection: widget.scrollDirection,
          child: widget.child,
        ),
      ),
    );
  }
}

/// Кастомный скроллбар для более детального контроля
class NsCustomScrollbar extends StatelessWidget {
  final Widget child;
  final ScrollController? controller;
  final Axis scrollDirection;

  const NsCustomScrollbar({
    super.key,
    required this.child,
    this.controller,
    this.scrollDirection = Axis.vertical,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return RawScrollbar(
      controller: controller,
      thumbVisibility: false,
      thickness: 8,
      radius: const Radius.circular(9999),
      thumbColor: (isDark ? NsColorsDark.mutedForeground : NsColorsLight.mutedForeground)
          .withValues(alpha: 0.3),
      child: child,
    );
  }
}
