import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Builds the text theme. Inter for English, Noto Sans Bengali for Bangla.
class AppTextStyles {
  AppTextStyles._();

  static TextTheme textTheme(Color primary, Color secondary, {required bool bangla}) {
    TextStyle base(double size, FontWeight w, Color c) => bangla
        ? GoogleFonts.notoSansBengali(fontSize: size, fontWeight: w, color: c)
        : GoogleFonts.inter(fontSize: size, fontWeight: w, color: c);

    return TextTheme(
      headlineLarge: base(28, FontWeight.w700, primary), // dashboard heading
      headlineMedium: base(24, FontWeight.w700, primary), // screen title
      titleLarge: base(18, FontWeight.w600, primary), // section heading
      titleMedium: base(16, FontWeight.w600, primary), // card title
      labelLarge: base(14, FontWeight.w500, primary), // labels
      bodyMedium: base(14, FontWeight.w400, primary), // body
      bodySmall: base(12, FontWeight.w400, secondary), // supporting
    );
  }
}
