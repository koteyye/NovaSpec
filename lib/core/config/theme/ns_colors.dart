import 'package:flutter/material.dart';

/// Цветовая палитра NovaSpec для светлой темы
class NsColorsLight {
  // Основные цвета
  static const Color background = Color.fromRGBO(255, 255, 255, 1.0); // hsl(0, 0%, 100%)
  static const Color foreground = Color.fromRGBO(26, 26, 26, 1.0); // hsl(0, 0%, 10%)

  // Основной цвет (MTS Granat - гранатово-красный)
  static const Color primary = Color.fromRGBO(168, 7, 50, 1.0); // hsl(354, 92%, 34%)
  static const Color primaryForeground = Color.fromRGBO(250, 250, 250, 1.0); // hsl(0, 0%, 98%)

  // Вторичный цвет
  static const Color secondary = Color.fromRGBO(245, 245, 245, 1.0); // hsl(0, 0%, 96%)
  static const Color secondaryForeground = Color.fromRGBO(26, 26, 26, 1.0); // hsl(0, 0%, 10%)

  // Приглушенные цвета (muted)
  static const Color muted = Color.fromRGBO(245, 245, 245, 1.0); // hsl(0, 0%, 96%)
  static const Color mutedForeground = Color.fromRGBO(115, 115, 115, 1.0); // hsl(0, 0%, 45%)

  // Акцентный цвет
  static const Color accent = Color.fromRGBO(168, 7, 50, 1.0); // hsl(354, 92%, 34%)
  static const Color accentForeground = Color.fromRGBO(250, 250, 250, 1.0); // hsl(0, 0%, 98%)

  // Деструктивный (ошибки, удаление)
  static const Color destructive = Color.fromRGBO(239, 68, 68, 1.0); // hsl(0, 84%, 60%)
  static const Color destructiveForeground = Color.fromRGBO(250, 250, 250, 1.0); // hsl(0, 0%, 98%)

  // Границы и обводки
  static const Color border = Color.fromRGBO(224, 224, 224, 1.0); // hsl(0, 0%, 88%)
  static const Color input = Color.fromRGBO(224, 224, 224, 1.0); // hsl(0, 0%, 88%)
  static const Color ring = Color.fromRGBO(168, 7, 50, 1.0); // hsl(354, 92%, 34%)

  // Карточки и поповеры
  static const Color card = Color.fromRGBO(255, 255, 255, 1.0); // hsl(0, 0%, 100%)
  static const Color cardForeground = Color.fromRGBO(26, 26, 26, 1.0); // hsl(0, 0%, 10%)
  static const Color popover = Color.fromRGBO(255, 255, 255, 1.0); // hsl(0, 0%, 100%)
  static const Color popoverForeground = Color.fromRGBO(26, 26, 26, 1.0); // hsl(0, 0%, 10%)

  // IDE-специфичные цвета
  static const Color panel = Color.fromRGBO(250, 250, 250, 1.0); // hsl(0, 0%, 98%)
  static const Color editor = Color.fromRGBO(255, 255, 255, 1.0); // hsl(0, 0%, 100%)
  static const Color sidebar = Color.fromRGBO(247, 247, 247, 1.0); // hsl(0, 0%, 97%)
  static const Color statusbar = Color.fromRGBO(242, 242, 242, 1.0); // hsl(0, 0%, 95%)
  static const Color hover = Color.fromRGBO(237, 237, 237, 1.0); // hsl(0, 0%, 93%)

  // Индикаторы состояния
  static const Color indicatorActive = Color.fromRGBO(168, 7, 50, 1.0); // hsl(354, 92%, 34%)
  static const Color indicatorInactive = Color.fromRGBO(153, 153, 153, 1.0); // hsl(0, 0%, 60%)
}

/// Цветовая палитра NovaSpec для темной темы
class NsColorsDark {
  // Основные цвета
  static const Color background = Color.fromRGBO(28, 28, 28, 1.0); // hsl(0, 0%, 11%)
  static const Color foreground = Color.fromRGBO(250, 250, 250, 1.0); // hsl(0, 0%, 98%)

