import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../../core/theme/picpac_colors.dart';
import '../../../../../core/theme/picpac_typography.dart';
import '../../../../../core/widgets/picpac_image.dart';
import '../../../domain/mock_data.dart';
import '../../controllers/editor_controller.dart';

/// Шит голосования за обложку книги (SOLID: SRP)
class CoverVotingSheet extends StatefulWidget {
  final EditorState editorState;
  final ValueChanged<String> onVote;
  final ValueChanged<String>? onToast;

  const CoverVotingSheet({
    super.key,
    required this.editorState,
    required this.onVote,
    this.onToast,
  });

  static void show(
    BuildContext context, {
    required EditorState editorState,
    required ValueChanged<String> onVote,
    ValueChanged<String>? onToast,
  }) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: PicPacColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      builder: (_) => CoverVotingSheet(
        editorState: editorState,
        onVote: onVote,
        onToast: onToast,
      ),
    );
  }

  @override
  State<CoverVotingSheet> createState() => _CoverVotingSheetState();
}

class _CoverVotingSheetState extends State<CoverVotingSheet> {
  int _selectedCoverPhotoIndex = 0;

  @override
  Widget build(BuildContext context) {
    final pool = widget.editorState.poolPhotos;
    final photosList = pool.isNotEmpty ? pool : MockData.poolPhotos;
    final safeIndex = _selectedCoverPhotoIndex.clamp(0, photosList.length - 1);
    final activePhoto = photosList[safeIndex];
    final photoVotes = widget.editorState.coverVotes[activePhoto.id] ?? 0;
    final isLeader = widget.editorState.winningCoverPhoto?.id == activePhoto.id;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 36.0,
                height: 4.0,
                margin: const EdgeInsets.only(bottom: 16.0),
                decoration: BoxDecoration(
                  color: PicPacColors.borderDefault,
                  borderRadius: BorderRadius.circular(2.0),
                ),
              ),
            ),
            Row(
              children: [
                const Icon(LucideIcons.crown, size: 22.0, color: Color(0xFFF59E0B)),
                const SizedBox(width: 8.0),
                Expanded(
                  child: Text(
                    'Голосование за обложку',
                    style: PicPacTypography.h2Section,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6.0),
            Text(
              'Выберите фото, которое станет лицом альбома всего класса:',
              style: PicPacTypography.photoCaption.copyWith(
                color: PicPacColors.textMuted,
              ),
            ),
            const SizedBox(height: 16.0),
            Stack(
              children: [
                SizedBox(
                  height: 200.0,
                  width: double.infinity,
                  child: PicPacImage(
                    imageUrl: activePhoto.imageUrl,
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                if (isLeader)
                  Positioned(
                    top: 10.0,
                    left: 10.0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF59E0B),
                        borderRadius: BorderRadius.circular(8.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.18),
                            blurRadius: 4.0,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(LucideIcons.crown, size: 14.0, color: Colors.white),
                          const SizedBox(width: 4.0),
                          Text(
                            'Лидер голосования',
                            style: PicPacTypography.metaInfo.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                Positioned(
                  bottom: 10.0,
                  right: 10.0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(LucideIcons.heart, size: 13.0, color: PicPacColors.primaryCoral),
                        const SizedBox(width: 4.0),
                        Text(
                          '$photoVotes голосов',
                          style: PicPacTypography.metaInfo.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12.0),
            SizedBox(
              height: 60.0,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: photosList.length,
                separatorBuilder: (context, index) => const SizedBox(width: 8.0),
                itemBuilder: (ctx, idx) {
                  final p = photosList[idx];
                  final isCurrent = idx == safeIndex;
                  final vCount = widget.editorState.coverVotes[p.id] ?? 0;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedCoverPhotoIndex = idx;
                      });
                    },
                    child: Container(
                      width: 60.0,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.0),
                        border: Border.all(
                          color: isCurrent ? PicPacColors.primaryCoral : PicPacColors.borderDefault,
                          width: isCurrent ? 2.5 : 1.0,
                        ),
                      ),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6.0),
                            child: PicPacImage(imageUrl: p.imageUrl),
                          ),
                          if (vCount > 0)
                            Positioned(
                              top: 2.0,
                              right: 2.0,
                              child: Container(
                                padding: const EdgeInsets.all(2.0),
                                decoration: const BoxDecoration(
                                  color: Colors.black54,
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  '$vCount',
                                  style: const TextStyle(color: Colors.white, fontSize: 8.0),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: PicPacColors.primaryCoral,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
                widget.onVote(activePhoto.id);
                widget.onToast?.call('Ваш голос за обложку альбома сохранен!');
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(LucideIcons.heart, size: 16.0, color: Colors.white),
                  const SizedBox(width: 8.0),
                  Text(
                    'Голосовать за этот вариант',
                    style: PicPacTypography.buttonText,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
