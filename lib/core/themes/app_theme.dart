import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTheme {
  static ThemeData light() {
    return _base(Brightness.light);
  }

  static ThemeData dark() {
    return _base(Brightness.dark);
  }

  static ThemeData _base(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final scheme = ColorScheme.fromSeed(
      seedColor: isDark ? AppColors.primaryDark : AppColors.primary,
      brightness: brightness,
      surface: isDark ? AppColors.darkSurface : AppColors.white,
    ).copyWith(
      primary: isDark ? AppColors.primaryDark : AppColors.primary,
      secondary: isDark ? AppColors.cardBlueDark : AppColors.cardBlue,
      surface: isDark ? AppColors.darkSurface : AppColors.white,
      surfaceContainerHighest:
          isDark ? AppColors.darkElevated : const Color(0xFFF5EBDD),
      background: isDark ? AppColors.darkBackground : AppColors.background,
      onSurface: isDark ? AppColors.inkPrimary : AppColors.black,
      onBackground: isDark ? AppColors.inkPrimary : AppColors.black,
      outline: isDark ? AppColors.inkBorder : const Color(0xFFD7CFC4),
      error: isDark ? AppColors.errorDark : AppColors.error,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      fontFamily: 'Roboto',
      scaffoldBackgroundColor: scheme.background,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.background,
        foregroundColor: scheme.onBackground,
        centerTitle: false,
        elevation: 0,
      ),
      iconTheme: IconThemeData(color: scheme.onSurface),
      textTheme: TextTheme(
        headlineLarge: TextStyle(
          fontSize: 48,
          fontWeight: FontWeight.w900,
          color: scheme.onSurface,
          height: .95,
        ),
        headlineMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w900,
          color: scheme.onSurface,
        ),
        titleLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w900,
          color: scheme.onSurface,
        ),
        bodyMedium: TextStyle(
          fontSize: 15,
          height: 1.45,
          color: isDark ? AppColors.inkSecondary : AppColors.inkMuted,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: AppColors.black,
          minimumSize: const Size.fromHeight(54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: AppColors.black,
          textStyle: const TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: scheme.onSurface,
          side: BorderSide(color: scheme.outline),
          textStyle: const TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? AppColors.darkElevated : AppColors.white,
        hintStyle: const TextStyle(color: AppColors.inkMuted),
        prefixIconColor: scheme.primary,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: scheme.primary, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: scheme.outline.withOpacity(.35)),
        ),
      ),
    );
  }
}
