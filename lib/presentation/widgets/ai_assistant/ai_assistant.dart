import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:novaspec/core/config/theme/ns_colors.dart';
import 'package:novaspec/core/config/theme/ns_spacing.dart';
import 'package:novaspec/core/config/theme/ns_text_styles.dart';

/// Режимы работы AI ассистента
enum AIAssistantMode {
  chat,
  review,
  generate,
}

/// AIAssistant виджет
class AIAssistant extends ConsumerStatefulWidget {
  const AIAssistant({super.key});

  @override
  ConsumerState<AIAssistant> createState() => _AIAssistantState();
}

class _AIAssistantState extends ConsumerState<AIAssistant> {
  AIAssistantMode _mode = AIAssistantMode.chat;
  bool _isExpanded = true;
  final _messageController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (!_isExpanded) {
      return _buildCollapsed(context, isDark);
    }

    return Container(
      width: 400,
      decoration: BoxDecoration(
        color: isDark ? NsColorsDark.panel : NsColorsLight.panel,
        border: Border(
          left: BorderSide(
            color: isDark ? NsColorsDark.border : NsColorsLight.border,
          ),
        ),
      ),
      child: Column(
        children: [
          _buildToolbar(context, isDark),
          Expanded(
            child: _buildMessagesArea(context, isDark),
          ),
          _buildInputPanel(context, isDark),
        ],
      ),
    );
  }

  Widget _buildCollapsed(BuildContext context, bool isDark) {
    return Container(
      width: 48,
      decoration: BoxDecoration(
        color: isDark ? NsColorsDark.panel : NsColorsLight.panel,
        border: Border(
          left: BorderSide(
            color: isDark ? NsColorsDark.border : NsColorsLight.border,
          ),
        ),
      ),
      child: Column(
        children: [
          Container(
            height: 48,
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: isDark ? NsColorsDark.border : NsColorsLight.border,
                ),
              ),
            ),
            child: IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: () {
                setState(() {
                  _isExpanded = true;
                });
              },
              tooltip: 'Expand AI Assistant',
            ),
          ),
          const SizedBox(height: NsSpacing.md),
          RotatedBox(
            quarterTurns: 3,
            child: Text(
              'AI Assistant',
              style: NsTextStyles.bodySmall(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolbar(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: NsSpacing.sm),
      height: 48,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isDark ? NsColorsDark.border : NsColorsLight.border,
          ),
        ),
      ),
      child: Row(
        children: [
          // Mode buttons
          _buildModeButton(
            context,
            isDark,
            Icons.chat_bubble_outline,
            AIAssistantMode.chat,
            'Chat',
          ),
          const SizedBox(width: NsSpacing.xs),
          _buildModeButton(
            context,
            isDark,
            Icons.rate_review_outlined,
            AIAssistantMode.review,
            'Review',
          ),
          const SizedBox(width: NsSpacing.xs),
          _buildModeButton(
            context,
            isDark,
            Icons.auto_awesome_outlined,
            AIAssistantMode.generate,
            'Generate',
          ),

          const Spacer(),

          // Action buttons
          IconButton(
            icon: const Icon(Icons.add, size: 18),
            onPressed: () {
              // TODO: New chat
            },
            tooltip: 'New Chat',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: NsSpacing.sm),
          IconButton(
            icon: const Icon(Icons.history, size: 18),
            onPressed: () {
              // TODO: Chat history
            },
            tooltip: 'History',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: NsSpacing.sm),
          IconButton(
            icon: const Icon(Icons.chevron_right, size: 18),
            onPressed: () {
              setState(() {
                _isExpanded = false;
              });
            },
            tooltip: 'Collapse',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildModeButton(
    BuildContext context,
    bool isDark,
    IconData icon,
    AIAssistantMode mode,
    String tooltip,
  ) {
    final isActive = _mode == mode;

    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: () {
          setState(() {
            _mode = mode;
          });
        },
        borderRadius: BorderRadius.circular(4),
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: isActive
                ? (isDark ? NsColorsDark.primary : NsColorsLight.primary).withValues(alpha: 0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Icon(
            icon,
            size: 18,
            color: isActive
                ? (isDark ? NsColorsDark.primary : NsColorsLight.primary)
                : (isDark ? NsColorsDark.mutedForeground : NsColorsLight.mutedForeground),
          ),
        ),
      ),
    );
  }

  Widget _buildMessagesArea(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(NsSpacing.md),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.psychology_outlined,
              size: 48,
              color: isDark ? NsColorsDark.mutedForeground : NsColorsLight.mutedForeground,
            ),
            const SizedBox(height: NsSpacing.md),
            Text(
              _getModeTitle(),
              style: NsTextStyles.h3(context).copyWith(
                color: isDark ? NsColorsDark.mutedForeground : NsColorsLight.mutedForeground,
              ),
            ),
            const SizedBox(height: NsSpacing.sm),
            Text(
              _getModeDescription(),
              style: NsTextStyles.bodyMedium(context).copyWith(
                color: isDark ? NsColorsDark.mutedForeground : NsColorsLight.mutedForeground,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  String _getModeTitle() {
    switch (_mode) {
      case AIAssistantMode.chat:
        return 'AI Chat';
      case AIAssistantMode.review:
        return 'AI Review';
      case AIAssistantMode.generate:
        return 'AI Generate';
    }
  }

  String _getModeDescription() {
    switch (_mode) {
      case AIAssistantMode.chat:
        return 'Ask questions about your specification';
      case AIAssistantMode.review:
        return 'Get AI feedback on your document';
      case AIAssistantMode.generate:
        return 'Generate specification content';
    }
  }

  Widget _buildInputPanel(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(NsSpacing.md),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: isDark ? NsColorsDark.border : NsColorsLight.border,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              maxLines: null,
              style: NsTextStyles.bodyMedium(context),
              decoration: InputDecoration(
                hintText: _getInputPlaceholder(),
                hintStyle: TextStyle(
                  color: isDark ? NsColorsDark.mutedForeground : NsColorsLight.mutedForeground,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: isDark ? NsColorsDark.border : NsColorsLight.border,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: isDark ? NsColorsDark.border : NsColorsLight.border,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: isDark ? NsColorsDark.primary : NsColorsLight.primary,
                    width: 2,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: NsSpacing.md,
                  vertical: NsSpacing.sm,
                ),
              ),
            ),
          ),
          const SizedBox(width: NsSpacing.sm),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: () {
              // TODO: Send message
            },
            style: IconButton.styleFrom(
              backgroundColor: isDark ? NsColorsDark.primary : NsColorsLight.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  String _getInputPlaceholder() {
    switch (_mode) {
      case AIAssistantMode.chat:
        return 'Ask a question...';
      case AIAssistantMode.review:
        return 'Request review...';
      case AIAssistantMode.generate:
        return 'Describe what to generate...';
    }
  }
}
