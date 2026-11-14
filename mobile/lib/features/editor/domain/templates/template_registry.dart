import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../album_template_style.dart';
import 'template_definition.dart';

/// Шаблон: Школьный Драйв (по умолчанию)
class SchoolDriveTemplate implements IAlbumTemplateDefinition {
  const SchoolDriveTemplate();

  @override
  String get id => 'school_drive';

  @override
  String get title => 'Школьный Драйв';

  @override
  AlbumTemplateStyle get style => const AlbumTemplateStyle(
        id: 'school_drive',
        title: 'Школьный Драйв',
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
        defaultHeadline: 'GO, BOYS!',
        defaultSubhead: '(да, это твой выпускной)',
        headlineColor: Color(0xFF1E293B),
        headlineLetterSpacing: 0.6,
        coverBackgroundColor: Color(0xFF1A1A1A),
        coverTextColor: Color(0xFFFFFFFF),
        coverAccentColor: Color(0xFFFF4D4D),
        coverBorderColor: Color(0xFFFF4D4D),
        coverBadgeText: 'ШКОЛЬНЫЙ ДРАЙВ • 2026',
      );

  @override
  TemplatePageLayoutInfo getPageLayout(int pageNumber) {
    switch (pageNumber) {
      case 1:
        return const TemplatePageLayoutInfo(
          layout: 'editorial_quote',
          slots: 2,
          headline: 'GO, BOYS!',
          subhead: '(да, это твой выпускной)',
        );
      case 2:
        return const TemplatePageLayoutInfo(layout: 'split_vertical_2', slots: 2);
      case 3:
        return const TemplatePageLayoutInfo(
          layout: 'hero_top_split_bottom_3',
          slots: 4,
          headline: "LET'S GO",
          subhead: '(лучшая вечеринка ever)',
        );
      case 4:
        return const TemplatePageLayoutInfo(layout: 'single_full', slots: 1);
      case 5:
        return const TemplatePageLayoutInfo(layout: 'checkerboard_3', slots: 3);
      case 6:
        return const TemplatePageLayoutInfo(layout: 'hero_centered', slots: 1);
      case 7:
        return const TemplatePageLayoutInfo(layout: 'split_horizontal_2', slots: 2);
      case 8:
        return const TemplatePageLayoutInfo(layout: 'grid_4', slots: 4);
      case 9:
        return const TemplatePageLayoutInfo(layout: 'split_vertical_3', slots: 3);
      case 10:
        return const TemplatePageLayoutInfo(layout: 'hero_top_trio_4', slots: 4);
      default:
        return TemplatePageLayoutInfo(
          layout: pageNumber % 2 == 0 ? 'grid_4' : 'split_vertical_2',
          slots: pageNumber % 2 == 0 ? 4 : 2,
        );
    }
  }
}

/// Шаблон: Классический выпускной
class ClassicGradTemplate implements IAlbumTemplateDefinition {
  const ClassicGradTemplate();

  @override
  String get id => 'classic_grad';

  @override
  String get title => 'Классический выпускной';

  @override
  AlbumTemplateStyle get style => const AlbumTemplateStyle(
        id: 'classic_grad',
        title: 'Классический выпускной',
        primaryColor: Color(0xFF1E293B),
        accentColor: Color(0xFFD4AF37),
        canvasBackgroundColor: Color(0xFFF1F5F9),
        sheetBackgroundColor: Color(0xFFFCFCFA),
        sheetBorderColor: Color(0xFFD4AF37),
        safeZoneColor: Color(0xFFD4AF37),
        slotBorderColor: Color(0xFFCBD5E1),
        slotBorderRadius: 2.0,
        slotBorderWidth: 1.0,
        headerBadgeBg: Color(0xFF0F172A),
        headerBadgeTextColor: Color(0xFFD4AF37),
        fontTag: 'CLASSIC GOLD',
        icon: LucideIcons.graduationCap,
        defaultHeadline: 'CLASS OF 2026',
        defaultSubhead: 'Выпускной альбом • Память на всю жизнь',
        headlineColor: Color(0xFF1E293B),
        headlineLetterSpacing: 2.0,
        coverBackgroundColor: Color(0xFF0F172A),
        coverTextColor: Color(0xFFF8FAFC),
        coverAccentColor: Color(0xFFD4AF37),
        coverBorderColor: Color(0xFFD4AF37),
        coverBadgeText: 'ВЫПУСКНОЙ АЛЬБОМ • CLASSIC',
      );

