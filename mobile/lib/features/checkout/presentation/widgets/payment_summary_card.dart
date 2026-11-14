import 'package:flutter/material.dart';
import '../../../../core/theme/picpac_colors.dart';
import '../../../../core/theme/picpac_typography.dart';

class PaymentSummaryCard extends StatelessWidget {
  final double itemsCost;
  final double discount;
  final VoidCallback onSubmitOrder;

  const PaymentSummaryCard({
    super.key,
    required this.itemsCost,
    required this.discount,
    required this.onSubmitOrder,
  });

  double get _totalCost {
    final total = itemsCost - discount;
    return total > 0 ? total : 0.0;
  }

  @override
  Widget build(BuildContext context) {
    final formattedItemsCost = '${itemsCost.toStringAsFixed(2).replaceAll('.', ',')} руб.';
    final formattedDiscount = '-${discount.toStringAsFixed(2).replaceAll('.', ',')} руб.';
    final formattedTotal = '${_totalCost.toStringAsFixed(2).replaceAll('.', ',')} руб.';

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: PicPacColors.white,
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(color: PicPacColors.borderDefault),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 8.0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Информация об оплате',
            style: PicPacTypography.photoCaption.copyWith(
              color: PicPacColors.textMuted,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 14.0),

          // Стоимость позиций
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Стоимость позиций:',
                  style: PicPacTypography.photoCaption.copyWith(fontSize: 14.0),
                ),
              ),
              const SizedBox(width: 8.0),
              Text(
                formattedItemsCost,
                style: PicPacTypography.photoCaption.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 14.0,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8.0),

          // Доставка
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Доставка:',
                  style: PicPacTypography.photoCaption.copyWith(fontSize: 14.0),
                ),
              ),
              const SizedBox(width: 8.0),
              Text(
                'Бесплатно',
                style: PicPacTypography.photoCaption.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 14.0,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8.0),

          // Скидка
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Скидка:',
                  style: PicPacTypography.photoCaption.copyWith(fontSize: 14.0),
                ),
              ),
              const SizedBox(width: 8.0),
              Text(
                formattedDiscount,
                style: const TextStyle(
                  color: PicPacColors.primaryCoral,
                  fontWeight: FontWeight.w600,
                  fontSize: 14.0,
                ),
              ),
            ],
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12.0),
            child: Divider(color: PicPacColors.borderDefault, height: 1.0),
          ),

          // Итого к оплате
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Итого к оплате:',
                  style: PicPacTypography.h2Section.copyWith(fontSize: 17.0),
                ),
              ),
              const SizedBox(width: 8.0),
              Text(
                formattedTotal,
                style: const TextStyle(
                  color: PicPacColors.textDark,
                  fontSize: 19.0,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16.0),

          // Кнопка «Подтвердить и заказать»
          GestureDetector(
            onTap: onSubmitOrder,
            behavior: HitTestBehavior.opaque,
            child: Container(
              height: 48.0,
              decoration: BoxDecoration(
                color: PicPacColors.primaryCoral,
                borderRadius: BorderRadius.circular(8.0),
              ),
              alignment: Alignment.center,
              child: const Text(
                'Подтвердить и заказать',
                style: TextStyle(
                  color: PicPacColors.white,
                  fontSize: 15.0,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

