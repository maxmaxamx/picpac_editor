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

    // Холст книги (Обложка и страницы) в едином полиграфическом формате и пропорциях
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

        // Пропорции листа (1:1 для 20×20 или 3:4 для 21×30) — обложка и страницы идентичны
        double sheetWidth = maxAvailableWidth;
        double sheetHeight = sheetWidth / aspectRatio;

        if (sheetHeight > maxAvailableHeight) {
          sheetHeight = maxAvailableHeight;
          sheetWidth = sheetHeight * aspectRatio;
        }

        final bool isCover = page.pageNumber == 0;

        return Container(
          width: double.infinity,
          height: constraints.maxHeight,
          color: style.canvasBackgroundColor,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isCover)
                Zone3CoverWidget(
                  albumTitle: albumTitle,
                  templateId: templateId,
                  winningPhoto: winningPhoto,
                  votesCount: votesCount,
                  totalVotes: totalVotes,
                  sheetWidth: sheetWidth,
                  sheetHeight: sheetHeight,
                  onVoteTap: onVoteTap ?? () {},
                  onOpenPagesTap: () => onPageChange(1),
                )
              else
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
                        child: _buildDynamicLayout(style),
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

  Widget _buildDynamicLayout(AlbumTemplateStyle style) {
    final slots = page.slots;
    final slotRadius = style.slotBorderRadius;
    final layout = page.layoutType;

    // 1. Полностраничное фото (1 фото на всю страницу / панорама)
    if (layout == 'single_full' || (slots.length <= 1 && layout != 'hero_centered')) {
      final slot0 = slots.isNotEmpty ? slots[0] : _fallbackSlot(0);
      return Zone3SlotWidget(
        slot: slot0,
        onTap: () => onSlotTap(slot0),
        borderRadius: slotRadius,
      );
    }

    // 2. Классическое акцентное фото с элегантным паспарту и полями
    if (layout == 'hero_centered') {
      final slot0 = slots.isNotEmpty ? slots[0] : _fallbackSlot(0);
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
          child: AspectRatio(
            aspectRatio: 1.0,
            child: Zone3SlotWidget(
              slot: slot0,
              onTap: () => onSlotTap(slot0),
              borderRadius: slotRadius,
            ),
          ),
        ),
      );
    }

    // 3. 2 вертикальных стройных портрета рядом (как на Развороте 2 на скриншоте)
    if (layout == 'split_vertical_2') {
      return Row(
        children: [
          Expanded(
            child: Zone3SlotWidget(
              slot: slots.isNotEmpty ? slots[0] : _fallbackSlot(0),
              onTap: () => onSlotTap(slots.isNotEmpty ? slots[0] : _fallbackSlot(0)),
              borderRadius: slotRadius,
            ),
          ),
          const SizedBox(width: 8.0),
          Expanded(
            child: Zone3SlotWidget(
              slot: slots.length > 1 ? slots[1] : _fallbackSlot(1),
              onTap: () => onSlotTap(slots.length > 1 ? slots[1] : _fallbackSlot(1)),
              borderRadius: slotRadius,
            ),
          ),
        ],
      );
    }

    // 4. 2 горизонтальных кадра (друг над другом)
    if (layout == 'split_horizontal_2' || (slots.length == 2 && layout != 'editorial_quote')) {
      return Column(
        children: [
          Expanded(
            child: Zone3SlotWidget(
              slot: slots.isNotEmpty ? slots[0] : _fallbackSlot(0),
              onTap: () => onSlotTap(slots.isNotEmpty ? slots[0] : _fallbackSlot(0)),
              borderRadius: slotRadius,
            ),
          ),
          const SizedBox(height: 8.0),
          Expanded(
            child: Zone3SlotWidget(
              slot: slots.length > 1 ? slots[1] : _fallbackSlot(1),
              onTap: () => onSlotTap(slots.length > 1 ? slots[1] : _fallbackSlot(1)),
              borderRadius: slotRadius,
            ),
          ),
        ],
      );
    }

    // 5. 3 вертикальных портрета рядом в ряд (полосами)
    if (layout == 'split_vertical_3') {
      return Row(
        children: [
          Expanded(
            child: Zone3SlotWidget(
              slot: slots.isNotEmpty ? slots[0] : _fallbackSlot(0),
              onTap: () => onSlotTap(slots.isNotEmpty ? slots[0] : _fallbackSlot(0)),
              borderRadius: slotRadius,
            ),
          ),
          const SizedBox(width: 6.0),
          Expanded(
            child: Zone3SlotWidget(
              slot: slots.length > 1 ? slots[1] : _fallbackSlot(1),
              onTap: () => onSlotTap(slots.length > 1 ? slots[1] : _fallbackSlot(1)),
              borderRadius: slotRadius,
            ),
          ),
          const SizedBox(width: 6.0),
          Expanded(
            child: Zone3SlotWidget(
              slot: slots.length > 2 ? slots[2] : _fallbackSlot(2),
              onTap: () => onSlotTap(slots.length > 2 ? slots[2] : _fallbackSlot(2)),
              borderRadius: slotRadius,
            ),
          ),
        ],
      );
    }

    // 6. Журнальный заголовок-типографика + фотоснимок (как "GO, BOYS!" на скриншоте)
    if (layout == 'editorial_quote') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0, top: 2.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  page.headline ?? style.defaultHeadline,
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.w900,
                    letterSpacing: style.headlineLetterSpacing,
                    color: style.headlineColor,
                  ),
                ),
                const SizedBox(height: 2.0),
                Text(
                  page.subhead ?? style.defaultSubhead,
                  style: TextStyle(
                    fontSize: 10.5,
                    fontStyle: FontStyle.italic,
                    color: style.headlineColor.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: slots.length > 1
                ? Row(
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
                  )
                : Zone3SlotWidget(
                    slot: slots.isNotEmpty ? slots[0] : _fallbackSlot(0),
                    onTap: () => onSlotTap(slots.isNotEmpty ? slots[0] : _fallbackSlot(0)),
                    borderRadius: slotRadius,
                  ),
          ),
        ],
      );
    }

    // 7. Шахматный журнальный коллаж с типографикой (как "LET'S GO" на скриншоте)
    if (layout == 'checkerboard_3') {
      return Column(
        children: [
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Center(
                    child: Text(
                      page.headline ?? "LET'S",
                      style: TextStyle(
                        fontSize: 22.0,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2.0,
                        color: style.headlineColor.withValues(alpha: 0.75),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 6.0),
                Expanded(
                  child: Zone3SlotWidget(
                    slot: slots.isNotEmpty ? slots[0] : _fallbackSlot(0),
                    onTap: () => onSlotTap(slots.isNotEmpty ? slots[0] : _fallbackSlot(0)),
                    borderRadius: slotRadius,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6.0),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Zone3SlotWidget(
                    slot: slots.length > 1 ? slots[1] : _fallbackSlot(1),
                    onTap: () => onSlotTap(slots.length > 1 ? slots[1] : _fallbackSlot(1)),
                    borderRadius: slotRadius,
                  ),
                ),
                const SizedBox(width: 6.0),
                Expanded(
                  child: Center(
                    child: Text(
                      page.subhead ?? "GO",
                      style: TextStyle(
                        fontSize: 22.0,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2.0,
                        color: style.headlineColor.withValues(alpha: 0.75),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (slots.length > 2) ...[
            const SizedBox(height: 6.0),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: Center(
                      child: Text(
                        '(лучшие моменты)',
                        style: TextStyle(
                          fontSize: 9.5,
                          fontStyle: FontStyle.italic,
                          color: style.headlineColor.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6.0),
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
        ],
      );
    }

    // 8. 1 широкое фото сверху + 3 вертикальных портрета внизу (в точности со скриншота 4)
    if (layout == 'hero_top_trio_4') {
      return Column(
        children: [
          Expanded(
            flex: 5,
            child: Zone3SlotWidget(
              slot: slots.isNotEmpty ? slots[0] : _fallbackSlot(0),
              onTap: () => onSlotTap(slots.isNotEmpty ? slots[0] : _fallbackSlot(0)),
              borderRadius: slotRadius,
            ),
          ),
          const SizedBox(height: 6.0),
          Expanded(
            flex: 4,
            child: Row(
              children: [
                Expanded(
                  child: Zone3SlotWidget(
                    slot: slots.length > 1 ? slots[1] : _fallbackSlot(1),
                    onTap: () => onSlotTap(slots.length > 1 ? slots[1] : _fallbackSlot(1)),
                    borderRadius: slotRadius,
                  ),
                ),
                const SizedBox(width: 6.0),
                Expanded(
                  child: Zone3SlotWidget(
                    slot: slots.length > 2 ? slots[2] : _fallbackSlot(2),
                    onTap: () => onSlotTap(slots.length > 2 ? slots[2] : _fallbackSlot(2)),
                    borderRadius: slotRadius,
                  ),
                ),
                const SizedBox(width: 6.0),
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

    // 9. 1 широкое фото сверху + 2 фото внизу
    if (layout == 'hero_top_split_bottom_3' || slots.length == 3) {
      return Column(
        children: [
          Expanded(
            flex: 5,
            child: Zone3SlotWidget(
              slot: slots.isNotEmpty ? slots[0] : _fallbackSlot(0),
              onTap: () => onSlotTap(slots.isNotEmpty ? slots[0] : _fallbackSlot(0)),
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
                    slot: slots.length > 1 ? slots[1] : _fallbackSlot(1),
                    onTap: () => onSlotTap(slots.length > 1 ? slots[1] : _fallbackSlot(1)),
                    borderRadius: slotRadius,
                  ),
                ),
                const SizedBox(width: 8.0),
                Expanded(
                  child: Zone3SlotWidget(
                    slot: slots.length > 2 ? slots[2] : _fallbackSlot(2),
                    onTap: () => onSlotTap(slots.length > 2 ? slots[2] : _fallbackSlot(2)),
                    borderRadius: slotRadius,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    // 10. Классическая сетка 2×2 (по умолчанию)
    return Column(
      children: [
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: Zone3SlotWidget(
                  slot: slots.isNotEmpty ? slots[0] : _fallbackSlot(0),
                  onTap: () => onSlotTap(slots.isNotEmpty ? slots[0] : _fallbackSlot(0)),
                  borderRadius: slotRadius,
                ),
              ),
              const SizedBox(width: 8.0),
              Expanded(
                child: Zone3SlotWidget(
                  slot: slots.length > 1 ? slots[1] : _fallbackSlot(1),
                  onTap: () => onSlotTap(slots.length > 1 ? slots[1] : _fallbackSlot(1)),
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
