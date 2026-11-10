import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/picpac_colors.dart';
import '../../../../core/theme/picpac_typography.dart';
import '../../../../core/widgets/dashed_border_box.dart';
import '../../../../core/widgets/picpac_image.dart';
import '../../domain/models.dart';

class Zone3SlotWidget extends StatelessWidget {
  final SlotModel slot;
  final VoidCallback onTap;
  final double borderRadius;

  const Zone3SlotWidget({
    super.key,
    required this.slot,
    required this.onTap,
    this.borderRadius = 6.0,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    switch (slot.status) {
      case SlotStatus.empty:
        return _buildEmptyState();
      case SlotStatus.selected:
        return _buildSelectedState();
      case SlotStatus.locked:
        return _buildLockedState();
      case SlotStatus.filled:
        return _buildFilledState();
    }
  }

  /// Состояние А — Пустой слот: Фон #F5F5F5, пунктирная рамка #D4D4D4.
  /// В центре иконка + (#1A1A1A) и текст «Выбрать слот».
  Widget _buildEmptyState() {
    return DashedBorderBox(
      color: PicPacColors.borderDashed,
      strokeWidth: 1.0,
      dashLength: 4.0,
      dashGap: 4.0,
      borderRadius: borderRadius,
      backgroundColor: PicPacColors.surfaceGrey,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                LucideIcons.plus,
                size: 20.0,
                color: PicPacColors.textDark,
              ),
              const SizedBox(height: 4.0),
              Text(
                'Выбрать слот',
                style: PicPacTypography.photoCaption.copyWith(
                  fontSize: 11.5,
                  color: PicPacColors.textDark,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Состояние Б — Выбран текущим пользователем:
  /// Сплошная рамка 2px solid #FF4D4D, фон #FFF0F0, текст «Выберите фото снизу ↓».
  Widget _buildSelectedState() {
    return Container(
      decoration: BoxDecoration(
        color: PicPacColors.primaryCoralSoft,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: PicPacColors.primaryCoral,
          width: 2.0,
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                LucideIcons.arrowDown,
                size: 18.0,
                color: PicPacColors.primaryCoral,
              ),
              const SizedBox(height: 4.0),
              Text(
                'Выберите фото снизу ↓',
                style: PicPacTypography.photoCaption.copyWith(
                  fontSize: 11.0,
                  fontWeight: FontWeight.w600,
                  color: PicPacColors.primaryCoral,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Состояние В — Заблокирован другим участником (Realtime Lock):
  /// Фон #F5F5F5, рамка #D4D4D4, по центру иконка замка, имя участника и обратный отсчет («Алина выбирает... 00:48»).
  Widget _buildLockedState() {
    final lockedName = slot.lockedByName ?? 'Алина';
    final remainingTime = slot.lockRemainingTime ?? '00:48';

    return DashedBorderBox(
      color: PicPacColors.borderDashed,
      strokeWidth: 1.0,
      dashLength: 4.0,
      dashGap: 4.0,
      borderRadius: borderRadius,
      backgroundColor: PicPacColors.surfaceGrey,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                LucideIcons.lock,
                size: 16.0,
                color: PicPacColors.textMuted,
              ),
              const SizedBox(height: 4.0),
              Text(
                '$lockedName выбирает...',
                style: PicPacTypography.metaInfo.copyWith(
                  fontSize: 10.5,
                  color: PicPacColors.textMuted,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2.0),
              Text(
                remainingTime,
                style: PicPacTypography.metaInfo.copyWith(
                  fontSize: 11.0,
                  fontWeight: FontWeight.w600,
                  color: PicPacColors.textDark,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Состояние Г — Заполненный слот:
  /// - Изображение (BoxFit.cover).
  /// - В правом нижнем углу фото — полупрозрачная белая капсула с реакциями (❤️ 4  🔥 2).
  /// - Под фото — строка подписи (photoCaption, 1 строка) и микро-бейдж автора (metaInfo).
  Widget _buildFilledState() {
    final showCaption = slot.caption != null &&
        slot.caption!.trim().isNotEmpty &&
        slot.caption!.trim().toLowerCase() != 'фото из пула';
    final showAuthor = slot.authorName != null &&
        slot.authorName!.trim().isNotEmpty &&
        slot.authorName!.trim().toLowerCase() != 'участник';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Фото с полупрозрачной капсулой реакций
        Expanded(
          child: Stack(
            fit: StackFit.expand,
            children: [
              PicPacImage(
                imageUrl: slot.imageUrl,
                borderRadius: BorderRadius.circular(borderRadius),
              ),

              // Капсула реакций в правом нижнем углу фото
              if (slot.reactions.isNotEmpty)
                Positioned(
                  right: 4.0,
                  bottom: 4.0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6.0,
                      vertical: 2.5,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xEBFFFFFF),
                      borderRadius: BorderRadius.circular(12.0),
                      border: Border.all(
                        color: PicPacColors.borderDefault,
                        width: 0.5,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (final entry in slot.reactions.entries) ...[
                          Text(
                            '${entry.key} ${entry.value}',
                            style: const TextStyle(
                              fontSize: 10.0,
                              fontWeight: FontWeight.w600,
                              color: PicPacColors.textDark,
                            ),
                          ),
                          if (entry.key != slot.reactions.keys.last)
                            const SizedBox(width: 4.0),
                        ],
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),

        const SizedBox(height: 3.0),

        // Подпись под фото и микро-бейдж автора
        if (showCaption || showAuthor)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 1.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (showCaption)
                  Text(
                    slot.caption!,
                    style: PicPacTypography.photoCaption.copyWith(
                      fontSize: 11.0,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                if (showAuthor)
                  Text(
                    slot.authorName!.startsWith('добавил')
                        ? slot.authorName!
                        : 'добавил ${slot.authorName}',
                    style: PicPacTypography.metaInfo.copyWith(
                      fontSize: 9.5,
                      color: PicPacColors.textMuted,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