  // Основной цвет (MTS Granat - светлее для темной темы)
  static const Color primary = Color.fromRGBO(235, 69, 117, 1.0); // hsl(354, 92%, 55%)
  static const Color primaryForeground = Color.fromRGBO(250, 250, 250, 1.0); // hsl(0, 0%, 98%)

  // Вторичный цвет
  static const Color secondary = Color.fromRGBO(38, 38, 38, 1.0); // hsl(0, 0%, 15%)
  static const Color secondaryForeground = Color.fromRGBO(250, 250, 250, 1.0); // hsl(0, 0%, 98%)

  // Приглушенные цвета (muted)
  static const Color muted = Color.fromRGBO(38, 38, 38, 1.0); // hsl(0, 0%, 15%)
  static const Color mutedForeground = Color.fromRGBO(166, 166, 166, 1.0); // hsl(0, 0%, 65%)

  // Акцентный цвет
  static const Color accent = Color.fromRGBO(235, 69, 117, 1.0); // hsl(354, 92%, 55%)
  static const Color accentForeground = Color.fromRGBO(250, 250, 250, 1.0); // hsl(0, 0%, 98%)

  // Деструктивный
  static const Color destructive = Color.fromRGBO(153, 27, 27, 1.0); // hsl(0, 63%, 31%)
  static const Color destructiveForeground = Color.fromRGBO(250, 250, 250, 1.0); // hsl(0, 0%, 98%)

  // Границы и обводки
  static const Color border = Color.fromRGBO(46, 46, 46, 1.0); // hsl(0, 0%, 18%)
  static const Color input = Color.fromRGBO(46, 46, 46, 1.0); // hsl(0, 0%, 18%)
  static const Color ring = Color.fromRGBO(235, 69, 117, 1.0); // hsl(354, 92%, 55%)

  // Карточки и поповеры
  static const Color card = Color.fromRGBO(28, 28, 28, 1.0); // hsl(0, 0%, 11%)
  static const Color cardForeground = Color.fromRGBO(250, 250, 250, 1.0); // hsl(0, 0%, 98%)
  static const Color popover = Color.fromRGBO(28, 28, 28, 1.0); // hsl(0, 0%, 11%)
  static const Color popoverForeground = Color.fromRGBO(250, 250, 250, 1.0); // hsl(0, 0%, 98%)

  // IDE-специфичные цвета
  static const Color panel = Color.fromRGBO(20, 20, 20, 1.0); // hsl(0, 0%, 8%)
  static const Color editor = Color.fromRGBO(28, 28, 28, 1.0); // hsl(0, 0%, 11%)
  static const Color sidebar = Color.fromRGBO(23, 23, 23, 1.0); // hsl(0, 0%, 9%)
  static const Color statusbar = Color.fromRGBO(18, 18, 18, 1.0); // hsl(0, 0%, 7%)
  static const Color hover = Color.fromRGBO(41, 41, 41, 1.0); // hsl(0, 0%, 16%)

  // Индикаторы состояния
  static const Color indicatorActive = Color.fromRGBO(235, 69, 117, 1.0); // hsl(354, 92%, 55%)
  static const Color indicatorInactive = Color.fromRGBO(115, 115, 115, 1.0); // hsl(0, 0%, 45%)
}

/// Семантические цвета (для уведомлений, статусов и т.д.)
class NsSemanticColors {
  // Успех
  static const Color successLight = Color.fromRGBO(34, 197, 94, 1.0); // Зеленый
  static const Color successDark = Color.fromRGBO(74, 222, 128, 1.0);

  // Предупреждение
  static const Color warningLight = Color.fromRGBO(234, 179, 8, 1.0); // Желтый
  static const Color warningDark = Color.fromRGBO(250, 204, 21, 1.0);

  // Информация
  static const Color infoLight = Color.fromRGBO(59, 130, 246, 1.0); // Синий
  static const Color infoDark = Color.fromRGBO(96, 165, 250, 1.0);

  // Ошибка
  static const Color errorLight = Color.fromRGBO(239, 68, 68, 1.0); // Красный
  static const Color errorDark = Color.fromRGBO(248, 113, 113, 1.0);
}