  @override
  TemplatePageLayoutInfo getPageLayout(int pageNumber) {
    switch (pageNumber) {
      case 1:
        return const TemplatePageLayoutInfo(layout: 'hero_centered', slots: 1);
      case 2:
        return const TemplatePageLayoutInfo(
          layout: 'editorial_quote',
          slots: 2,
          headline: 'CLASS OF 2026',
          subhead: 'Excellence & Memory',
        );
      case 3:
        return const TemplatePageLayoutInfo(layout: 'split_vertical_2', slots: 2);
      case 4:
        return const TemplatePageLayoutInfo(layout: 'grid_4', slots: 4);
      case 5:
        return const TemplatePageLayoutInfo(layout: 'split_vertical_2', slots: 2);
      case 6:
        return const TemplatePageLayoutInfo(layout: 'hero_centered', slots: 1);
      case 7:
        return const TemplatePageLayoutInfo(layout: 'single_full', slots: 1);
      case 8:
        return const TemplatePageLayoutInfo(layout: 'hero_top_split_bottom_3', slots: 4);
      case 9:
        return const TemplatePageLayoutInfo(layout: 'split_vertical_3', slots: 3);
      case 10:
        return const TemplatePageLayoutInfo(layout: 'split_horizontal_2', slots: 2);
      default:
        return TemplatePageLayoutInfo(
          layout: pageNumber % 2 == 0 ? 'grid_4' : 'split_vertical_2',
          slots: pageNumber % 2 == 0 ? 4 : 2,
        );
    }
  }
}

/// Шаблон: Минимализм
class MinimalismTemplate implements IAlbumTemplateDefinition {
  const MinimalismTemplate();

  @override
  String get id => 'minimalism';

  @override
  String get title => 'Минимализм';

  @override
  AlbumTemplateStyle get style => const AlbumTemplateStyle(
        id: 'minimalism',
        title: 'Минимализм',
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
        defaultHeadline: 'MOMENTS',
        defaultSubhead: 'archive / school years edition',
        headlineColor: Color(0xFF18181B),
        headlineLetterSpacing: 3.0,
        coverBackgroundColor: Color(0xFF09090B),
        coverTextColor: Color(0xFFFFFFFF),
        coverAccentColor: Color(0xFFE4E4E7),
        coverBorderColor: Color(0xFF3F3F46),
        coverBadgeText: 'ARCHIVE // МОНОХРОМ',
      );

  @override
  TemplatePageLayoutInfo getPageLayout(int pageNumber) {
    switch (pageNumber) {
      case 1:
        return const TemplatePageLayoutInfo(layout: 'hero_centered', slots: 1);
      case 2:
        return const TemplatePageLayoutInfo(layout: 'split_vertical_2', slots: 2);
      case 3:
        return const TemplatePageLayoutInfo(layout: 'single_full', slots: 1);
      case 4:
        return const TemplatePageLayoutInfo(layout: 'grid_4', slots: 4);
      case 5:
        return const TemplatePageLayoutInfo(
          layout: 'editorial_quote',
          slots: 2,
          headline: 'MINIMAL',
          subhead: 'pure memories',
        );
      case 6:
        return const TemplatePageLayoutInfo(layout: 'split_horizontal_2', slots: 2);
      case 7:
        return const TemplatePageLayoutInfo(layout: 'hero_centered', slots: 1);
      case 8:
        return const TemplatePageLayoutInfo(layout: 'split_vertical_3', slots: 3);
      case 9:
        return const TemplatePageLayoutInfo(layout: 'single_full', slots: 1);
      case 10:
        return const TemplatePageLayoutInfo(layout: 'split_vertical_2', slots: 2);
      default:
        return TemplatePageLayoutInfo(
          layout: pageNumber % 2 == 0 ? 'split_vertical_2' : 'hero_centered',
          slots: pageNumber % 2 == 0 ? 2 : 1,
        );
    }
  }
}

/// Шаблон: Пастель
class GentlePastelTemplate implements IAlbumTemplateDefinition {
  const GentlePastelTemplate();

  @override
  String get id => 'gentle_pastel';

  @override
  String get title => 'Пастель';

  @override
  AlbumTemplateStyle get style => const AlbumTemplateStyle(
        id: 'gentle_pastel',
        title: 'Пастель',
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
        defaultHeadline: 'Warm Memories',
        defaultSubhead: 'лучшие школьные моменты вместе',
        headlineColor: Color(0xFF9D174D),
        headlineLetterSpacing: 1.0,
        coverBackgroundColor: Color(0xFFFDF2F8),
        coverTextColor: Color(0xFF831843),
        coverAccentColor: Color(0xFFEC4899),
        coverBorderColor: Color(0xFFF472B6),
        coverBadgeText: 'НЕЖНАЯ АКВАРЕЛЬ • ПАМЯТЬ',
      );

