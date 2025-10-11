import 'package:flutter/material.dart';
import 'package:novaspec/core/config/theme/ns_colors.dart';
import 'package:novaspec/core/config/theme/ns_text_styles.dart';
import 'package:novaspec/core/config/theme/ns_spacing.dart';

/// Основная тема приложения NovaSpec
class NsTheme {
  /// Светлая тема
  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      // Цветовая схема
      colorScheme: ColorScheme.light(
        primary: NsColorsLight.primary,
        onPrimary: NsColorsLight.primaryForeground,
        secondary: NsColorsLight.secondary,
        onSecondary: NsColorsLight.secondaryForeground,
        error: NsColorsLight.destructive,
        onError: NsColorsLight.destructiveForeground,
        surface: NsColorsLight.background,
        onSurface: NsColorsLight.foreground,
        surfaceContainerHighest: NsColorsLight.card,
        outline: NsColorsLight.border,
      ),

      // Цвета для различных элементов
      scaffoldBackgroundColor: NsColorsLight.background,
      cardColor: NsColorsLight.card,
      dividerColor: NsColorsLight.border,
      hoverColor: NsColorsLight.hover,

      // Типографика
      fontFamily: 'Inter',
      textTheme: TextTheme(
        displayLarge: TextStyle(
          fontSize: NsTextSizes.h1,
          fontWeight: NsFontWeights.bold,
          color: NsColorsLight.foreground,
        ),
        displayMedium: TextStyle(
          fontSize: NsTextSizes.h2,
          fontWeight: NsFontWeights.semiBold,
          color: NsColorsLight.foreground,
        ),
        displaySmall: TextStyle(
          fontSize: NsTextSizes.h3,
          fontWeight: NsFontWeights.semiBold,
          color: NsColorsLight.foreground,
        ),
        headlineMedium: TextStyle(
          fontSize: NsTextSizes.h4,
          fontWeight: NsFontWeights.medium,
          color: NsColorsLight.foreground,
        ),
        bodyLarge: TextStyle(
          fontSize: NsTextSizes.bodyLarge,
          fontWeight: NsFontWeights.regular,
          color: NsColorsLight.foreground,
        ),
        bodyMedium: TextStyle(
          fontSize: NsTextSizes.bodyMedium,
          fontWeight: NsFontWeights.regular,
          color: NsColorsLight.foreground,
        ),
        bodySmall: TextStyle(
          fontSize: NsTextSizes.bodySmall,
          fontWeight: NsFontWeights.regular,
          color: NsColorsLight.foreground,
        ),
        labelLarge: TextStyle(
          fontSize: NsTextSizes.bodyMedium,
          fontWeight: NsFontWeights.medium,
          color: NsColorsLight.foreground,
        ),
      ),

      // Стили компонентов
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: NsColorsLight.primary,
          foregroundColor: NsColorsLight.primaryForeground,
          padding: const EdgeInsets.symmetric(
            horizontal: NsSpacing.buttonPaddingHorizontal,
            vertical: NsSpacing.buttonPaddingVertical,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: NsRadius.button,
          ),
          elevation: 0,
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: NsColorsLight.background,
        border: OutlineInputBorder(
          borderRadius: NsRadius.input,
          borderSide: const BorderSide(color: NsColorsLight.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: NsRadius.input,
          borderSide: const BorderSide(color: NsColorsLight.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: NsRadius.input,
          borderSide: const BorderSide(color: NsColorsLight.ring, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: NsSpacing.inputPaddingHorizontal,
          vertical: NsSpacing.inputPaddingVertical,
        ),
      ),

      cardTheme: CardThemeData(
        color: NsColorsLight.card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: NsRadius.card,
          side: const BorderSide(color: NsColorsLight.border),
        ),
        margin: EdgeInsets.zero,
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: NsColorsLight.background,
        shape: RoundedRectangleBorder(
          borderRadius: NsRadius.dialog,
        ),
      ),
    );
  }

  /// Темная тема
  static ThemeData dark() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      // Цветовая схема
      colorScheme: ColorScheme.dark(
        primary: NsColorsDark.primary,
        onPrimary: NsColorsDark.primaryForeground,
        secondary: NsColorsDark.secondary,
        onSecondary: NsColorsDark.secondaryForeground,
        error: NsColorsDark.destructive,
        onError: NsColorsDark.destructiveForeground,
        surface: NsColorsDark.background,
        onSurface: NsColorsDark.foreground,
        surfaceContainerHighest: NsColorsDark.card,
        outline: NsColorsDark.border,
      ),

      // Цвета для различных элементов
      scaffoldBackgroundColor: NsColorsDark.background,
      cardColor: NsColorsDark.card,
      dividerColor: NsColorsDark.border,
      hoverColor: NsColorsDark.hover,

      // Типографика
      fontFamily: 'Inter',
      textTheme: TextTheme(
        displayLarge: TextStyle(
          fontSize: NsTextSizes.h1,
          fontWeight: NsFontWeights.bold,
          color: NsColorsDark.foreground,
        ),
        displayMedium: TextStyle(
          fontSize: NsTextSizes.h2,
          fontWeight: NsFontWeights.semiBold,
          color: NsColorsDark.foreground,
        ),
        displaySmall: TextStyle(
          fontSize: NsTextSizes.h3,
          fontWeight: NsFontWeights.semiBold,
          color: NsColorsDark.foreground,
        ),
        headlineMedium: TextStyle(
          fontSize: NsTextSizes.h4,
          fontWeight: NsFontWeights.medium,
          color: NsColorsDark.foreground,
        ),
        bodyLarge: TextStyle(
          fontSize: NsTextSizes.bodyLarge,
          fontWeight: NsFontWeights.regular,
          color: NsColorsDark.foreground,
        ),
        bodyMedium: TextStyle(
          fontSize: NsTextSizes.bodyMedium,
          fontWeight: NsFontWeights.regular,
          color: NsColorsDark.foreground,
        ),
        bodySmall: TextStyle(
          fontSize: NsTextSizes.bodySmall,
          fontWeight: NsFontWeights.regular,
          color: NsColorsDark.foreground,
        ),
        labelLarge: TextStyle(
          fontSize: NsTextSizes.bodyMedium,
          fontWeight: NsFontWeights.medium,
          color: NsColorsDark.foreground,
        ),
      ),

      // Стили компонентов
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: NsColorsDark.primary,
          foregroundColor: NsColorsDark.primaryForeground,
          padding: const EdgeInsets.symmetric(
            horizontal: NsSpacing.buttonPaddingHorizontal,
            vertical: NsSpacing.buttonPaddingVertical,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: NsRadius.button,
          ),
          elevation: 0,
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: NsColorsDark.background,
        border: OutlineInputBorder(
          borderRadius: NsRadius.input,
          borderSide: const BorderSide(color: NsColorsDark.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: NsRadius.input,
          borderSide: const BorderSide(color: NsColorsDark.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: NsRadius.input,
          borderSide: const BorderSide(color: NsColorsDark.ring, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: NsSpacing.inputPaddingHorizontal,
          vertical: NsSpacing.inputPaddingVertical,
        ),
      ),

      cardTheme: CardThemeData(
        color: NsColorsDark.card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: NsRadius.card,
          side: const BorderSide(color: NsColorsDark.border),
        ),
        margin: EdgeInsets.zero,
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: NsColorsDark.background,
        shape: RoundedRectangleBorder(
          borderRadius: NsRadius.dialog,
        ),
      ),
    );
  }
}
