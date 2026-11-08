import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_dimensions.dart';
import 'app_text_styles.dart';

/// Material 3 light and dark themes.
class AppTheme {
  AppTheme._();

  static ThemeData light({bool bangla = false}) => _build(
        brightness: Brightness.light,
        primary: AppColors.primaryBlue,
        background: AppColors.background,
        card: AppColors.card,
        input: AppColors.inputBackground,
        divider: AppColors.divider,
        text: AppColors.textPrimary,
        secondaryText: AppColors.textSecondary,
        bangla: bangla,
      );

  static ThemeData dark({bool bangla = false}) => _build(
        brightness: Brightness.dark,
        primary: AppColors.darkPrimary,
        background: AppColors.darkBackground,
        card: AppColors.darkCard,
        input: AppColors.darkCard,
        divider: AppColors.darkDivider,
        text: AppColors.darkText,
        secondaryText: AppColors.darkTextSecondary,
        bangla: bangla,
      );

  static ThemeData _build({
    required Brightness brightness,
    required Color primary,
    required Color background,
    required Color card,
    required Color input,
    required Color divider,
    required Color text,
    required Color secondaryText,
    required bool bangla,
  }) {
    final scheme = ColorScheme.fromSeed(seedColor: primary, brightness: brightness).copyWith(
      primary: primary,
      onPrimary: AppColors.white,
      surface: card,
      onSurface: text,
      error: AppColors.danger,
      outline: divider,
    );
    final radius = BorderRadius.circular(AppDimensions.controlRadius);
    OutlineInputBorder border(Color c, [double w = 1]) =>
        OutlineInputBorder(borderRadius: radius, borderSide: BorderSide(color: c, width: w));

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: background,
      textTheme: AppTextStyles.textTheme(text, secondaryText, bangla: bangla),
      dividerColor: divider,
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: text,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: card,
        elevation: 1,
        shadowColor: const Color(0x14000000),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
          side: BorderSide(color: divider),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: input,
        enabledBorder: border(divider),
        border: border(divider),
        focusedBorder: border(primary, 2),
        errorBorder: border(AppColors.danger),
        focusedErrorBorder: border(AppColors.danger, 2),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: AppColors.white,
          minimumSize: const Size.fromHeight(AppDimensions.minTouchTarget),
          shape: RoundedRectangleBorder(borderRadius: radius),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: card,
        indicatorColor: primary.withValues(alpha: 0.12),
        iconTheme: WidgetStateProperty.resolveWith((s) => IconThemeData(
            color: s.contains(WidgetState.selected) ? primary : secondaryText)),
        labelTextStyle: WidgetStateProperty.resolveWith((s) => TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: s.contains(WidgetState.selected) ? primary : secondaryText)),
      ),
    );
  }
}
