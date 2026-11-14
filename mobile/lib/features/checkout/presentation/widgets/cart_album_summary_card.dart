import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/picpac_colors.dart';
import '../../../../core/theme/picpac_typography.dart';

class CartAlbumSummaryCard extends StatelessWidget {
  final String albumTitle;
  final double itemsCost;
  final int spreadsCount;
  final String format;

  const CartAlbumSummaryCard({
    super.key,
    required this.albumTitle,
    required this.itemsCost,
    required this.spreadsCount,
    required this.format,
  });

  @override
  Widget build(BuildContext context) {
    final formattedCost = '${itemsCost.toStringAsFixed(2).replaceAll('.', ',')} руб.';

    return Container(
      padding: const EdgeInsets.all(14.0),
      decoration: BoxDecoration(
        color: PicPacColors.white,
        borderRadius: BorderRadius.circular(12.0),
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
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 54.0,
                height: 54.0,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFFAF8), Color(0xFFFEECE6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10.0),
                  border: Border.all(color: PicPacColors.primaryCoral.withValues(alpha: 0.3)),
                ),
                child: const Center(
                  child: Icon(
                    LucideIcons.bookOpen,
                    color: PicPacColors.primaryCoral,
                    size: 26.0,
                  ),
                ),
              ),
              const SizedBox(width: 12.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(6.0),
                      ),
                      child: const Text(
                        'В корзине • 1 шт.',
                        style: TextStyle(
                          color: Color(0xFF2E7D32),
                          fontSize: 11.0,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6.0),
                    Text(
                      albumTitle,
                      style: const TextStyle(
                        fontSize: 15.0,
                        fontWeight: FontWeight.w700,
                        color: PicPacColors.textDark,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3.0),
                    Text(
                      'Фотокнига Classic • $format • $spreadsCount разворотов',
                      style: PicPacTypography.metaInfo.copyWith(
                        color: PicPacColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      '$formattedCost / экз.',
                      style: const TextStyle(
                        fontSize: 15.0,
                        fontWeight: FontWeight.w800,
                        color: PicPacColors.primaryCoral,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10.0),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 7.0),
            decoration: BoxDecoration(
              color: PicPacColors.surfaceGrey,
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Row(
              children: [
                const Icon(
                  LucideIcons.sparkles,
                  size: 14.0,
                  color: PicPacColors.primaryCoral,
                ),
                const SizedBox(width: 8.0),
                Expanded(
                  child: Text(
                    'Твердая обложка, шелковистая бумага, макет готов к печати',
                    style: PicPacTypography.metaInfo.copyWith(
                      fontSize: 11.5,
                      color: PicPacColors.textMuted,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

