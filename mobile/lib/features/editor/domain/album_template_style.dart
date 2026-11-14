import 'package:flutter/material.dart';
import 'templates/template_registry.dart';

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

  // Типографика и акценты для журнальных макетов (Editorial & Typography Spreads)
  final String defaultHeadline;
  final String defaultSubhead;
  final Color headlineColor;
  final double headlineLetterSpacing;

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
    required this.defaultHeadline,
    required this.defaultSubhead,
    required this.headlineColor,
    this.headlineLetterSpacing = 0.5,
    required this.coverBackgroundColor,
    required this.coverTextColor,
    required this.coverAccentColor,
    required this.coverBorderColor,
    required this.coverBadgeText,
  });

  /// Получение стиля через реестр шаблонов (SOLID: OCP)
  static AlbumTemplateStyle fromId(String? id) {
    return AlbumTemplateRegistry.getStyle(id);
  }
}

