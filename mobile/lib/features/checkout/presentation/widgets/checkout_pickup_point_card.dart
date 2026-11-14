import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/picpac_colors.dart';
import '../../../../core/theme/picpac_typography.dart';
import '../../domain/pickup_point.dart';

class CheckoutPickupPointCard extends StatelessWidget {
  final PickupPoint? selectedPickupPoint;
  final VoidCallback onSelectOrChange;

  const CheckoutPickupPointCard({
    super.key,
    required this.selectedPickupPoint,
    required this.onSelectOrChange,
  });

  @override
  Widget build(BuildContext context) {
    if (selectedPickupPoint == null) {
      return GestureDetector(
        onTap: onSelectOrChange,
        behavior: HitTestBehavior.opaque,
        child: Container(
          height: 48.0,
          decoration: BoxDecoration(
            color: PicPacColors.white,
            borderRadius: BorderRadius.circular(8.0),
            border: Border.all(color: PicPacColors.primaryCoral, width: 1.2),
          ),
          alignment: Alignment.center,
          child: const Text(
            'Выберите пункт выдачи',
            style: TextStyle(
              color: PicPacColors.primaryCoral,
              fontSize: 15.0,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }

    final point = selectedPickupPoint!;

    return Container(
      padding: const EdgeInsets.all(14.0),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6.0),
                decoration: BoxDecoration(
                  color: PicPacColors.primaryCoralSoft,
                  borderRadius: BorderRadius.circular(6.0),
                ),
                child: const Icon(
                  LucideIcons.mapPin,
                  size: 16.0,
                  color: PicPacColors.primaryCoral,
                ),
              ),
              const SizedBox(width: 8.0),
              Expanded(
                child: Text(
                  point.name,
                  style: PicPacTypography.buttonTextDark.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 14.5,
                  ),
                ),
              ),
              GestureDetector(
                onTap: onSelectOrChange,
                behavior: HitTestBehavior.opaque,
                child: Text(
                  'Изменить',
                  style: PicPacTypography.buttonText.copyWith(
                    color: PicPacColors.primaryCoral,
                    fontSize: 13.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6.0),
          Padding(
            padding: const EdgeInsets.only(left: 30.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  point.address,
                  style: PicPacTypography.photoCaption.copyWith(fontSize: 12.5),
                ),
                const SizedBox(height: 2.0),
                Text(
                  point.workingHours,
                  style: PicPacTypography.metaInfo,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
