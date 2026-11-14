import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:mobile/features/editor/domain/album_template_style.dart';
import 'package:mobile/features/editor/domain/templates/template_definition.dart';
import 'package:mobile/features/editor/domain/templates/template_registry.dart';

class CustomTestTemplate implements IAlbumTemplateDefinition {
  @override
  String get id => 'custom_test_template';

  @override
  String get title => 'Тестовый шаблон';

  @override
  AlbumTemplateStyle get style => const AlbumTemplateStyle(
        id: 'custom_test_template',
        title: 'Тестовый шаблон',
        primaryColor: Colors.blue,
        accentColor: Colors.red,
        canvasBackgroundColor: Colors.amber,
        sheetBackgroundColor: Colors.black,
        sheetBorderColor: Colors.grey,
        safeZoneColor: Colors.red,
        slotBorderColor: Colors.grey,
        slotBorderRadius: 4.0,
        slotBorderWidth: 1.0,
        headerBadgeBg: Colors.white,
        headerBadgeTextColor: Colors.black,
        fontTag: 'TEST FONT',
        icon: LucideIcons.sparkles,
        defaultHeadline: 'HEADLINE',
        defaultSubhead: 'SUBHEAD',
        headlineColor: Colors.black,
        coverBackgroundColor: Colors.black,
        coverTextColor: Colors.white,
        coverAccentColor: Colors.red,
        coverBorderColor: Colors.red,
        coverBadgeText: 'TEST BADGE',
      );

  @override
  TemplatePageLayoutInfo getPageLayout(int pageNumber) {
    return const TemplatePageLayoutInfo(layout: 'grid_4', slots: 4);
  }
}

void main() {
  group('AlbumTemplateRegistry (SOLID OCP)', () {
    test('provides styles for known built-in templates', () {
      final style = AlbumTemplateRegistry.getStyle('school_drive');
      expect(style.id, 'school_drive');
      expect(style.title, 'Школьный Драйв');

      final minimalStyle = AlbumTemplateRegistry.getStyle('minimalism');
      expect(minimalStyle.id, 'minimalism');
    });

    test('falls back gracefully to default for unknown template', () {
      final style = AlbumTemplateRegistry.getStyle('non_existent_template');
      expect(style.id, 'school_drive');
    });

    test('allows dynamic registration of new templates without modifying core code (OCP)', () {
      AlbumTemplateRegistry.register(CustomTestTemplate());
      final customStyle = AlbumTemplateRegistry.getStyle('custom_test_template');

      expect(customStyle.id, 'custom_test_template');
      expect(customStyle.title, 'Тестовый шаблон');
      expect(customStyle.canvasBackgroundColor, Colors.amber);
      expect(customStyle.accentColor, Colors.red);
    });
  });
}
