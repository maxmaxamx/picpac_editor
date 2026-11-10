import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/picpac_colors.dart';
import '../../../../core/theme/picpac_typography.dart';
import 'album_parameters_screen.dart';

/// Модель шаблона дизайна альбома
class AlbumTemplate {
  final String id;
  final String title;
  final String subtitle;
  final String tag;
  final String description;
  final Color primaryColor;
  final List<Color> palette;
  final IconData icon;

  const AlbumTemplate({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.tag,
    required this.description,
    required this.primaryColor,
    required this.palette,
    required this.icon,
  });
}

const List<AlbumTemplate> kAlbumTemplates = [
  AlbumTemplate(
    id: 'classic_grad',
    title: 'Классический выпускной',
    subtitle: 'Элегантный и строгий',
    tag: 'ХИТ СЕЗОНА',
    description: 'Благородная типографика, классическая портретная сетка и золотые акценты для памятных моментов.',
    primaryColor: Color(0xFF1E293B),
    palette: [Color(0xFF0F172A), Color(0xFFD4AF37), Color(0xFFF8FAFC), Color(0xFF94A3B8)],
    icon: LucideIcons.graduationCap,
  ),
  AlbumTemplate(
    id: 'school_drive',
    title: 'Школьный Драйв & Casual',
    subtitle: 'Динамичный и яркий',
    tag: 'ПОПУЛЯРНЫЙ',
    description: 'Живая верстка цитат, яркие акценты и репортажные коллажи для дружного и активного класса.',
    primaryColor: Color(0xFFFF4D4D),
    palette: [Color(0xFFFF4D4D), Color(0xFF3B82F6), Color(0xFFFBBF24), Color(0xFF10B981)],
    icon: LucideIcons.sparkles,
  ),
  AlbumTemplate(
    id: 'minimalism',
    title: 'Минимализм & Ч/Б Эстетика',
    subtitle: 'Воздушный и чистый',
    tag: 'СТИЛЬ',
    description: 'Чистые линии, выверенные поля и акцент на живых эмоциях без визуального шума.',
    primaryColor: Color(0xFF18181B),
    palette: [Color(0xFF09090B), Color(0xFF52525B), Color(0xFFE4E4E7), Color(0xFFFFFFFF)],
    icon: LucideIcons.maximize2,
  ),
  AlbumTemplate(
    id: 'gentle_pastel',
    title: 'Нежная Акварель & Пастель',
    subtitle: 'Мягкий и романтичный',
    tag: 'ТРЕНД',
    description: 'Мягкие пастельные тона, художественные текстуры и каллиграфические заголовки.',
    primaryColor: Color(0xFFEC4899),
    palette: [Color(0xFFF472B6), Color(0xFFFDE047), Color(0xFF93C5FD), Color(0xFFA7F3D0)],
    icon: LucideIcons.palette,
  ),
  AlbumTemplate(
    id: 'vintage_film',
    title: 'Винтаж & Плёнка 90-х',
    subtitle: 'Теплый и ламповый',
    tag: 'РЕТРО',
    description: 'Тёплая ностальгическая гамма, полароидные рамки и зернистая эстетика аналоговой фотографии.',
    primaryColor: Color(0xFFB45309),
    palette: [Color(0xFF92400E), Color(0xFFF59E0B), Color(0xFFFEF3C7), Color(0xFF451A03)],
    icon: LucideIcons.camera,
  ),
  AlbumTemplate(
    id: 'primary_school',
    title: 'Младшая школа & Первоклашки',
    subtitle: 'Весёлый и красочный',
    tag: 'ДЕТСКИЙ',
    description: 'Красочные рамки, забавные стикеры и жизнерадостные развороты для начальной школы.',
    primaryColor: Color(0xFF6366F1),
    palette: [Color(0xFF6366F1), Color(0xFFF59E0B), Color(0xFFEF4444), Color(0xFF10B981)],
    icon: LucideIcons.smile,
  ),
];

class AlbumTemplatesScreen extends StatefulWidget {
  final String albumTitle;
  final String userName;

  const AlbumTemplatesScreen({
    super.key,
    required this.albumTitle,
    required this.userName,
  });

  @override
  State<AlbumTemplatesScreen> createState() => _AlbumTemplatesScreenState();
}

class _AlbumTemplatesScreenState extends State<AlbumTemplatesScreen> {
  AlbumTemplate _selectedTemplate = kAlbumTemplates.first;

