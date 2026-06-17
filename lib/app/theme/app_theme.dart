import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';
import 'app_dimensions.dart';
import 'app_text_styles.dart';
import 'system_ui_style.dart';

abstract final class AppTheme {
  static ThemeData get light => _buildTheme(
        brightness: Brightness.light,
        background: AppColors.background,
        surface: AppColors.surface,
        surfaceSecondary: AppColors.surfaceSecondary,
        textPrimary: AppColors.textPrimary,
        textSecondary: AppColors.textSecondary,
        border: AppColors.border,
        accentLight: AppColors.accentLight,
        systemUi: AppSystemUi.lightStyle,
      );

  static ThemeData get dark => _buildTheme(
        brightness: Brightness.dark,
        background: AppColors.backgroundDark,
        surface: AppColors.surfaceDark,
        surfaceSecondary: AppColors.surfaceSecondaryDark,
        textPrimary: AppColors.textPrimaryDark,
        textSecondary: AppColors.textSecondaryDark,
        border: AppColors.borderDark,
        accentLight: AppColors.accentLightDark,
        systemUi: AppSystemUi.darkStyle,
      );

  static ThemeData _buildTheme({
    required Brightness brightness,
    required Color background,
    required Color surface,
    required Color surfaceSecondary,
    required Color textPrimary,
    required Color textSecondary,
    required Color border,
    required Color accentLight,
    required SystemUiOverlayStyle systemUi,
  }) {
    if (brightness == Brightness.light) {
      AppSystemUi.apply();
    }

    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: AppColors.accent,
      onPrimary: Colors.white,
      secondary: AppColors.accent,
      onSecondary: Colors.white,
      error: AppColors.error,
      onError: Colors.white,
      surface: surface,
      onSurface: textPrimary,
      surfaceTint: Colors.transparent,
    );

    final textTheme = TextTheme(
      displaySmall: AppTextStyles.display.copyWith(color: textPrimary),
      titleMedium: AppTextStyles.title.copyWith(color: textPrimary),
      bodyLarge: AppTextStyles.body.copyWith(color: textPrimary),
      bodyMedium: AppTextStyles.bodySecondary.copyWith(color: textSecondary),
      labelLarge: AppTextStyles.label.copyWith(color: textPrimary),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: background,
      canvasColor: background,
      dividerColor: border,
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: background,
        foregroundColor: textPrimary,
        centerTitle: false,
        systemOverlayStyle: systemUi,
        titleTextStyle: AppTextStyles.title.copyWith(color: textPrimary),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: AppDimensions.bottomNavHeight,
        labelPadding: const EdgeInsets.only(top: 2),
        backgroundColor: surface,
        indicatorColor: accentLight,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            fontSize: 12,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            color: selected ? AppColors.accent : textSecondary,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected ? AppColors.accent : textSecondary,
            size: 22,
          );
        }),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shadowColor: brightness == Brightness.dark
            ? Colors.black54
            : const Color(0x0F000000),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: border,
        thickness: 1,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spacingLg,
            vertical: 14,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          ),
          textStyle: AppTextStyles.label,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.accent,
          side: const BorderSide(color: AppColors.accent),
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spacingLg,
            vertical: 14,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          ),
          textStyle: AppTextStyles.label,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceSecondary,
        hintStyle: AppTextStyles.bodySecondary.copyWith(color: textSecondary),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spacingMd,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
          borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surfaceSecondary,
        selectedColor: AppColors.accent,
        labelStyle: AppTextStyles.bodySecondary.copyWith(
          fontSize: 13,
          color: textSecondary,
        ),
        secondaryLabelStyle: const TextStyle(color: Colors.white, fontSize: 13),
        padding: const EdgeInsets.symmetric(horizontal: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        side: brightness == Brightness.dark
            ? BorderSide.none
            : BorderSide(color: border),
      ),
      iconTheme: IconThemeData(color: textSecondary),
      textTheme: textTheme,
    );
  }
}
