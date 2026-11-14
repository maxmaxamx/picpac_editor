import '../album_template_style.dart';

/// Информация о разметке конкретной страницы шаблона
class TemplatePageLayoutInfo {
  final String layout;
  final int slots;
  final String? headline;
  final String? subhead;

  const TemplatePageLayoutInfo({
    required this.layout,
    required this.slots,
    this.headline,
    this.subhead,
  });

  Map<String, dynamic> toMap() {
    return {
      'layout': layout,
      'slots': slots,
      if (headline != null) 'headline': headline,
      if (subhead != null) 'subhead': subhead,
    };
  }
}

/// Абстрактный контракт определения шаблона фотокниги (SOLID: OCP, ISP)
abstract class IAlbumTemplateDefinition {
  String get id;
  String get title;
  AlbumTemplateStyle get style;
  TemplatePageLayoutInfo getPageLayout(int pageNumber);
}
