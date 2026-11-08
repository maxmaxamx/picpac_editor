import 'package:flutter/material.dart';
import '../../../../core/theme/picpac_colors.dart';
import '../../../../core/widgets/dashed_border_box.dart';
import '../../domain/models.dart';
import 'zone3_floating_pill.dart';
import 'zone3_slot_widget.dart';

class Zone3SpreadCanvas extends StatelessWidget {
  final PageModel page;
  final int totalPages;
  final ValueChanged<int> onPageChange;
  final ValueChanged<SlotModel> onSlotTap;

  const Zone3SpreadCanvas({
    super.key,
    required this.page,
    required this.totalPages,
    required this.onPageChange,
    required this.onSlotTap,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Доступное пространство
        // Вычитаем 36px (пилл) + 10px (отступ между листом и пиллом) + 12px * 2 (отступы сверху/снизу)
        const double pillHeight = 36.0;
        const double pillMarginTop = 10.0;
        const double verticalPadding = 12.0;

        final double maxAvailableHeight = constraints.maxHeight -
            pillHeight -
            pillMarginTop -
            verticalPadding * 2;
        final double maxAvailableWidth = constraints.maxWidth - 32.0; // отступы по бокам 16px

        // Пропорции листа 3:4
        const double aspectRatio = 3.0 / 4.0;
        double sheetWidth = maxAvailableWidth;
        double sheetHeight = sheetWidth / aspectRatio;

        if (sheetHeight > maxAvailableHeight) {
          sheetHeight = maxAvailableHeight;
          sheetWidth = sheetHeight * aspectRatio;
        }

        return Container(
          width: double.infinity,
          height: constraints.maxHeight,
          color: PicPacColors.surfaceGrey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Белый лист фотокниги с поддержкой горизонтального свайпа
              GestureDetector(
                onHorizontalDragEnd: (details) {
                  if (details.primaryVelocity != null) {
                    if (details.primaryVelocity! < -200 &&
                        page.pageNumber < totalPages) {
                      // Свайп влево -> следующая страница
                      onPageChange(page.pageNumber + 1);
                    } else if (details.primaryVelocity! > 200 &&
                        page.pageNumber > 1) {
                      // Свайп вправо -> предыдущая страница
                      onPageChange(page.pageNumber - 1);
                    }
                  }
                },
                child: Container(
                  width: sheetWidth,
                  height: sheetHeight,
                  decoration: BoxDecoration(
                    color: PicPacColors.white,
                    borderRadius: BorderRadius.circular(4.0),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x12000000), // 7% черного по спецификации
                        blurRadius: 24.0,
                        spreadRadius: 0.0,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // Полиграфическая линия безопасности (Print Safe Zone):
                      // Внутри белого листа на расстоянии 6px от края, 1px dashed #FF4D4D с opacity: 0.35
                      Positioned(
                        left: 6.0,
                        top: 6.0,
                        right: 6.0,
                        bottom: 6.0,
                        child: IgnorePointer(
                          child: DashedBorderBox(
                            color: PicPacColors.primaryCoral.withValues(alpha: 0.35),
                            strokeWidth: 1.0,
                            dashLength: 4.0,
                            dashGap: 4.0,
                            borderRadius: 2.0,
                          ),
                        ),
                      ),

                      // Сетка слотов 2×2 с внутренним отступом 14px и зазором 10px
                      Padding(
                        padding: const EdgeInsets.all(14.0),
                        child: _buildSlotsGrid(),
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

  Widget _buildSlotsGrid() {
    final slots = page.slots;

    return Column(
      children: [
        // Верхний ряд: Слот 0 и Слот 1
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: Zone3SlotWidget(
                  slot: slots.isNotEmpty ? slots[0] : _fallbackSlot(0),
                  onTap: () => onSlotTap(
                      slots.isNotEmpty ? slots[0] : _fallbackSlot(0)),
                ),
              ),
              const SizedBox(width: 10.0),
              Expanded(
                child: Zone3SlotWidget(
                  slot: slots.length > 1 ? slots[1] : _fallbackSlot(1),
                  onTap: () => onSlotTap(
                      slots.length > 1 ? slots[1] : _fallbackSlot(1)),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 10.0),

        // Нижний ряд: Слот 2 и Слот 3
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: Zone3SlotWidget(
                  slot: slots.length > 2 ? slots[2] : _fallbackSlot(2),
                  onTap: () => onSlotTap(
                      slots.length > 2 ? slots[2] : _fallbackSlot(2)),
                ),
              ),
              const SizedBox(width: 10.0),
              Expanded(
                child: Zone3SlotWidget(
                  slot: slots.length > 3 ? slots[3] : _fallbackSlot(3),
                  onTap: () => onSlotTap(
                      slots.length > 3 ? slots[3] : _fallbackSlot(3)),
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
      id: 'fallback_$index',
      slotIndex: index,
      status: SlotStatus.empty,
    );
  }
}
