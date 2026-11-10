import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Визуальные настройки шаблона оформления страниц фотокниги
class AlbumTemplateStyle {
  final String id;
  final String title;
  final Color primaryColor;
  final Color accentColor;
  final Color canvasBackgroundColor;
  final Color sheetBackgroundColor;
  final Color sheetBorderColor;
  final Color safeZoneColor;
  final Color slotBorderColor;
  final double slotBorderRadius;
  final double slotBorderWidth;
  final Color headerBadgeBg;
  final Color headerBadgeTextColor;
  final String fontTag;
  final IconData icon;

  // Стиль обложки (Cover Presentation)
  final Color coverBackgroundColor;
  final Color coverTextColor;
  final Color coverAccentColor;
  final Color coverBorderColor;
  final String coverBadgeText;

  const AlbumTemplateStyle({
    required this.id,
    required this.title,
    required this.primaryColor,
    required this.accentColor,
    required this.canvasBackgroundColor,
    required this.sheetBackgroundColor,
    required this.sheetBorderColor,
    required this.safeZoneColor,
    required this.slotBorderColor,
    required this.slotBorderRadius,
    required this.slotBorderWidth,
    required this.headerBadgeBg,
    required this.headerBadgeTextColor,
    required this.fontTag,
    required this.icon,
    required this.coverBackgroundColor,
    required this.coverTextColor,
    required this.coverAccentColor,
    required this.coverBorderColor,
    required this.coverBadgeText,
  });

