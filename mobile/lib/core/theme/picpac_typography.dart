import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'picpac_colors.dart';

abstract class PicPacTypography {
  /// Название альбома в шапке, заголовки модалок (18sp, Bold, 1.2)
  static TextStyle get h1Title => GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        height: 1.2,
        color: PicPacColors.textDark,
      );

  /// Заголовки шторок («Общая медиатека», «Голосование») (15sp, SemiBold, 1.3)
  static TextStyle get h2Section => GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        height: 1.3,
        color: PicPacColors.textDark,
      );

  /// Подписи под фотографиями на листе альбома (13sp, Medium, 1.3)
  static TextStyle get photoCaption => GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        height: 1.3,
        color: PicPacColors.textDark,
      );

  /// Текст на основных кнопках (14sp, SemiBold, 1.0)
  static TextStyle get buttonText => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 1.0,
        color: PicPacColors.white,
      );

  /// Текст на вторичных кнопках (14sp, SemiBold, 1.0)
  static TextStyle get buttonTextDark => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 1.0,
        color: PicPacColors.textDark,
      );

  /// Бейджи автора фото, таймер блокировки слота, номера страниц (11sp, Medium, 1.2)
  static TextStyle get metaInfo => GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        height: 1.2,
        color: PicPacColors.textMuted,
      );
}

