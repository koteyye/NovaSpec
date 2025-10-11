import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:novaspec/core/config/theme/ns_colors.dart';
import 'package:novaspec/core/config/theme/ns_spacing.dart';
import 'package:novaspec/core/config/theme/ns_text_styles.dart';
import 'package:url_launcher/url_launcher.dart';

/// Рендерер HTML с поддержкой кастомных стилей
class HtmlRenderer extends StatelessWidget {
  final String data;

  const HtmlRenderer({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseStyle = NsTextStyles.bodyMedium(context);

    return Html(
      data: data,
      style: {
        // Основные элементы
        'body': Style(
          margin: Margins.zero,
          padding: HtmlPaddings.zero,
          fontSize: FontSize(baseStyle.fontSize ?? 14),
          color: isDark ? NsColorsDark.foreground : NsColorsLight.foreground,
        ),

        // Заголовки
        'h1': Style.fromTextStyle(NsTextStyles.h1(context)).copyWith(
          margin: Margins.only(top: NsSpacing.lg, bottom: NsSpacing.md),
        ),
        'h2': Style.fromTextStyle(NsTextStyles.h2(context)).copyWith(
          margin: Margins.only(top: NsSpacing.lg, bottom: NsSpacing.md),
        ),
        'h3': Style.fromTextStyle(NsTextStyles.h3(context)).copyWith(
          margin: Margins.only(top: NsSpacing.md, bottom: NsSpacing.sm),
        ),
        'h4': Style.fromTextStyle(NsTextStyles.h4(context)).copyWith(
          margin: Margins.only(top: NsSpacing.md, bottom: NsSpacing.sm),
        ),

        // Параграфы
        'p': Style(
          margin: Margins.symmetric(vertical: NsSpacing.sm),
        ),

        // Ссылки
        'a': Style(
          color: isDark ? NsColorsDark.primary : NsColorsLight.primary,
          textDecoration: TextDecoration.underline,
        ),

        // Списки
        'ul': Style(
          margin: Margins.symmetric(vertical: NsSpacing.sm),
          padding: HtmlPaddings.only(left: NsSpacing.xl),
        ),
        'ol': Style(
          margin: Margins.symmetric(vertical: NsSpacing.sm),
          padding: HtmlPaddings.only(left: NsSpacing.xl),
        ),
        'li': Style(
          margin: Margins.only(bottom: NsSpacing.xs),
        ),

        // Код
        'code': Style(
          fontFamily: 'monospace',
          fontSize: FontSize(13),
          backgroundColor: isDark ? NsColorsDark.muted : NsColorsLight.muted,
          padding: HtmlPaddings.symmetric(horizontal: 4, vertical: 2),
          border: Border.all(
            color: isDark ? NsColorsDark.border : NsColorsLight.border,
          ),
        ),
        'pre': Style(
          fontFamily: 'monospace',
          fontSize: FontSize(13),
          backgroundColor: isDark ? NsColorsDark.muted : NsColorsLight.muted,
          padding: HtmlPaddings.all(NsSpacing.md),
          margin: Margins.symmetric(vertical: NsSpacing.sm),
          border: Border.all(
            color: isDark ? NsColorsDark.border : NsColorsLight.border,
          ),
        ),

        // Цитаты
        'blockquote': Style(
          backgroundColor: isDark ? NsColorsDark.muted : NsColorsLight.muted,
          padding: HtmlPaddings.symmetric(horizontal: NsSpacing.md, vertical: NsSpacing.sm),
          margin: Margins.symmetric(vertical: NsSpacing.sm),
          border: Border(
            left: BorderSide(
              color: isDark ? NsColorsDark.primary : NsColorsLight.primary,
              width: 4,
            ),
          ),
        ),

        // Таблицы
        'table': Style(
          margin: Margins.symmetric(vertical: NsSpacing.sm),
          border: Border.all(
            color: isDark ? NsColorsDark.border : NsColorsLight.border,
          ),
        ),
        'th': Style(
          backgroundColor: isDark ? NsColorsDark.muted : NsColorsLight.muted,
          padding: HtmlPaddings.all(NsSpacing.sm),
          fontWeight: FontWeight.bold,
          border: Border.all(
            color: isDark ? NsColorsDark.border : NsColorsLight.border,
          ),
        ),
        'td': Style(
          padding: HtmlPaddings.all(NsSpacing.sm),
          border: Border.all(
            color: isDark ? NsColorsDark.border : NsColorsLight.border,
          ),
        ),

        // Горизонтальная линия
        'hr': Style(
          margin: Margins.symmetric(vertical: NsSpacing.md),
          border: Border(
            top: BorderSide(
              color: isDark ? NsColorsDark.border : NsColorsLight.border,
            ),
          ),
        ),

        // Текстовое форматирование
        'strong': Style(fontWeight: FontWeight.bold),
        'b': Style(fontWeight: FontWeight.bold),
        'em': Style(fontStyle: FontStyle.italic),
        'i': Style(fontStyle: FontStyle.italic),
        'del': Style(textDecoration: TextDecoration.lineThrough),
        'u': Style(textDecoration: TextDecoration.underline),

        // Изображения
        'img': Style(
          margin: Margins.symmetric(vertical: NsSpacing.sm),
        ),
      },
      onLinkTap: (url, attributes, element) {
        if (url != null) {
          _handleLinkTap(url);
        }
      },
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