  @override
  TemplatePageLayoutInfo getPageLayout(int pageNumber) {
    switch (pageNumber) {
      case 1:
        return const TemplatePageLayoutInfo(
          layout: 'editorial_quote',
          slots: 2,
          headline: 'PASTEL',
          subhead: 'soft emotions',
        );
      case 2:
        return const TemplatePageLayoutInfo(layout: 'hero_top_split_bottom_3', slots: 4);
      case 3:
        return const TemplatePageLayoutInfo(layout: 'split_vertical_2', slots: 2);
      case 4:
        return const TemplatePageLayoutInfo(layout: 'grid_4', slots: 4);
      case 5:
        return const TemplatePageLayoutInfo(layout: 'checkerboard_3', slots: 3);
      case 6:
        return const TemplatePageLayoutInfo(layout: 'single_full', slots: 1);
      case 7:
        return const TemplatePageLayoutInfo(layout: 'hero_top_trio_4', slots: 4);
      case 8:
        return const TemplatePageLayoutInfo(layout: 'hero_centered', slots: 1);
      case 9:
        return const TemplatePageLayoutInfo(layout: 'split_vertical_3', slots: 3);
      case 10:
        return const TemplatePageLayoutInfo(layout: 'split_horizontal_2', slots: 2);
      default:
        return TemplatePageLayoutInfo(
          layout: pageNumber % 2 == 0 ? 'hero_top_split_bottom_3' : 'split_vertical_2',
          slots: pageNumber % 2 == 0 ? 4 : 2,
        );
    }
  }
}

/// Шаблон: Винтаж
class VintageFilmTemplate implements IAlbumTemplateDefinition {
  const VintageFilmTemplate();

  @override
  String get id => 'vintage_film';

  @override
  String get title => 'Винтаж';

  @override
  AlbumTemplateStyle get style => const AlbumTemplateStyle(
        id: 'vintage_film',
        title: 'Винтаж',
        primaryColor: Color(0xFFB45309),
        accentColor: Color(0xFFF59E0B),
        canvasBackgroundColor: Color(0xFFF5EBE1),
        sheetBackgroundColor: Color(0xFFFAF7F0),
        sheetBorderColor: Color(0xFFB45309),
        safeZoneColor: Color(0xFFD97706),
        slotBorderColor: Color(0xFFE5D5C5),
        slotBorderRadius: 4.0,
        slotBorderWidth: 1.5,
        headerBadgeBg: Color(0xFF78350F),
        headerBadgeTextColor: Color(0xFFFEF3C7),
        fontTag: 'VINTAGE 35MM',
        icon: LucideIcons.camera,
        defaultHeadline: 'ANALOG 35MM',
        defaultSubhead: 'пленочные хроники нашего выпуска',
        headlineColor: Color(0xFF78350F),
        headlineLetterSpacing: 1.8,
        coverBackgroundColor: Color(0xFF382213),
        coverTextColor: Color(0xFFFEF3C7),
        coverAccentColor: Color(0xFFF59E0B),
        coverBorderColor: Color(0xFF92400E),
        coverBadgeText: 'RETRO FILM • ПЛЁНКА 90-х',
      );

  @override
  TemplatePageLayoutInfo getPageLayout(int pageNumber) {
    switch (pageNumber) {
      case 1:
        return const TemplatePageLayoutInfo(
          layout: 'editorial_quote',
          slots: 2,
          headline: '35MM FILM',
          subhead: 'analog memories',
        );
      case 2:
        return const TemplatePageLayoutInfo(layout: 'split_vertical_3', slots: 3);
      case 3:
        return const TemplatePageLayoutInfo(layout: 'hero_top_trio_4', slots: 4);
      case 4:
        return const TemplatePageLayoutInfo(layout: 'grid_4', slots: 4);
      case 5:
        return const TemplatePageLayoutInfo(layout: 'hero_centered', slots: 1);
      case 6:
        return const TemplatePageLayoutInfo(layout: 'split_horizontal_2', slots: 2);
      case 7:
        return const TemplatePageLayoutInfo(layout: 'single_full', slots: 1);
      case 8:
        return const TemplatePageLayoutInfo(layout: 'split_vertical_2', slots: 2);
      case 9:
        return const TemplatePageLayoutInfo(layout: 'checkerboard_3', slots: 3);
      case 10:
        return const TemplatePageLayoutInfo(layout: 'hero_top_split_bottom_3', slots: 4);
      default:
        return TemplatePageLayoutInfo(
          layout: pageNumber % 2 == 0 ? 'split_vertical_3' : 'hero_centered',
          slots: pageNumber % 2 == 0 ? 3 : 1,
        );
    }
  }
}

