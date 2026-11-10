import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/picpac_colors.dart';
import '../../../../core/theme/picpac_typography.dart';
import '../../../../core/widgets/picpac_image.dart';
import '../../domain/models.dart';

class Zone4MediaPool extends StatelessWidget {
  final List<MediaPoolItem> photos;
  final ValueChanged<MediaPoolItem> onPhotoTap;
  final VoidCallback? onUploadTap;
  final VoidCallback? onExpandTap;

  const Zone4MediaPool({
    super.key,
    required this.photos,
    required this.onPhotoTap,
    this.onUploadTap,
    this.onExpandTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 98.0,
      decoration: const BoxDecoration(
        color: PicPacColors.white,
        border: Border(
          top: BorderSide(
            color: PicPacColors.borderDefault,
            width: 1.0,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Шапка панели (28px) с кнопкой разворачивания на весь экран и добавления фото
          SizedBox(
            height: 28.0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: GestureDetector(
                      onTap: onExpandTap,
                      behavior: HitTestBehavior.opaque,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Общий пул (${photos.length})',
                              style: PicPacTypography.h2Section.copyWith(
                                fontSize: 13.0,
                              ),
                            ),
                            const SizedBox(width: 4.0),
                            const Icon(
                              LucideIcons.maximize2,
                              size: 13.0,
                              color: PicPacColors.textDark,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  Flexible(
                    child: GestureDetector(
                      onTap: onUploadTap,
                      behavior: HitTestBehavior.opaque,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerRight,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              LucideIcons.imagePlus,
                              size: 14.0,
                              color: PicPacColors.primaryCoral,
                            ),
                            const SizedBox(width: 4.0),
                            Text(
                              '+ Добавить фото',
                              style: PicPacTypography.buttonText.copyWith(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                                color: PicPacColors.primaryCoral,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Лента превью (60px) с квадратными миниатюрами 54×54px
          SizedBox(
            height: 60.0,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 3.0,
              ),
              scrollDirection: Axis.horizontal,
              itemCount: photos.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8.0),
              itemBuilder: (context, index) {
                final photo = photos[index];
                return GestureDetector(
                  onTap: () => onPhotoTap(photo),
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    width: 54.0,
                    height: 54.0,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6.0),
                      border: Border.all(
                        color: PicPacColors.borderDefault,
                        width: 1.0,
                      ),
                    ),
                    child: PicPacImage(
                      imageUrl: photo.imageUrl,
                      borderRadius: BorderRadius.circular(6.0),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
