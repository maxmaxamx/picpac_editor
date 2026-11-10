import 'package:flutter/material.dart';
import '../../../../core/widgets/dashed_border_box.dart';
import '../../domain/album_template_style.dart';
import '../../domain/models.dart';
import 'zone3_cover_widget.dart';
import 'zone3_floating_pill.dart';
import 'zone3_slot_widget.dart';

class Zone3SpreadCanvas extends StatelessWidget {
  final PageModel page;
  final int totalPages;
  final ValueChanged<int> onPageChange;
  final ValueChanged<SlotModel> onSlotTap;
  final double aspectRatio;
  final String templateId;
  final String albumTitle;
  final MediaPoolItem? winningPhoto;
  final int votesCount;
  final int totalVotes;
  final VoidCallback? onVoteTap;

  const Zone3SpreadCanvas({
    super.key,
    required this.page,
    required this.totalPages,
    required this.onPageChange,
    required this.onSlotTap,
    this.aspectRatio = 3.0 / 4.0,
    this.templateId = 'school_drive',
    this.albumTitle = 'Выпускной альбом',
    this.winningPhoto,
    this.votesCount = 0,
    this.totalVotes = 0,
    this.onVoteTap,
  });

  @override
  Widget build(BuildContext context) {
    final style = AlbumTemplateStyle.fromId(templateId);

    // 1. Первая страница в редакторе — Презентация твердой обложки (Cover)
    if (page.pageNumber == 0) {
      return Container(
        width: double.infinity,
        height: double.infinity,
        color: style.canvasBackgroundColor,
        child: Column(
          children: [
            Expanded(
              child: Zone3CoverWidget(
                albumTitle: albumTitle,
                templateId: templateId,
                winningPhoto: winningPhoto,
                votesCount: votesCount,
                totalVotes: totalVotes,
                onVoteTap: onVoteTap ?? () {},
                onOpenPagesTap: () => onPageChange(1),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Zone3FloatingPill(
                currentPage: 0,
                totalPages: totalPages,
                onPageChange: onPageChange,
              ),
            ),
          ],
        ),
      );
    }

    // 2. Внутренние страницы книги (Развороты со слотами), оформленные по стилю выбранного шаблона
    return LayoutBuilder(
      builder: (context, constraints) {
        // Доступное пространство
        const double pillHeight = 36.0;
        const double pillMarginTop = 10.0;
        const double verticalPadding = 12.0;

        final double maxAvailableHeight = constraints.maxHeight -
            pillHeight -
            pillMarginTop -
            verticalPadding * 2;
        final double maxAvailableWidth = constraints.maxWidth - 32.0; // отступы по бокам 16px

        // Пропорции листа (1:1 для 20×20 или 3:4 для 21×30)
        double sheetWidth = maxAvailableWidth;
        double sheetHeight = sheetWidth / aspectRatio;

        if (sheetHeight > maxAvailableHeight) {
          sheetHeight = maxAvailableHeight;
          sheetWidth = sheetHeight * aspectRatio;
        }

        return Container(
          width: double.infinity,
          height: constraints.maxHeight,
          color: style.canvasBackgroundColor,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Лист фотокниги в стилистике шаблона с поддержкой горизонтального свайпа
              GestureDetector(
                onHorizontalDragEnd: (details) {
                  if (details.primaryVelocity != null) {
                    if (details.primaryVelocity! < -200 &&
                        page.pageNumber < totalPages) {
                      // Свайп влево -> следующая страница
                      onPageChange(page.pageNumber + 1);
                    } else if (details.primaryVelocity! > 200) {
                      // Свайп вправо -> предыдущая страница (если страница 1, возврат на обложку 0)
                      onPageChange(page.pageNumber - 1);
                    }
                  }
                },
                child: Container(
                  width: sheetWidth,
                  height: sheetHeight,
                  decoration: BoxDecoration(
                    color: style.sheetBackgroundColor,
                    borderRadius: BorderRadius.circular(4.0),
                    border: Border.all(
                      color: style.sheetBorderColor.withValues(alpha: 0.4),
                      width: 1.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 20.0,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // Фоновый стикер/водяной знак выбранного шаблона вверху страницы
                      Positioned(
                        right: 14.0,
                        top: 10.0,
                        child: Opacity(
                          opacity: 0.45,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(style.icon, size: 11.0, color: style.accentColor),
                              const SizedBox(width: 4.0),
                              Text(
                                '${style.fontTag} • СТР. ${page.pageNumber}',
                                style: TextStyle(
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.6,
                                  color: style.accentColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Полиграфическая линия безопасности (Print Safe Zone):
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

                      // Сетка слотов в зависимости от выбранного лейаута (1, 2, 3 или 4 слота)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(14.0, 24.0, 14.0, 14.0),
                        child: _buildDynamicLayout(style.slotBorderRadius),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: pillMarginTop),

              // Плавающий переключатель разворота (Floating Spread Pill)
              Zone3FloatingPill(
                currentPage: page.pageNumber,
                totalPages: totalPages,
                onPageChange: onPageChange,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDynamicLayout(double slotRadius) {
    final slots = page.slots;

    if (slots.length <= 1) {
      // 1 слот: на всю страницу
      final slot0 = slots.isNotEmpty ? slots[0] : _fallbackSlot(0);
      return Zone3SlotWidget(
        slot: slot0,
        onTap: () => onSlotTap(slot0),
        borderRadius: slotRadius,
      );
    }

    if (slots.length == 2) {
      // 2 слота: верх и низ
      return Column(
        children: [
          Expanded(
            child: Zone3SlotWidget(
              slot: slots[0],
              onTap: () => onSlotTap(slots[0]),
              borderRadius: slotRadius,
            ),
          ),
          const SizedBox(height: 8.0),
          Expanded(
            child: Zone3SlotWidget(
              slot: slots[1],
              onTap: () => onSlotTap(slots[1]),
              borderRadius: slotRadius,
            ),
          ),
        ],
      );
    }

    if (slots.length == 3) {
      // 3 слота: 1 сверху широкий, 2 снизу
      return Column(
        children: [
          Expanded(
            flex: 5,
            child: Zone3SlotWidget(
              slot: slots[0],
              onTap: () => onSlotTap(slots[0]),
              borderRadius: slotRadius,
            ),
          ),
          const SizedBox(height: 8.0),
          Expanded(
            flex: 4,
            child: Row(
              children: [
                Expanded(
                  child: Zone3SlotWidget(
                    slot: slots[1],
                    onTap: () => onSlotTap(slots[1]),
                    borderRadius: slotRadius,
                  ),
                ),
                const SizedBox(width: 8.0),
                Expanded(
                  child: Zone3SlotWidget(
                    slot: slots[2],
                    onTap: () => onSlotTap(slots[2]),
                    borderRadius: slotRadius,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    // 4 слота: сетка 2×2 (по умолчанию)
    return Column(
      children: [
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: Zone3SlotWidget(
                  slot: slots[0],
                  onTap: () => onSlotTap(slots[0]),
                  borderRadius: slotRadius,
                ),
              ),
              const SizedBox(width: 8.0),
              Expanded(
                child: Zone3SlotWidget(
                  slot: slots[1],
                  onTap: () => onSlotTap(slots[1]),
                  borderRadius: slotRadius,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8.0),
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: Zone3SlotWidget(
                  slot: slots.length > 2 ? slots[2] : _fallbackSlot(2),
                  onTap: () => onSlotTap(slots.length > 2 ? slots[2] : _fallbackSlot(2)),
                  borderRadius: slotRadius,
                ),
              ),
              const SizedBox(width: 8.0),
              Expanded(
                child: Zone3SlotWidget(
                  slot: slots.length > 3 ? slots[3] : _fallbackSlot(3),
                  onTap: () => onSlotTap(slots.length > 3 ? slots[3] : _fallbackSlot(3)),
                  borderRadius: slotRadius,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  SlotModel _fallbackSlot(int index) {
    return SlotModel(
      id: 'fallback_slot_$index',
      slotIndex: index,
      status: SlotStatus.empty,
    );
  }
}
