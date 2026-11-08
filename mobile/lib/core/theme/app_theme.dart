import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'picpac_colors.dart';

class PicPacTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: PicPacColors.surfaceGrey,
      fontFamily: GoogleFonts.inter().fontFamily,
      colorScheme: const ColorScheme.light(
        primary: PicPacColors.primaryCoral,
        onPrimary: PicPacColors.white,
        surface: PicPacColors.white,
        onSurface: PicPacColors.textDark,
        outline: PicPacColors.borderDefault,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: PicPacColors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: PicPacColors.textDark),
      ),
      dividerColor: PicPacColors.borderDefault,
    );
  }

  static ShadThemeData get shadTheme {
    return ShadThemeData(
      brightness: Brightness.light,
      colorScheme: const ShadZincColorScheme.light(
        primary: PicPacColors.primaryCoral,
        primaryForeground: PicPacColors.white,
        background: PicPacColors.white,
        foreground: PicPacColors.textDark,
        muted: PicPacColors.surfaceGrey,
        mutedForeground: PicPacColors.textMuted,
        border: PicPacColors.borderDefault,
      ),
    );
  }
}