  static AlbumTemplateStyle fromId(String? id) {
    switch (id) {
      case 'classic_grad':
        return const AlbumTemplateStyle(
          id: 'classic_grad',
          title: 'Классический выпускной',
          primaryColor: Color(0xFF1E293B),
          accentColor: Color(0xFFD4AF37), // Благородное золото
          canvasBackgroundColor: Color(0xFFF1F5F9),
          sheetBackgroundColor: Color(0xFFFCFCFA), // Слоновая кость
          sheetBorderColor: Color(0xFFD4AF37),
          safeZoneColor: Color(0xFFD4AF37),
          slotBorderColor: Color(0xFFCBD5E1),
          slotBorderRadius: 2.0,
          slotBorderWidth: 1.0,
          headerBadgeBg: Color(0xFF0F172A),
          headerBadgeTextColor: Color(0xFFD4AF37),
          fontTag: 'CLASSIC GOLD',
          icon: LucideIcons.graduationCap,
          coverBackgroundColor: Color(0xFF0F172A), // Темно-синий бархат
          coverTextColor: Color(0xFFF8FAFC),
          coverAccentColor: Color(0xFFD4AF37),
          coverBorderColor: Color(0xFFD4AF37),
          coverBadgeText: 'ВЫПУСКНОЙ АЛЬБОМ • CLASSIC',
        );

      case 'minimalism':
        return const AlbumTemplateStyle(
          id: 'minimalism',
          title: 'Минимализм & Ч/Б Эстетика',
          primaryColor: Color(0xFF09090B),
          accentColor: Color(0xFF18181B),
          canvasBackgroundColor: Color(0xFFE4E4E7),
          sheetBackgroundColor: Color(0xFFFFFFFF),
          sheetBorderColor: Color(0xFF27272A),
          safeZoneColor: Color(0xFF71717A),
          slotBorderColor: Color(0xFFE4E4E7),
          slotBorderRadius: 0.0,
          slotBorderWidth: 1.0,
          headerBadgeBg: Color(0xFF18181B),
          headerBadgeTextColor: Color(0xFFFFFFFF),
          fontTag: 'MONOCHROME ARCHIVE',
          icon: LucideIcons.maximize2,
          coverBackgroundColor: Color(0xFF09090B), // Чистый графитовый
          coverTextColor: Color(0xFFFFFFFF),
          coverAccentColor: Color(0xFFE4E4E7),
          coverBorderColor: Color(0xFF3F3F46),
          coverBadgeText: 'ARCHIVE // МОНОХРОМ',
        );

      case 'gentle_pastel':
        return const AlbumTemplateStyle(
          id: 'gentle_pastel',
          title: 'Нежная Акварель & Пастель',
          primaryColor: Color(0xFFEC4899),
          accentColor: Color(0xFFF472B6),
          canvasBackgroundColor: Color(0xFFFDF2F8),
          sheetBackgroundColor: Color(0xFFFFFDFE),
          sheetBorderColor: Color(0xFFFBCFE8),
          safeZoneColor: Color(0xFFF472B6),
          slotBorderColor: Color(0xFFFCE7F3),
          slotBorderRadius: 12.0,
          slotBorderWidth: 1.5,
          headerBadgeBg: Color(0xFFFCE7F3),
          headerBadgeTextColor: Color(0xFFBE185D),
          fontTag: 'SOFT PASTEL',
          icon: LucideIcons.palette,
          coverBackgroundColor: Color(0xFFFDF2F8),
          coverTextColor: Color(0xFF831843),
          coverAccentColor: Color(0xFFEC4899),
          coverBorderColor: Color(0xFFF472B6),
          coverBadgeText: 'НЕЖНАЯ АКВАРЕЛЬ • ПАМЯТЬ',
        );

      case 'vintage_film':
        return const AlbumTemplateStyle(
          id: 'vintage_film',
          title: 'Винтаж & Плёнка 90-х',
          primaryColor: Color(0xFFB45309),
          accentColor: Color(0xFFF59E0B),
          canvasBackgroundColor: Color(0xFFF5EBE1),
          sheetBackgroundColor: Color(0xFFFAF7F0), // Состаренная бумага
          sheetBorderColor: Color(0xFFB45309),
          safeZoneColor: Color(0xFFD97706),
          slotBorderColor: Color(0xFFE5D5C5),
          slotBorderRadius: 4.0,
          slotBorderWidth: 1.5,
          headerBadgeBg: Color(0xFF78350F),
          headerBadgeTextColor: Color(0xFFFEF3C7),
          fontTag: 'VINTAGE 35MM',
          icon: LucideIcons.camera,
          coverBackgroundColor: Color(0xFF382213), // Винтажная кожа
          coverTextColor: Color(0xFFFEF3C7),
          coverAccentColor: Color(0xFFF59E0B),
          coverBorderColor: Color(0xFF92400E),
          coverBadgeText: 'RETRO FILM • ПЛЁНКА 90-х',
        );

      case 'primary_school':
        return const AlbumTemplateStyle(
          id: 'primary_school',
          title: 'Младшая школа & Первоклашки',
          primaryColor: Color(0xFF6366F1),
          accentColor: Color(0xFFF59E0B),
          canvasBackgroundColor: Color(0xFFEEF2FF),
          sheetBackgroundColor: Color(0xFFFFFFFF),
          sheetBorderColor: Color(0xFF818CF8),
          safeZoneColor: Color(0xFF6366F1),
          slotBorderColor: Color(0xFFE0E7FF),
          slotBorderRadius: 10.0,
          slotBorderWidth: 2.0,
          headerBadgeBg: Color(0xFFE0E7FF),
          headerBadgeTextColor: Color(0xFF4338CA),
          fontTag: 'PRIMARY SCHOOL',
          icon: LucideIcons.smile,
          coverBackgroundColor: Color(0xFF312E81),
          coverTextColor: Color(0xFFFFFFFF),
          coverAccentColor: Color(0xFFFBBF24),
          coverBorderColor: Color(0xFF6366F1),
          coverBadgeText: 'НАШ ЛЮБИМЫЙ 1-Й КЛАСС 🚀',
        );

      case 'school_drive':
      default:
        return const AlbumTemplateStyle(
          id: 'school_drive',
          title: 'Школьный Драйв & Casual',
          primaryColor: Color(0xFFFF4D4D),
          accentColor: Color(0xFF3B82F6),
          canvasBackgroundColor: Color(0xFFF5F5F5),
          sheetBackgroundColor: Color(0xFFFFFFFF),
          sheetBorderColor: Color(0xFFE5E5E5),
          safeZoneColor: Color(0xFFFF4D4D),
          slotBorderColor: Color(0xFFE5E5E5),
          slotBorderRadius: 6.0,
          slotBorderWidth: 1.0,
          headerBadgeBg: Color(0xFFFFF0F0),
          headerBadgeTextColor: Color(0xFFFF4D4D),
          fontTag: 'MODERN DRIVE',
          icon: LucideIcons.sparkles,
          coverBackgroundColor: Color(0xFF1A1A1A),
          coverTextColor: Color(0xFFFFFFFF),
          coverAccentColor: Color(0xFFFF4D4D),
          coverBorderColor: Color(0xFFFF4D4D),
          coverBadgeText: 'ШКОЛЬНЫЙ ДРАЙВ • 2026',
        );
    }
  }
}
