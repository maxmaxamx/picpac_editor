import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/picpac_colors.dart';
import '../../../../core/theme/picpac_typography.dart';
import '../../domain/pickup_point.dart';

class OrderSuccessDialog extends StatelessWidget {
  final String orderNumber;
  final PickupPoint? pickupPoint;
  final VoidCallback onReturnToEditor;

  const OrderSuccessDialog({
    super.key,
    required this.orderNumber,
    required this.pickupPoint,
    required this.onReturnToEditor,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: PicPacColors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      contentPadding: const EdgeInsets.all(24.0),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60.0,
            height: 60.0,
            decoration: const BoxDecoration(
              color: Color(0xFFDCFCE7),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              LucideIcons.check,
              size: 32.0,
              color: Color(0xFF16A34A),
            ),
          ),
          const SizedBox(height: 16.0),
          Text(
            'Заказ оформлен!',
            style: PicPacTypography.h1Title.copyWith(fontSize: 20.0),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8.0),
          Text(
            'Заказ №$orderNumber успешно принят в типографию picPac.by',
            style: PicPacTypography.photoCaption,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16.0),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: PicPacColors.surfaceGrey,
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(color: PicPacColors.borderDefault),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Пункт выдачи:',
                  style: PicPacTypography.metaInfo.copyWith(fontWeight: FontWeight.w600),
                ),
                Text(
                  pickupPoint?.name ?? '',
                  style: PicPacTypography.photoCaption.copyWith(fontWeight: FontWeight.w700),
                ),
                Text(
                  pickupPoint?.address ?? '',
                  style: PicPacTypography.metaInfo,
                ),
                const SizedBox(height: 6.0),
                Text(
                  'Ориентировочная готовность: через 2 дня',
                  style: PicPacTypography.metaInfo.copyWith(
                    color: PicPacColors.primaryCoral,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20.0),
          GestureDetector(
            onTap: onReturnToEditor,
            behavior: HitTestBehavior.opaque,
            child: Container(
              height: 46.0,
              width: double.infinity,
              decoration: BoxDecoration(
                color: PicPacColors.primaryCoral,
                borderRadius: BorderRadius.circular(8.0),
              ),
              alignment: Alignment.center,
              child: Text(
                'Вернуться в редактор',
                style: PicPacTypography.buttonText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
