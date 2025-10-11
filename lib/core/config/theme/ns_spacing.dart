import 'package:flutter/material.dart';

/// Система отступов NovaSpec
class NsSpacing {
  // Базовая единица: 4px
  static const double unit = 4.0;

  // Отступы
  static const double xxs = 2.0; // 0.5 unit
  static const double xs = 4.0; // 1 unit
  static const double sm = 8.0; // 2 units
  static const double md = 12.0; // 3 units
  static const double lg = 16.0; // 4 units
  static const double xl = 24.0; // 6 units
  static const double xxl = 32.0; // 8 units
  static const double xxxl = 48.0; // 12 units

  // Специфичные отступы для компонентов
  static const double buttonPaddingHorizontal = 24.0;
  static const double buttonPaddingVertical = 12.0;
  static const double inputPaddingHorizontal = 12.0;
  static const double inputPaddingVertical = 10.0;
  static const double cardPadding = 16.0;
  static const double dialogPadding = 24.0;
  static const double sectionSpacing = 24.0;
}

/// EdgeInsets пресеты для NovaSpec
class NsPadding {
  static const EdgeInsets zero = EdgeInsets.zero;
  static const EdgeInsets xxs = EdgeInsets.all(NsSpacing.xxs);
  static const EdgeInsets xs = EdgeInsets.all(NsSpacing.xs);
  static const EdgeInsets sm = EdgeInsets.all(NsSpacing.sm);
  static const EdgeInsets md = EdgeInsets.all(NsSpacing.md);
  static const EdgeInsets lg = EdgeInsets.all(NsSpacing.lg);
  static const EdgeInsets xl = EdgeInsets.all(NsSpacing.xl);
  static const EdgeInsets xxl = EdgeInsets.all(NsSpacing.xxl);

  // Горизонтальные
  static const EdgeInsets horizontalXs = EdgeInsets.symmetric(horizontal: NsSpacing.xs);
  static const EdgeInsets horizontalSm = EdgeInsets.symmetric(horizontal: NsSpacing.sm);
  static const EdgeInsets horizontalMd = EdgeInsets.symmetric(horizontal: NsSpacing.md);
  static const EdgeInsets horizontalLg = EdgeInsets.symmetric(horizontal: NsSpacing.lg);
  static const EdgeInsets horizontalXl = EdgeInsets.symmetric(horizontal: NsSpacing.xl);

  // Вертикальные
  static const EdgeInsets verticalXs = EdgeInsets.symmetric(vertical: NsSpacing.xs);
  static const EdgeInsets verticalSm = EdgeInsets.symmetric(vertical: NsSpacing.sm);
  static const EdgeInsets verticalMd = EdgeInsets.symmetric(vertical: NsSpacing.md);
  static const EdgeInsets verticalLg = EdgeInsets.symmetric(vertical: NsSpacing.lg);
  static const EdgeInsets verticalXl = EdgeInsets.symmetric(vertical: NsSpacing.xl);
}

/// Значения радиусов скругления
class NsBorderRadius {
  // Базовое значение: 10px (0.625rem)
  static const double base = 10.0;

  static const double none = 0.0;
  static const double sm = 6.0; // base - 4px
  static const double md = 8.0; // base - 2px
  static const double lg = 10.0; // base
  static const double xl = 12.0; // base + 2px
  static const double xxl = 16.0; // base + 6px
  static const double full = 9999.0; // Полностью скругленный
}

/// BorderRadius пресеты для NovaSpec
class NsRadius {
  static const BorderRadius none = BorderRadius.zero;
  static const BorderRadius sm = BorderRadius.all(Radius.circular(NsBorderRadius.sm));
  static const BorderRadius md = BorderRadius.all(Radius.circular(NsBorderRadius.md));
  static const BorderRadius lg = BorderRadius.all(Radius.circular(NsBorderRadius.lg));
  static const BorderRadius xl = BorderRadius.all(Radius.circular(NsBorderRadius.xl));
  static const BorderRadius xxl = BorderRadius.all(Radius.circular(NsBorderRadius.xxl));
  static const BorderRadius full = BorderRadius.all(Radius.circular(NsBorderRadius.full));

  // Специфичные для компонентов
  static const BorderRadius button = lg;
  static const BorderRadius input = lg;
  static const BorderRadius card = xl;
  static const BorderRadius dialog = xxl;
}