  void _proceedToParameters() {
    Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (_) => AlbumParametersScreen(
          albumTitle: widget.albumTitle,
          userName: widget.userName,
          selectedTemplateTitle: _selectedTemplate.title,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PicPacColors.white,
      appBar: AppBar(
        backgroundColor: PicPacColors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          behavior: HitTestBehavior.opaque,
          child: const Center(
            child: Icon(
              LucideIcons.arrowLeft,
              size: 22.0,
              color: PicPacColors.textDark,
            ),
          ),
        ),
        title: Text(
          'Выбор шаблона',
          style: PicPacTypography.h1Title.copyWith(
            fontSize: 17.5,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Подзаголовок и шаг
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
              color: PicPacColors.surfaceGrey.withValues(alpha: 0.5),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                    decoration: BoxDecoration(
                      color: PicPacColors.primaryCoralSoft,
                      borderRadius: BorderRadius.circular(6.0),
                    ),
                    child: Text(
                      'Шаг 1 из 2',
                      style: PicPacTypography.metaInfo.copyWith(
                        color: PicPacColors.primaryCoral,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10.0),
                  Expanded(
                    child: Text(
                      'Выберите стиль и оформление альбома',
                      style: PicPacTypography.metaInfo.copyWith(
                        color: PicPacColors.textDark,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

            // Список шаблонов
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                itemCount: kAlbumTemplates.length,
                separatorBuilder: (context, index) => const SizedBox(height: 14.0),
                itemBuilder: (context, index) {
                  final template = kAlbumTemplates[index];
                  final isSelected = template.id == _selectedTemplate.id;

                  return _buildTemplateCard(template, isSelected);
                },
              ),
            ),

            // Нижняя панель действий
            Container(
              padding: const EdgeInsets.all(20.0),
              decoration: const BoxDecoration(
                color: PicPacColors.white,
                border: Border(
                  top: BorderSide(color: PicPacColors.borderDefault, width: 0.8),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Выбранный стиль:',
                        style: PicPacTypography.metaInfo.copyWith(color: PicPacColors.textMuted),
                      ),
                      const SizedBox(width: 8.0),
                      Expanded(
                        child: Text(
                          _selectedTemplate.title,
                          textAlign: TextAlign.end,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: PicPacTypography.metaInfo.copyWith(
                            fontWeight: FontWeight.w700,
                            color: PicPacColors.textDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12.0),
                  SizedBox(
                    width: double.infinity,
                    height: 52.0,
                    child: ElevatedButton(
                      onPressed: _proceedToParameters,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: PicPacColors.primaryCoral,
                        foregroundColor: PicPacColors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                'Выбрать этот шаблон',
                                style: PicPacTypography.buttonText.copyWith(
                                  fontSize: 15.0,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8.0),
                          const Icon(LucideIcons.arrowRight, size: 18.0),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTemplateCard(AlbumTemplate template, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTemplate = template;
        });
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(14.0),
        decoration: BoxDecoration(
          color: PicPacColors.white,
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(
            color: isSelected ? PicPacColors.primaryCoral : PicPacColors.borderDefault,
            width: isSelected ? 2.0 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected ? PicPacColors.primaryCoral.withValues(alpha: 0.08) : const Color(0x08000000),
              blurRadius: isSelected ? 10.0 : 4.0,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Верхняя плашка: Иконка превью + Тег + Радио-чекмарк
            Row(
              children: [
                Container(
                  width: 38.0,
                  height: 38.0,
                  decoration: BoxDecoration(
                    color: template.primaryColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Icon(
                    template.icon,
                    size: 20.0,
                    color: template.primaryColor,
                  ),
                ),
                const SizedBox(width: 10.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              template.title,
                              style: PicPacTypography.photoCaption.copyWith(
                                fontWeight: FontWeight.w700,
                                fontSize: 15.0,
                                color: PicPacColors.textDark,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 6.0),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
                            decoration: BoxDecoration(
                              color: isSelected ? PicPacColors.primaryCoralSoft : PicPacColors.surfaceGrey,
                              borderRadius: BorderRadius.circular(4.0),
                            ),
                            child: Text(
                              template.tag,
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w700,
                                color: isSelected ? PicPacColors.primaryCoral : PicPacColors.textMuted,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2.0),
                      Text(
                        template.subtitle,
                        style: PicPacTypography.metaInfo.copyWith(
                          color: PicPacColors.textMuted,
                          fontSize: 12.0,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8.0),
                Container(
                  width: 22.0,
                  height: 22.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? PicPacColors.primaryCoral : Colors.transparent,
                    border: Border.all(
                      color: isSelected ? PicPacColors.primaryCoral : PicPacColors.borderDefault,
                      width: 1.8,
                    ),
                  ),
                  child: isSelected
                      ? const Icon(
                          LucideIcons.check,
                          size: 14.0,
                          color: PicPacColors.white,
                        )
                      : null,
                ),
              ],
            ),

            const SizedBox(height: 10.0),

            // Описание шаблона
            Text(
              template.description,
              style: PicPacTypography.metaInfo.copyWith(
                color: PicPacColors.textDark.withValues(alpha: 0.8),
                height: 1.35,
              ),
            ),

            const SizedBox(height: 10.0),

            // Цветовая палитра шаблона
            Row(
              children: [
                Text(
                  'Палитра:',
                  style: PicPacTypography.metaInfo.copyWith(
                    fontSize: 11.5,
                    color: PicPacColors.textMuted,
                  ),
                ),
                const SizedBox(width: 8.0),
                ...template.palette.map((color) {
                  return Container(
                    width: 14.0,
                    height: 14.0,
                    margin: const EdgeInsets.only(right: 6.0),
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.black.withValues(alpha: 0.1),
                        width: 0.8,
                      ),
                    ),
                  );
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
