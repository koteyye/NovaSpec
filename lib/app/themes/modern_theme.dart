import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/helpers.dart';

class ModernTheme {
  // Современная светлая тема с мягкими цветами
  static ThemeData get lightTheme {
    final interTheme = GoogleFonts.interTextTheme();
    
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primarySwatch: Helpers.createMaterialColor(const Color(AppConstants.primaryColorValue)),
      primaryColor: const Color(AppConstants.primaryColorValue),
      scaffoldBackgroundColor: Colors.white,
      
      // Современная цветовая схема
      colorScheme: const ColorScheme.light(
        primary: Color(AppConstants.primaryColorValue),
        secondary: Color(AppConstants.secondaryColorValue),
        surface: Colors.white,
        error: Color(AppConstants.errorColorValue),
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Color(0xFF1F2937), // Мягкий черный текст
        onError: Colors.white,
      ),
      
      // Inter текстовая тема
      textTheme: interTheme.copyWith(
        displayLarge: interTheme.displayLarge?.copyWith(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF1F2937),
        ),
        displayMedium: interTheme.displayMedium?.copyWith(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF1F2937),
        ),
        displaySmall: interTheme.displaySmall?.copyWith(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF1F2937),
        ),
        headlineLarge: interTheme.headlineLarge?.copyWith(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF1F2937),
        ),
        headlineMedium: interTheme.headlineMedium?.copyWith(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF1F2937),
        ),
        headlineSmall: interTheme.headlineSmall?.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF1F2937),
        ),
        titleLarge: interTheme.titleLarge?.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF1F2937),
        ),
        titleMedium: interTheme.titleMedium?.copyWith(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF1F2937),
        ),
        titleSmall: interTheme.titleSmall?.copyWith(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF1F2937),
        ),
        bodyLarge: interTheme.bodyLarge?.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: const Color(0xFF1F2937),
        ),
        bodyMedium: interTheme.bodyMedium?.copyWith(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: const Color(0xFF1F2937),
        ),
        bodySmall: interTheme.bodySmall?.copyWith(
          fontSize: 10,
          fontWeight: FontWeight.normal,
          color: const Color(0xFF1F2937),
        ),
        labelLarge: interTheme.labelLarge?.copyWith(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF1F2937),
        ),
        labelMedium: interTheme.labelMedium?.copyWith(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF1F2937),
        ),
        labelSmall: interTheme.labelSmall?.copyWith(
          fontSize: 8,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF1F2937),
        ),
      ),
      
      // AppBar тема
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(AppConstants.primaryColorValue),
        foregroundColor: Colors.white,
        elevation: 2,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      
      // Primary кнопки с современными эффектами
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(AppConstants.primaryColorValue),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
          ),
          elevation: 2,
          shadowColor: Colors.black26,
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ).copyWith(
          overlayColor: WidgetStateProperty.resolveWith<Color?>((states) {
            if (states.contains(WidgetState.hovered)) {
              return const Color(AppConstants.primaryColorValue).withValues(alpha: 0.1);
            }
            if (states.contains(WidgetState.pressed)) {
              return const Color(AppConstants.primaryColorValue).withValues(alpha: 0.2);
            }
            return null;
          }),
        ),
      ),
      
      // Tertiary кнопки (вспомогательные)
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: const Color(AppConstants.secondaryColorValue),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ).copyWith(
          overlayColor: WidgetStateProperty.resolveWith<Color?>((states) {
            if (states.contains(WidgetState.hovered)) {
              return const Color(AppConstants.secondaryColorValue).withValues(alpha: 0.1);
            }
            return null;
          }),
        ),
      ),
      
      // Secondary кнопки (второстепенные)
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(AppConstants.primaryColorValue),
          side: const BorderSide(color: Color(AppConstants.primaryColorValue), width: 1),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ).copyWith(
          backgroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
            if (states.contains(WidgetState.hovered)) {
              return const Color(AppConstants.primaryColorValue).withValues(alpha: 0.05);
            }
            return null;
          }),
        ),
      ),
      
      // Карточки с мягкими тенями
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 1,
        shadowColor: Colors.black12,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        ),
        margin: const EdgeInsets.all(AppConstants.defaultPadding),
      ),
      
      // Поля ввода с современным стилем
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
          borderSide: const BorderSide(color: Color(AppConstants.primaryColorValue), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
          borderSide: const BorderSide(color: Color(AppConstants.errorColorValue)),
        ),
        filled: true,
        fillColor: const Color(0xFFF9FAFB),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }
  
  // Современная темная тема
  static ThemeData get darkTheme {
    final interTheme = GoogleFonts.interTextTheme(ThemeData.dark().textTheme);
    
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primarySwatch: Helpers.createMaterialColor(const Color(AppConstants.primaryColorValue)),
      primaryColor: const Color(AppConstants.primaryColorValue),
      scaffoldBackgroundColor: const Color(0xFF111827),
      
      colorScheme: const ColorScheme.dark(
        primary: Color(AppConstants.primaryColorValue),
        secondary: Color(AppConstants.secondaryColorValue),
        surface: Color(0xFF1F2937),
        error: Color(AppConstants.errorColorValue),
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Color(0xFFF9FAFB),
        onError: Colors.white,
      ),
      
      textTheme: interTheme.copyWith(
        displayLarge: interTheme.displayLarge?.copyWith(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: const Color(0xFFF9FAFB),
        ),
        displayMedium: interTheme.displayMedium?.copyWith(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: const Color(0xFFF9FAFB),
        ),
        displaySmall: interTheme.displaySmall?.copyWith(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: const Color(0xFFF9FAFB),
        ),
        headlineLarge: interTheme.headlineLarge?.copyWith(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: const Color(0xFFF9FAFB),
        ),
        headlineMedium: interTheme.headlineMedium?.copyWith(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: const Color(0xFFF9FAFB),
        ),
        headlineSmall: interTheme.headlineSmall?.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: const Color(0xFFF9FAFB),
        ),
        titleLarge: interTheme.titleLarge?.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: const Color(0xFFF9FAFB),
        ),
        titleMedium: interTheme.titleMedium?.copyWith(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: const Color(0xFFF9FAFB),
        ),
        titleSmall: interTheme.titleSmall?.copyWith(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: const Color(0xFFF9FAFB),
        ),
        bodyLarge: interTheme.bodyLarge?.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: const Color(0xFFF9FAFB),
        ),
        bodyMedium: interTheme.bodyMedium?.copyWith(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: const Color(0xFFF9FAFB),
        ),
        bodySmall: interTheme.bodySmall?.copyWith(
          fontSize: 10,
          fontWeight: FontWeight.normal,
          color: const Color(0xFFF9FAFB),
        ),
        labelLarge: interTheme.labelLarge?.copyWith(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: const Color(0xFFF9FAFB),
        ),
        labelMedium: interTheme.labelMedium?.copyWith(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: const Color(0xFFF9FAFB),
        ),
        labelSmall: interTheme.labelSmall?.copyWith(
          fontSize: 8,
          fontWeight: FontWeight.w500,
          color: const Color(0xFFF9FAFB),
        ),
      ),
      
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(AppConstants.surfaceColorValue),
        foregroundColor: Color(0xFFF9FAFB),
        elevation: 2,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Color(0xFFF9FAFB),
        ),
      ),
      
      // Темные кнопки с современными эффектами
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(AppConstants.primaryColorValue),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
          ),
          elevation: 2,
          shadowColor: Colors.black26,
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ).copyWith(
          overlayColor: WidgetStateProperty.resolveWith<Color?>((states) {
            if (states.contains(WidgetState.hovered)) {
              return const Color(AppConstants.primaryColorValue).withValues(alpha: 0.1);
            }
            if (states.contains(WidgetState.pressed)) {
              return const Color(AppConstants.primaryColorValue).withValues(alpha: 0.2);
            }
            return null;
          }),
        ),
      ),
      
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: const Color(AppConstants.secondaryColorValue),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ).copyWith(
          overlayColor: WidgetStateProperty.resolveWith<Color?>((states) {
            if (states.contains(WidgetState.hovered)) {
              return const Color(AppConstants.secondaryColorValue).withValues(alpha: 0.1);
            }
            return null;
          }),
        ),
      ),
      
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(AppConstants.primaryColorValue),
          side: const BorderSide(color: Color(AppConstants.primaryColorValue), width: 1),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ).copyWith(
          backgroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
            if (states.contains(WidgetState.hovered)) {
              return const Color(AppConstants.primaryColorValue).withValues(alpha: 0.05);
            }
            return null;
          }),
        ),
      ),
      
      cardTheme: CardThemeData(
        color: const Color(AppConstants.surfaceColorValue),
        elevation: 1,
        shadowColor: Colors.black12,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        ),
        margin: const EdgeInsets.all(AppConstants.defaultPadding),
      ),
      
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
          borderSide: const BorderSide(color: Color(0xFF374151)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
          borderSide: const BorderSide(color: Color(0xFF374151)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
          borderSide: const BorderSide(color: Color(AppConstants.primaryColorValue), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
          borderSide: const BorderSide(color: Color(AppConstants.errorColorValue)),
        ),
        filled: true,
        fillColor: const Color(0xFF1F2937),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }
}
