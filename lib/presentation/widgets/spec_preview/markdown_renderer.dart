import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:novaspec/core/config/theme/ns_colors.dart';
import 'package:novaspec/core/config/theme/ns_spacing.dart';
import 'package:novaspec/core/config/theme/ns_text_styles.dart';
import 'package:url_launcher/url_launcher.dart';

/// Расширенный рендерер Markdown с поддержкой таблиц, кода и других элементов
class MarkdownRenderer extends StatelessWidget {
  final String data;
  final bool selectable;

  const MarkdownRenderer({
    super.key,
    required this.data,
    this.selectable = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Markdown(
      data: data,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      selectable: selectable,
      styleSheet: _buildStyleSheet(context, isDark),
      extensionSet: md.ExtensionSet.gitHubFlavored,
      onTapLink: (text, href, title) {
        if (href != null) {
          _handleLinkTap(href);
        }
      },
      builders: {
        'code': CodeElementBuilder(isDark: isDark),
      },
    );
  }

  /// Создать кастомную таблицу стилей
  MarkdownStyleSheet _buildStyleSheet(BuildContext context, bool isDark) {
    final baseStyle = NsTextStyles.bodyMedium(context);
    final codeColor = isDark ? NsColorsDark.muted : NsColorsLight.muted;
    final borderColor = isDark ? NsColorsDark.border : NsColorsLight.border;
    final codeTextColor = isDark ? NsColorsDark.foreground : NsColorsLight.foreground;
    final linkColor = isDark ? NsColorsDark.primary : NsColorsLight.primary;

    return MarkdownStyleSheet(
      // Заголовки
      h1: NsTextStyles.h1(context),
      h1Padding: const EdgeInsets.only(top: NsSpacing.lg, bottom: NsSpacing.md),
      h2: NsTextStyles.h2(context),
      h2Padding: const EdgeInsets.only(top: NsSpacing.lg, bottom: NsSpacing.md),
      h3: NsTextStyles.h3(context),
      h3Padding: const EdgeInsets.only(top: NsSpacing.md, bottom: NsSpacing.sm),
      h4: NsTextStyles.h4(context),
      h4Padding: const EdgeInsets.only(top: NsSpacing.md, bottom: NsSpacing.sm),
      h5: baseStyle.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
      h5Padding: const EdgeInsets.only(top: NsSpacing.sm, bottom: NsSpacing.xs),
      h6: baseStyle.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      h6Padding: const EdgeInsets.only(top: NsSpacing.sm, bottom: NsSpacing.xs),

      // Параграфы и текст
      p: baseStyle,
      pPadding: const EdgeInsets.symmetric(vertical: NsSpacing.sm),
      strong: baseStyle.copyWith(fontWeight: FontWeight.bold),
      em: baseStyle.copyWith(fontStyle: FontStyle.italic),
      del: baseStyle.copyWith(
        decoration: TextDecoration.lineThrough,
      ),

      // Ссылки
      a: baseStyle.copyWith(
        color: linkColor,
        decoration: TextDecoration.underline,
      ),

      // Списки
      listBullet: baseStyle,
      listIndent: NsSpacing.xl,

      // Блоки кода
      code: TextStyle(
        fontFamily: 'monospace',
        fontSize: 13,
        color: codeTextColor,
        backgroundColor: codeColor,
      ),
      codeblockDecoration: BoxDecoration(
        color: codeColor,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: borderColor),
      ),
      codeblockPadding: const EdgeInsets.all(NsSpacing.md),

      // Цитаты
      blockquote: baseStyle.copyWith(
        color: isDark ? NsColorsDark.mutedForeground : NsColorsLight.mutedForeground,
      ),
      blockquoteDecoration: BoxDecoration(
        color: codeColor,
        border: Border(
          left: BorderSide(
            color: linkColor,
            width: 4,
          ),
        ),
      ),
      blockquotePadding: const EdgeInsets.symmetric(
        horizontal: NsSpacing.md,
        vertical: NsSpacing.sm,
      ),

      // Таблицы
      tableHead: baseStyle.copyWith(
        fontWeight: FontWeight.bold,
      ),
      tableBody: baseStyle,
      tableBorder: TableBorder.all(
        color: borderColor,
        width: 1,
      ),
      tableCellsPadding: const EdgeInsets.all(NsSpacing.sm),
      tableColumnWidth: const FlexColumnWidth(),

      // Горизонтальная линия
      horizontalRuleDecoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: borderColor,
            width: 1,
          ),
        ),
      ),

      // Чекбоксы в задачах
      checkbox: baseStyle.copyWith(
        color: linkColor,
      ),
    );
  }

  /// Обработка клика по ссылке
  Future<void> _handleLinkTap(String href) async {
    try {
      final uri = Uri.parse(href);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      // Ignore link errors
    }
  }
}

/// Кастомный билдер для блоков кода с подсветкой синтаксиса
class CodeElementBuilder extends MarkdownElementBuilder {
  final bool isDark;

  CodeElementBuilder({required this.isDark});

  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    final String textContent = element.textContent;
    final String? language = element.attributes['class']?.replaceFirst('language-', '');

    final codeColor = isDark ? NsColorsDark.muted : NsColorsLight.muted;
    final borderColor = isDark ? NsColorsDark.border : NsColorsLight.border;
    final textColor = isDark ? NsColorsDark.foreground : NsColorsLight.foreground;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: NsSpacing.sm),
      decoration: BoxDecoration(
        color: codeColor,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Заголовок с языком (если указан)
          if (language != null && language.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: NsSpacing.md,
                vertical: NsSpacing.xs,
              ),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: borderColor),
                ),
              ),
              child: Text(
                language.toUpperCase(),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isDark ? NsColorsDark.mutedForeground : NsColorsLight.mutedForeground,
                  fontFamily: 'monospace',
                ),
              ),
            ),

          // Код
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(NsSpacing.md),
            child: SelectableText(
              textContent,
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 13,
                color: textColor,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
