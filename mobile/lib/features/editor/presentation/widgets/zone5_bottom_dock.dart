import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/picpac_colors.dart';
import '../../../../core/theme/picpac_typography.dart';

class Zone5BottomDock extends StatelessWidget {
  final int filledPagesCount;
  final int totalPagesCount;
  final int coverVotesCount;
  final VoidCallback? onCoverTap;
  final VoidCallback? onLayoutTap;
  final VoidCallback? onOrderTap;

  const Zone5BottomDock({
    super.key,
    required this.filledPagesCount,
    required this.totalPagesCount,
    this.coverVotesCount = 5,
    this.onCoverTap,
    this.onLayoutTap,
    this.onOrderTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: PicPacColors.white,
        border: Border(
          top: BorderSide(
            color: PicPacColors.borderDefault,
            width: 1.0,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64.0,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
            child: Row(
              children: [
                // 1. Кнопка «👑 Обложка» с бейджем голосов
                GestureDetector(
                  onTap: onCoverTap,
                  behavior: HitTestBehavior.opaque,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        height: 44.0,
                        padding: const EdgeInsets.symmetric(horizontal: 14.0),
                        decoration: BoxDecoration(
                          color: PicPacColors.surfaceGrey,
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        alignment: Alignment.center,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            '👑 Обложка',
                            style: PicPacTypography.buttonTextDark,
                          ),
                        ),
                      ),
                      if (coverVotesCount > 0)
                        Positioned(
                          right: -4.0,
                          top: -4.0,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 5.0,
                              vertical: 1.5,
                            ),
                            constraints: const BoxConstraints(minWidth: 18.0),
                            decoration: BoxDecoration(
                              color: PicPacColors.primaryCoral,
                              borderRadius: BorderRadius.circular(10.0),
                              border: Border.all(
                                color: PicPacColors.white,
                                width: 1.5,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                '$coverVotesCount',
                                style: const TextStyle(
                                  color: PicPacColors.white,
                                  fontSize: 10.0,
                                  fontWeight: FontWeight.w700,
                                  height: 1.0,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(width: 12.0),

                // 2. Кнопка «Сетка»
                GestureDetector(
                  onTap: onLayoutTap,
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    width: 44.0,
                    height: 44.0,
                    decoration: BoxDecoration(
                      color: PicPacColors.surfaceGrey,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: const Center(
                      child: Icon(
                        LucideIcons.layoutGrid,
                        size: 20.0,
                        color: PicPacColors.textDark,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 12.0),

                // 3. Главная кнопка «🛒 В заказ» (Expanded)
                Expanded(
                  child: GestureDetector(
                    onTap: onOrderTap,
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      height: 44.0,
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      decoration: BoxDecoration(
                        color: PicPacColors.primaryCoral,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              LucideIcons.shoppingBag,
                              size: 18.0,
                              color: PicPacColors.white,
                            ),
                            const SizedBox(width: 6.0),
                            Text(
                              'В заказ • $filledPagesCount/$totalPagesCount стр.',
                              style: PicPacTypography.buttonText,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