/// Шаблон: Младшая школа
class PrimarySchoolTemplate implements IAlbumTemplateDefinition {
  const PrimarySchoolTemplate();

  @override
  String get id => 'primary_school';

  @override
  String get title => 'Младшая школа';

  @override
  AlbumTemplateStyle get style => const AlbumTemplateStyle(
        id: 'primary_school',
        title: 'Младшая школа',
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
        defaultHeadline: 'НАШ ЛЮБИМЫЙ КЛАСС!',
        defaultSubhead: 'первые шаги к большим победам 🚀',
        headlineColor: Color(0xFF312E81),
        headlineLetterSpacing: 0.8,
        coverBackgroundColor: Color(0xFF312E81),
        coverTextColor: Color(0xFFFFFFFF),
        coverAccentColor: Color(0xFFFBBF24),
        coverBorderColor: Color(0xFF6366F1),
        coverBadgeText: 'НАШ ЛЮБИМЫЙ 1-Й КЛАСС 🚀',
      );

  @override
  TemplatePageLayoutInfo getPageLayout(int pageNumber) {
    switch (pageNumber) {
      case 1:
        return const TemplatePageLayoutInfo(
          layout: 'editorial_quote',
          slots: 2,
          headline: '1-Й КЛАСС',
          subhead: 'наши первые уроки',
        );
      case 2:
        return const TemplatePageLayoutInfo(layout: 'grid_4', slots: 4);
      case 3:
        return const TemplatePageLayoutInfo(layout: 'hero_top_split_bottom_3', slots: 4);
      case 4:
        return const TemplatePageLayoutInfo(layout: 'split_vertical_2', slots: 2);
      case 5:
        return const TemplatePageLayoutInfo(layout: 'checkerboard_3', slots: 3);
      case 6:
        return const TemplatePageLayoutInfo(layout: 'hero_centered', slots: 1);
      case 7:
        return const TemplatePageLayoutInfo(layout: 'hero_top_trio_4', slots: 4);
      case 8:
        return const TemplatePageLayoutInfo(layout: 'split_horizontal_2', slots: 2);
      case 9:
        return const TemplatePageLayoutInfo(layout: 'single_full', slots: 1);
      case 10:
        return const TemplatePageLayoutInfo(layout: 'split_vertical_3', slots: 3);
      default:
        return TemplatePageLayoutInfo(
          layout: pageNumber % 2 == 0 ? 'grid_4' : 'hero_centered',
          slots: pageNumber % 2 == 0 ? 4 : 1,
        );
    }
  }
}

/// Реестр шаблонов фотокниг (SOLID: OCP - Open for extension, Closed for modification)
class AlbumTemplateRegistry {
  static final Map<String, IAlbumTemplateDefinition> _templates = {
    'school_drive': const SchoolDriveTemplate(),
    'classic_grad': const ClassicGradTemplate(),
    'minimalism': const MinimalismTemplate(),
    'gentle_pastel': const GentlePastelTemplate(),
    'vintage_film': const VintageFilmTemplate(),
    'primary_school': const PrimarySchoolTemplate(),
  };

  static const IAlbumTemplateDefinition _fallbackTemplate = SchoolDriveTemplate();

  /// Регистрация нового шаблона без модификации существующего кода (OCP)
  static void register(IAlbumTemplateDefinition template) {
    _templates[template.id] = template;
  }

  /// Получить шаблон по идентификатору
  static IAlbumTemplateDefinition get(String? id) {
    if (id == null) return _fallbackTemplate;
    return _templates[id] ?? _fallbackTemplate;
  }

  /// Получить визуальный стиль шаблона
  static AlbumTemplateStyle getStyle(String? id) {
    return get(id).style;
  }

  /// Получить разметку страницы шаблона
  static Map<String, dynamic> getPageLayout(String? templateId, int pageNumber) {
    return get(templateId).getPageLayout(pageNumber).toMap();
  }

  /// Получить список всех доступных шаблонов
  static List<IAlbumTemplateDefinition> getAll() {
    return _templates.values.toList();
  }
}

