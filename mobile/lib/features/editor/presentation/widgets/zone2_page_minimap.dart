import 'package:flutter/material.dart';
import '../../../../core/theme/picpac_colors.dart';
import '../../../../core/theme/picpac_typography.dart';
import '../../domain/models.dart';

class Zone2PageMinimap extends StatelessWidget {
  final List<PageModel> pages;
  final int currentPage;
  final ValueChanged<int> onPageSelected;

  const Zone2PageMinimap({
    super.key,
    required this.pages,
    required this.currentPage,
    required this.onPageSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44.0,
      decoration: const BoxDecoration(
        color: PicPacColors.surfaceGrey,
        border: Border(
          bottom: BorderSide(
            color: PicPacColors.borderDefault,
            width: 1.0,
          ),
        ),
      ),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
        scrollDirection: Axis.horizontal,
        itemCount: pages.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8.0),
        itemBuilder: (context, index) {
          final page = pages[index];
          final isSelected = page.pageNumber == currentPage;

          return GestureDetector(
            onTap: () => onPageSelected(page.pageNumber),
            behavior: HitTestBehavior.opaque,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 58.0,
              decoration: BoxDecoration(
                color: isSelected ? PicPacColors.white : PicPacColors.surfaceGrey,
                borderRadius: BorderRadius.circular(6.0),
                border: Border.all(
                  color: isSelected
                      ? PicPacColors.primaryCoral
                      : PicPacColors.borderDefault,
                  width: isSelected ? 1.5 : 1.0,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Стр. ${page.pageNumber}',
                    style: PicPacTypography.metaInfo.copyWith(
                      fontSize: 10.0,
                      height: 1.1,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected
                          ? PicPacColors.textDark
                          : PicPacColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 2.0),
                  // Индикация заполнения слотов (■ ■ □ □)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(4, (dotIndex) {
                      final isSlotFilled =
                          dotIndex < page.filledSlotsCount;
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 1.0),
                        width: 4.0,
                        height: 4.0,
                        decoration: BoxDecoration(
                          color: isSlotFilled
                              ? (isSelected
                                  ? PicPacColors.primaryCoral
                                  : PicPacColors.textDark)
                              : PicPacColors.borderDashed,
                          borderRadius: BorderRadius.circular(1.0),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

