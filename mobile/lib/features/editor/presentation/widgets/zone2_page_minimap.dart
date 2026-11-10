import 'package:flutter/material.dart';
import '../../../../core/theme/picpac_colors.dart';
import '../../../../core/theme/picpac_typography.dart';
import '../../domain/models.dart';

class Zone2PageMinimap extends StatefulWidget {
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
  State<Zone2PageMinimap> createState() => _Zone2PageMinimapState();
}

class _Zone2PageMinimapState extends State<Zone2PageMinimap> {
  final ScrollController _scrollController = ScrollController();

  static const double _itemWidth = 58.0;
  static const double _itemSpacing = 8.0;
  static const double _horizontalPadding = 12.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToPage(widget.currentPage, animate: false);
    });
  }

  @override
  void didUpdateWidget(covariant Zone2PageMinimap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentPage != widget.currentPage) {
      _scrollToPage(widget.currentPage, animate: true);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToPage(int pageNumber, {required bool animate}) {
    if (!_scrollController.hasClients) return;

    final index = widget.pages.indexWhere((p) => p.pageNumber == pageNumber);
    if (index == -1) return;

    final itemStride = _itemWidth + _itemSpacing;
    final itemCenter = _horizontalPadding + (index * itemStride) + (_itemWidth / 2);
    final viewportWidth = _scrollController.position.viewportDimension;
    final targetOffset = itemCenter - (viewportWidth / 2);

    final clampedOffset = targetOffset.clamp(
      0.0,
      _scrollController.position.maxScrollExtent,
    );

    if (animate) {
      _scrollController.animateTo(
        clampedOffset,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _scrollController.jumpTo(clampedOffset);
    }
  }

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
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(
          horizontal: _horizontalPadding,
          vertical: 4.0,
        ),
        scrollDirection: Axis.horizontal,
        itemCount: widget.pages.length,
        separatorBuilder: (context, index) => const SizedBox(width: _itemSpacing),
        itemBuilder: (context, index) {
          final page = widget.pages[index];
          final isSelected = page.pageNumber == widget.currentPage;

          return GestureDetector(
            onTap: () => widget.onPageSelected(page.pageNumber),
            behavior: HitTestBehavior.opaque,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: _itemWidth,
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
                    children: List.generate(page.slots.length, (dotIndex) {
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
