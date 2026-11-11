import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/widgets/dashed_border_box.dart';
import '../../../../core/widgets/picpac_image.dart';
import '../../domain/album_template_style.dart';
import '../../domain/models.dart';

class Zone3CoverWidget extends StatelessWidget {
  final String albumTitle;
  final String templateId;
  final MediaPoolItem? winningPhoto;
  final int votesCount;
  final int totalVotes;
  final double sheetWidth;
  final double sheetHeight;
  final VoidCallback onVoteTap;
  final VoidCallback onOpenPagesTap;

  const Zone3CoverWidget({
    super.key,
    required this.albumTitle,
    required this.templateId,
    required this.winningPhoto,
    required this.votesCount,
    required this.totalVotes,
    required this.sheetWidth,
    required this.sheetHeight,
    required this.onVoteTap,
    required this.onOpenPagesTap,
  });

  @override
  Widget build(BuildContext context) {
    final style = AlbumTemplateStyle.fromId(templateId);

    return GestureDetector(
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity != null && details.primaryVelocity! < -200) {
          // Свайп влево -> переход к странице 1
          onOpenPagesTap();
        }
      },
      child: Container(
        width: sheetWidth,
        height: sheetHeight,
        decoration: BoxDecoration(
          color: style.coverBackgroundColor,
          borderRadius: BorderRadius.circular(4.0),
          border: Border.all(
            color: style.coverBorderColor.withValues(alpha: 0.6),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 20.0,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Полиграфическая линия безопасности (Print Safe Zone)
            Positioned(
              left: 6.0,
              top: 6.0,
              right: 6.0,
              bottom: 6.0,
              child: IgnorePointer(
                child: DashedBorderBox(
                  color: style.safeZoneColor.withValues(alpha: 0.35),
                  strokeWidth: 1.0,
                  dashLength: 4.0,
                  dashGap: 4.0,
                  borderRadius: 2.0,
                ),
              ),
            ),

            // Имитация деликатного корешка книги слева
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: Container(
                width: 10.0,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.horizontal(left: Radius.circular(3.0)),
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withValues(alpha: 0.28),
                      Colors.black.withValues(alpha: 0.05),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // Содержимое обложки
            Padding(
              padding: const EdgeInsets.fromLTRB(18.0, 14.0, 16.0, 14.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Верхний бейдж стиля + Индикатор голосов
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.5),
                          decoration: BoxDecoration(
                            color: style.coverAccentColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12.0),
                            border: Border.all(
                              color: style.coverAccentColor.withValues(alpha: 0.4),
                              width: 1.0,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                style.icon,
                                size: 12.0,
                                color: style.coverAccentColor,
                              ),
                              const SizedBox(width: 4.0),
                              Flexible(
                                child: Text(
                                  style.coverBadgeText,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 10.0,
                                    fontWeight: FontWeight.w700,
                                    color: style.coverAccentColor,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.5),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('👑', style: TextStyle(fontSize: 10.5)),
                            const SizedBox(width: 4.0),
                            Text(
                              votesCount > 0 ? '$votesCount голосов' : 'Обложка',
                              style: TextStyle(
                                color: style.coverTextColor,
                                fontSize: 10.0,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10.0),

                  // Заголовок альбома
                  Text(
                    albumTitle.toUpperCase(),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: (sheetHeight * 0.045).clamp(15.0, 22.0),
                      fontWeight: FontWeight.w900,
                      letterSpacing: style.headlineLetterSpacing,
                      color: style.coverTextColor,
                    ),
                  ),

                  const SizedBox(height: 10.0),

                  // Главная фотография-победитель обложки
                  Expanded(
                    child: GestureDetector(
                      onTap: onVoteTap,
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(style.slotBorderRadius.clamp(4.0, 12.0)),
                          border: Border.all(
                            color: style.coverAccentColor,
                            width: 2.0,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 10.0,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(
                            (style.slotBorderRadius.clamp(4.0, 12.0) - 2.0).clamp(2.0, 10.0),
                          ),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              if (winningPhoto != null)
                                PicPacImage(
                                  imageUrl: winningPhoto!.imageUrl,
                                  borderRadius: BorderRadius.zero,
                                )
                              else
                                Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        LucideIcons.crown,
                                        size: 32.0,
                                        color: style.coverAccentColor,
                                      ),
                                      const SizedBox(height: 6.0),
                                      Text(
                                        'Нажмите, чтобы выбрать\nглавное фото обложки',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: style.coverTextColor.withValues(alpha: 0.8),
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                              // Бейдж лидера на самом фото
                              Positioned(
                                left: 8.0,
                                bottom: 8.0,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.75),
                                    borderRadius: BorderRadius.circular(6.0),
                                    border: Border.all(color: style.coverAccentColor, width: 1.0),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Text('👑', style: TextStyle(fontSize: 10.5)),
                                      const SizedBox(width: 4.0),
                                      Text(
                                        votesCount > 0 ? 'Лидер обложки ($votesCount)' : 'Главное фото',
                                        style: TextStyle(
                                          color: style.coverTextColor,
                                          fontSize: 10.0,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10.0),

                  // Нижний подзаголовок обложки
                  Text(
                    'ФОТОКНИГА • 2026',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 10.0,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 2.5,
                      color: style.coverTextColor.withValues(alpha: 0.7),
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
