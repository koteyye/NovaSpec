import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:novaspec/core/config/theme/ns_colors.dart';
import 'package:novaspec/core/config/theme/ns_spacing.dart';
import 'package:novaspec/core/config/theme/ns_text_styles.dart';
import 'package:novaspec/data/models/chat_message.dart';

/// Виджет для отображения сообщения в чате с AI
class MessageBubble extends StatelessWidget {
  final ChatMessage message;

  const MessageBubble({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isUser = message.role == 'user';

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: NsSpacing.md,
        vertical: NsSpacing.sm,
      ),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // AI avatar (левая сторона)
          if (!isUser) ...[
            _buildAvatar(isDark, isUser: false),
            const SizedBox(width: NsSpacing.sm),
          ],

          // Message content
          Flexible(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 320),
              padding: const EdgeInsets.all(NsSpacing.md),
              decoration: BoxDecoration(
                color: isUser
                    ? (isDark ? NsColorsDark.primary : NsColorsLight.primary)
                    : (isDark
                        ? NsColorsDark.muted
                        : NsColorsLight.muted),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(isUser ? 12 : 4),
                  topRight: Radius.circular(isUser ? 4 : 12),
                  bottomLeft: const Radius.circular(12),
                  bottomRight: const Radius.circular(12),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Message content (Markdown support)
                  MarkdownBody(
                    data: message.content,
                    styleSheet: MarkdownStyleSheet(
                      p: NsTextStyles.bodyMedium(context).copyWith(
                        color: isUser
                            ? (isDark
                                ? NsColorsDark.primaryForeground
                                : NsColorsLight.primaryForeground)
                            : (isDark
                                ? NsColorsDark.foreground
                                : NsColorsLight.foreground),
                      ),
                      code: NsTextStyles.bodyMedium(context).copyWith(
                        fontFamily: 'monospace',
                        backgroundColor: isUser
                            ? (isDark
                                ? NsColorsDark.primaryForeground
                                : NsColorsLight.primaryForeground)
                                .withValues(alpha: 0.1)
                            : (isDark
                                ? NsColorsDark.foreground
                                : NsColorsLight.foreground)
                                .withValues(alpha: 0.1),
                      ),
                      codeblockDecoration: BoxDecoration(
                        color: isUser
                            ? (isDark
                                ? NsColorsDark.primaryForeground
                                : NsColorsLight.primaryForeground)
                                .withValues(alpha: 0.1)
                            : (isDark
                                ? NsColorsDark.foreground
                                : NsColorsLight.foreground)
                                .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),

                  // Timestamp
                  const SizedBox(height: NsSpacing.xs),
                  Text(
                    _formatTimestamp(message.timestamp),
                    style: NsTextStyles.bodySmall(context).copyWith(
                      fontSize: 11,
                      color: isUser
                          ? (isDark
                              ? NsColorsDark.primaryForeground
                              : NsColorsLight.primaryForeground)
                              .withValues(alpha: 0.7)
                          : (isDark
                              ? NsColorsDark.mutedForeground
                              : NsColorsLight.mutedForeground),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // User avatar (правая сторона)
          if (isUser) ...[
            const SizedBox(width: NsSpacing.sm),
            _buildAvatar(isDark, isUser: true),
          ],
        ],
      ),
    );
  }

  Widget _buildAvatar(bool isDark, {required bool isUser}) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: isUser
            ? (isDark ? NsColorsDark.primary : NsColorsLight.primary)
            : (isDark ? NsColorsDark.muted : NsColorsLight.muted),
        shape: BoxShape.circle,
      ),
      child: Icon(
        isUser ? Icons.person_outline : Icons.psychology_outlined,
        size: 18,
        color: isUser
            ? (isDark
                ? NsColorsDark.primaryForeground
                : NsColorsLight.primaryForeground)
            : (isDark ? NsColorsDark.foreground : NsColorsLight.foreground),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Сейчас';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} мин назад';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} ч назад';
    } else {
      final day = timestamp.day.toString().padLeft(2, '0');
      final month = timestamp.month.toString().padLeft(2, '0');
      final hour = timestamp.hour.toString().padLeft(2, '0');
      final minute = timestamp.minute.toString().padLeft(2, '0');
      return '$day.$month в $hour:$minute';
    }
  }
}
