import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/picpac_colors.dart';
import '../../../../core/theme/picpac_typography.dart';
import '../../../../core/widgets/picpac_image.dart';
import '../../domain/album_template_style.dart';
import '../../domain/models.dart';

class Zone3CoverWidget extends StatelessWidget {
  final String albumTitle;
  final String templateId;
  final MediaPoolItem? winningPhoto;
  final int votesCount;
  final int totalVotes;
  final VoidCallback onVoteTap;
  final VoidCallback onOpenPagesTap;

  const Zone3CoverWidget({
    super.key,
    required this.albumTitle,
    required this.templateId,
    required this.winningPhoto,
    required this.votesCount,
    required this.totalVotes,
    required this.onVoteTap,
    required this.onOpenPagesTap,
  });

  @override
  Widget build(BuildContext context) {
    final style = AlbumTemplateStyle.fromId(templateId);

    return LayoutBuilder(
      builder: (context, constraints) {
        final photoHeight = (constraints.maxWidth * 0.52).clamp(140.0, 220.0);

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 1. Презентация твердой обложки альбома (Hardcover Album Presentation)
                Container(
                  decoration: BoxDecoration(
                    color: style.coverBackgroundColor,
                    borderRadius: BorderRadius.circular(10.0),
                    border: Border.all(color: style.coverBorderColor, width: 2.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.25),
                        blurRadius: 18.0,
                        offset: const Offset(0, 8),
                      ),
                      BoxShadow(
                        color: style.coverAccentColor.withValues(alpha: 0.15),
                        blurRadius: 10.0,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // Имитация книжного корешка слева (Spine Highlight)
                      Positioned(
                        left: 0,
                        top: 0,
                        bottom: 0,
                        child: Container(
                          width: 14.0,
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.horizontal(left: Radius.circular(8.0)),
                            gradient: LinearGradient(
                              colors: [
                                Colors.black.withValues(alpha: 0.35),
                                Colors.white.withValues(alpha: 0.08),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Содержимое обложки
                      Padding(
                        padding: const EdgeInsets.fromLTRB(22.0, 14.0, 18.0, 14.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Верхний бейдж стиля + Индикатор голосов
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                                    decoration: BoxDecoration(
                                      color: style.coverAccentColor.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(16.0),
                                      border: Border.all(
                                        color: style.coverAccentColor.withValues(alpha: 0.5),
                                        width: 1.0,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          style.icon,
                                          size: 13.0,
                                          color: style.coverAccentColor,
                                        ),
                                        const SizedBox(width: 4.0),
                                        Flexible(
                                          child: Text(
                                            style.coverBadgeText,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 10.5,
                                              fontWeight: FontWeight.w700,
                                              letterSpacing: 0.5,
                                              color: style.coverAccentColor,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8.0),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.0),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.4),
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Text('👑', style: TextStyle(fontSize: 11.0)),
                                      const SizedBox(width: 4.0),
                                      Text(
                                        votesCount > 0 ? '$votesCount голосов' : 'Обложка',
                                        style: TextStyle(
                                          color: style.coverTextColor,
                                          fontSize: 10.5,
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
                              albumTitle,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.2,
                                color: style.coverTextColor,
                              ),
                            ),

                            const SizedBox(height: 10.0),

                            // Главная фотография-победитель обложки
                            GestureDetector(
                              onTap: onVoteTap,
                              behavior: HitTestBehavior.opaque,
                              child: Container(
                                height: photoHeight,
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(style.slotBorderRadius.clamp(4.0, 14.0)),
                                  border: Border.all(
                                    color: style.coverAccentColor,
                                    width: 2.0,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.3),
                                      blurRadius: 10.0,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(
                                    (style.slotBorderRadius.clamp(4.0, 14.0) - 2.0).clamp(2.0, 12.0),
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
                                                  fontSize: 12.0,
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
                                              const Text('👑', style: TextStyle(fontSize: 11.0)),
                                              const SizedBox(width: 4.0),
                                              Text(
                                                votesCount > 0
                                                    ? 'Выбор обложки ($votesCount)'
                                                    : 'Выбор обложки',
                                                style: TextStyle(
                                                  color: style.coverTextColor,
                                                  fontSize: 10.5,
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

                            const SizedBox(height: 10.0),

                            // Кнопка голосования за обложку
                            GestureDetector(
                              onTap: onVoteTap,
                              behavior: HitTestBehavior.opaque,
                              child: Container(
                                height: 38.0,
                                decoration: BoxDecoration(
                                  color: style.coverAccentColor,
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                alignment: Alignment.center,
                                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(LucideIcons.vote, size: 15.0, color: Colors.white),
                                    const SizedBox(width: 6.0),
                                    Flexible(
                                      child: Text(
                                        totalVotes > 0
                                            ? 'Голосовать за обложку ($totalVotes)'
                                            : 'Голосовать за обложку',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12.0,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
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

                const SizedBox(height: 10.0),

                // 2. Кнопка перехода к разворотам альбома
                GestureDetector(
                  onTap: onOpenPagesTap,
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    height: 40.0,
                    decoration: BoxDecoration(
                      color: PicPacColors.white,
                      borderRadius: BorderRadius.circular(8.0),
                      border: Border.all(color: PicPacColors.borderDefault),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Text(
                            'Перейти к страницам (Стр. 1)',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: PicPacTypography.buttonTextDark.copyWith(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6.0),
                        const Icon(
                          LucideIcons.arrowRight,
                          size: 15.0,
                          color: PicPacColors.textDark,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
