import 'dart:ui';

/// Single source of truth for every colour used in MediTrack.
class AppColors {
  AppColors._();

  // Primary
  static const primaryBlue = Color(0xFF2563EB);
  static const primaryDark = Color(0xFF1D4ED8);
  static const lightBlue = Color(0xFFDBEAFE);
  static const softBlue = Color(0xFFEFF6FF);
  static const darkNavy = Color(0xFF172554);
  static const secondaryNavy = Color(0xFF1E3A8A);

  // Light backgrounds
  static const background = Color(0xFFF7F9FC);
  static const card = Color(0xFFFFFFFF);
  static const inputBackground = Color(0xFFF8FAFC);
  static const divider = Color(0xFFE2E8F0);

  // Status
  static const success = Color(0xFF16A34A);
  static const lightGreen = Color(0xFFDCFCE7);
  static const warning = Color(0xFFF59E0B);
  static const lightOrange = Color(0xFFFEF3C7);
  static const danger = Color(0xFFDC2626);
  static const lightRed = Color(0xFFFEE2E2);
  static const info = Color(0xFF0891B2);

  // Text
  static const textPrimary = darkNavy;
  static const textSecondary = Color(0xFF64748B);
  static const textMuted = Color(0xFF94A3B8);
  static const white = Color(0xFFFFFFFF);

  // Dark theme
  static const darkBackground = Color(0xFF0F172A);
  static const darkCard = Color(0xFF1E293B);
  static const darkPrimary = Color(0xFF3B82F6);
  static const darkText = Color(0xFFF8FAFC);
  static const darkTextSecondary = Color(0xFFCBD5E1);
  static const darkDivider = Color(0xFF334155);
}
