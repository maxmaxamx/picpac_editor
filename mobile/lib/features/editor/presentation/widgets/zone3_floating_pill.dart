import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/picpac_colors.dart';
import '../../../../core/theme/picpac_typography.dart';

class Zone3FloatingPill extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final ValueChanged<int> onPageChange;

  const Zone3FloatingPill({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.onPageChange,
  });

  @override
  Widget build(BuildContext context) {
    if (currentPage == 0) {
      return Container(
        height: 36.0,
        padding: const EdgeInsets.symmetric(horizontal: 14.0),
        decoration: BoxDecoration(
          color: PicPacColors.textDark,
          borderRadius: BorderRadius.circular(20.0),
          boxShadow: const [
            BoxShadow(
              color: Color(0x26000000),
              blurRadius: 10.0,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('👑', style: TextStyle(fontSize: 13.0)),
            const SizedBox(width: 6.0),
            Text(
              'Обложка альбома',
              style: PicPacTypography.buttonText.copyWith(
                fontSize: 12.0,
                fontWeight: FontWeight.w700,
                color: PicPacColors.white,
              ),
            ),
            const SizedBox(width: 10.0),
            Container(
              width: 1.0,
              height: 14.0,
              color: PicPacColors.white.withValues(alpha: 0.2),
            ),
            const SizedBox(width: 8.0),
            GestureDetector(
              onTap: () => onPageChange(1),
              behavior: HitTestBehavior.opaque,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Стр. 1',
                    style: PicPacTypography.buttonText.copyWith(
                      fontSize: 12.0,
                      fontWeight: FontWeight.w500,
                      color: PicPacColors.primaryCoral,
                    ),
                  ),
                  const SizedBox(width: 4.0),
                  const Icon(
                    LucideIcons.chevronRight,
                    size: 14.0,
                    color: PicPacColors.primaryCoral,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // В типографии книги разворот состоит из левой (четной) и правой (нечетной) страниц
    final int leftPage = currentPage % 2 == 0 ? currentPage : currentPage - 1;
    final int rightPage = leftPage + 1;

    final bool isLeftActive = currentPage == leftPage;
    final bool isRightActive = currentPage == rightPage;

    return Container(
      height: 36.0,
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      decoration: BoxDecoration(
        color: PicPacColors.textDark,
        borderRadius: BorderRadius.circular(20.0),
        boxShadow: const [
          BoxShadow(
            color: Color(0x26000000),
            blurRadius: 10.0,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Левая страница / Обложка
            GestureDetector(
              onTap: () {
                if (currentPage == 1) {
                  onPageChange(0);
                } else if (leftPage >= 1) {
                  onPageChange(leftPage);
                }
              },
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 4.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      LucideIcons.chevronLeft,
                      size: 14.0,
                      color: isLeftActive
                          ? PicPacColors.primaryCoral
                          : PicPacColors.white.withValues(alpha: 0.7),
                    ),
                    const SizedBox(width: 4.0),
                    Text(
                      currentPage == 1 ? '👑 Обложка' : 'Левая (Стр. $leftPage)',
                      style: PicPacTypography.buttonText.copyWith(
                        fontSize: 12.0,
                        fontWeight:
                            isLeftActive ? FontWeight.w700 : FontWeight.w500,
                        color: isLeftActive
                            ? PicPacColors.white
                            : PicPacColors.white.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Разделитель
            Container(
              width: 1.0,
              height: 14.0,
              margin: const EdgeInsets.symmetric(horizontal: 4.0),
              color: PicPacColors.white.withValues(alpha: 0.2),
            ),

            // Правая страница
            GestureDetector(
              onTap: () {
                if (rightPage <= totalPages) onPageChange(rightPage);
              },
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 4.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Правая (Стр. $rightPage)',
                      style: PicPacTypography.buttonText.copyWith(
                        fontSize: 12.0,
                        fontWeight:
                            isRightActive ? FontWeight.w700 : FontWeight.w500,
                        color: isRightActive
                            ? PicPacColors.white
                            : PicPacColors.white.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(width: 4.0),
                    Icon(
                      LucideIcons.chevronRight,
                      size: 14.0,
                      color: isRightActive
                          ? PicPacColors.primaryCoral
                          : PicPacColors.white.withValues(alpha: 0.7),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
