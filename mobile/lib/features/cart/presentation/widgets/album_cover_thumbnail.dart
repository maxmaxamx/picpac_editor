import 'package:flutter/material.dart';
import '../../../../core/widgets/dashed_border_box.dart';
import '../../../../core/widgets/picpac_image.dart';
import '../../../editor/domain/album_template_style.dart';

/// Реалистичное миниатюрное превью твердой обложки фотокниги
class AlbumCoverThumbnail extends StatelessWidget {
  final String title;
  final String templateId;
  final String? coverImageUrl;
  final double width;
  final double height;

  const AlbumCoverThumbnail({
    super.key,
    required this.title,
    required this.templateId,
    this.coverImageUrl,
    this.width = 82.0,
    this.height = 100.0,
  });

  @override
  Widget build(BuildContext context) {
    final style = AlbumTemplateStyle.fromId(templateId);

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: style.coverBackgroundColor,
        borderRadius: BorderRadius.circular(5.0),
        border: Border.all(
          color: style.coverBorderColor.withValues(alpha: 0.7),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 8.0,
            offset: const Offset(1, 3),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 2.0,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4.0),
        child: Stack(
          children: [
            // Линия безопасной зоны обложки
            Positioned(
              left: 4.0,
              top: 4.0,
              right: 4.0,
              bottom: 4.0,
              child: IgnorePointer(
                child: DashedBorderBox(
                  color: style.safeZoneColor.withValues(alpha: 0.35),
                  strokeWidth: 0.8,
                  dashLength: 3.0,
                  dashGap: 3.0,
                  borderRadius: 2.0,
                ),
              ),
            ),

            // Имитация объемного корешка книги слева
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: Container(
                width: 7.0,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withValues(alpha: 0.35),
                      Colors.black.withValues(alpha: 0.10),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // Содержимое обложки
            Padding(
              padding: const EdgeInsets.fromLTRB(9.0, 7.0, 6.0, 6.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Название книги
                  Text(
                    title.toUpperCase(),
                    maxLines: 2,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 7.2,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.4,
                      color: style.coverTextColor,
                      height: 1.1,
                    ),
                  ),

                  const SizedBox(height: 5.0),

                  // Центральная миниатюра фотографии или значок
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(3.0),
                        border: Border.all(
                          color: style.coverAccentColor.withValues(alpha: 0.8),
                          width: 1.0,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(2.0),
                        child: coverImageUrl != null && coverImageUrl!.isNotEmpty
                            ? PicPacImage(
                                imageUrl: coverImageUrl!,
                                borderRadius: BorderRadius.zero,
                              )
                            : Center(
                                child: Icon(
                                  style.icon,
                                  size: 18.0,
                                  color: style.coverAccentColor,
                                ),
                              ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 4.0),

                  // Нижняя надпись фотокниги
                  Center(
                    child: Text(
                      'PICPAC • 20×20',
                      style: TextStyle(
                        fontSize: 5.8,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                        color: style.coverTextColor.withValues(alpha: 0.65),
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
}
