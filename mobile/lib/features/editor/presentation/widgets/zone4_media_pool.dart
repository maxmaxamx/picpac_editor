import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/picpac_colors.dart';
import '../../../../core/theme/picpac_typography.dart';
import '../../domain/models.dart';

class Zone4MediaPool extends StatelessWidget {
  final List<MediaPoolItem> photos;
  final ValueChanged<MediaPoolItem> onPhotoTap;
  final VoidCallback? onUploadTap;

  const Zone4MediaPool({
    super.key,
    required this.photos,
    required this.onPhotoTap,
    this.onUploadTap,
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
          // Шапка панели (28px)
          SizedBox(
            height: 28.0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Общий пул фото (${photos.length})',
                      style: PicPacTypography.h2Section.copyWith(
                        fontSize: 13.0,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  GestureDetector(
                    onTap: onUploadTap,
                    behavior: HitTestBehavior.opaque,
                    child: Text(
                      '+ Загрузить с телефона',
                      style: PicPacTypography.buttonText.copyWith(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: PicPacColors.primaryCoral,
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
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6.0),
                      child: CachedNetworkImage(
                        imageUrl: photo.imageUrl,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: PicPacColors.surfaceGrey,
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: PicPacColors.surfaceGrey,
                          child: const Icon(
                            LucideIcons.image,
                            size: 18.0,
                            color: PicPacColors.textMuted,
                          ),
                        ),
                      ),
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

