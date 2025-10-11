import 'package:flutter/material.dart';

/// Размеры текста в NovaSpec
class NsTextSizes {
  // Заголовки
  static const double h1 = 32.0; // 2rem
  static const double h2 = 24.0; // 1.5rem
  static const double h3 = 20.0; // 1.25rem
  static const double h4 = 18.0; // 1.125rem

  // Основной текст
  static const double bodyLarge = 16.0; // 1rem
  static const double bodyMedium = 14.0; // 0.875rem
  static const double bodySmall = 12.0; // 0.75rem

  // Дополнительный текст
  static const double caption = 11.0; // 0.6875rem
  static const double overline = 10.0; // 0.625rem
}

/// Высота строки
class NsLineHeights {
  static const double tight = 1.2;
  static const double normal = 1.5;
  static const double relaxed = 1.75;
  static const double loose = 2.0;
}

/// Веса шрифтов
class NsFontWeights {
  static const FontWeight light = FontWeight.w300;
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;
}

/// Стили текста для NovaSpec
class NsTextStyles {
  // Заголовки
  static TextStyle h1(BuildContext context) => TextStyle(
        fontSize: NsTextSizes.h1,
        fontWeight: NsFontWeights.bold,
        height: NsLineHeights.tight,
        color: Theme.of(context).colorScheme.onSurface,
      );

  static TextStyle h2(BuildContext context) => TextStyle(
        fontSize: NsTextSizes.h2,
        fontWeight: NsFontWeights.semiBold,
        height: NsLineHeights.tight,
        color: Theme.of(context).colorScheme.onSurface,
      );

  static TextStyle h3(BuildContext context) => TextStyle(
        fontSize: NsTextSizes.h3,
        fontWeight: NsFontWeights.semiBold,
        height: NsLineHeights.normal,
        color: Theme.of(context).colorScheme.onSurface,
      );

  static TextStyle h4(BuildContext context) => TextStyle(
        fontSize: NsTextSizes.h4,
        fontWeight: NsFontWeights.medium,
        height: NsLineHeights.normal,
        color: Theme.of(context).colorScheme.onSurface,
      );

  // Основной текст
  static TextStyle bodyLarge(BuildContext context) => TextStyle(
        fontSize: NsTextSizes.bodyLarge,
        fontWeight: NsFontWeights.regular,
        height: NsLineHeights.normal,
        color: Theme.of(context).colorScheme.onSurface,
      );

  static TextStyle bodyMedium(BuildContext context) => TextStyle(
        fontSize: NsTextSizes.bodyMedium,
        fontWeight: NsFontWeights.regular,
        height: NsLineHeights.normal,
        color: Theme.of(context).colorScheme.onSurface,
      );

  static TextStyle bodySmall(BuildContext context) => TextStyle(
        fontSize: NsTextSizes.bodySmall,
        fontWeight: NsFontWeights.regular,
        height: NsLineHeights.normal,
        color: Theme.of(context).colorScheme.onSurface,
      );

  // Специальные
  static TextStyle caption(BuildContext context) => TextStyle(
        fontSize: NsTextSizes.caption,
        fontWeight: NsFontWeights.regular,
        height: NsLineHeights.normal,
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
      );

  static TextStyle button(BuildContext context) => TextStyle(
        fontSize: NsTextSizes.bodyMedium,
        fontWeight: NsFontWeights.medium,
        height: 1.0,
        letterSpacing: 0.5,
        color: Theme.of(context).colorScheme.onPrimary,
      );

  // Моноширинный (для кода)
  static TextStyle code(BuildContext context) => TextStyle(
        fontSize: NsTextSizes.bodyMedium,
        fontWeight: NsFontWeights.regular,
        fontFamily: 'JetBrainsMono',
        height: NsLineHeights.relaxed,
        color: Theme.of(context).colorScheme.onSurface,
      );
}
