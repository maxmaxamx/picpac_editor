import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../../core/theme/picpac_colors.dart';
import '../../../../../core/theme/picpac_typography.dart';

/// Диалог «Поделиться альбомом / Пригласить участников» (SOLID: SRP)
class ShareAlbumDialog extends StatelessWidget {
  final String inviteCode;
  final ValueChanged<String>? onToast;

  const ShareAlbumDialog({
    super.key,
    required this.inviteCode,
    this.onToast,
  });

  static Future<void> show(
    BuildContext context, {
    required String inviteCode,
    ValueChanged<String>? onToast,
  }) {
    return showDialog<void>(
      context: context,
      builder: (dialogContext) => ShareAlbumDialog(
        inviteCode: inviteCode,
        onToast: onToast,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final rawCode = inviteCode.isNotEmpty ? inviteCode : '849204';
    final displayCode = rawCode.length == 6
        ? '${rawCode.substring(0, 3)} - ${rawCode.substring(3)}'
        : rawCode;
    final shareUrl = 'picpac://join?code=$rawCode';

    return AlertDialog(
      backgroundColor: PicPacColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: PicPacColors.primaryCoral.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: const Icon(
              LucideIcons.share2,
              size: 20.0,
              color: PicPacColors.primaryCoral,
            ),
          ),
          const SizedBox(width: 12.0),
          Expanded(
            child: Text(
              'Пригласить в альбом',
              style: PicPacTypography.h2Section.copyWith(fontSize: 18.0),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Поделитесь ссылкой или кодом с участниками для совместного заполнения альбома:',
            style: PicPacTypography.photoCaption.copyWith(fontSize: 13.0),
          ),
          const SizedBox(height: 16.0),
          Text(
            'Ссылка на приложение (Live-режим):',
            style: PicPacTypography.buttonTextDark.copyWith(
              fontSize: 12.0,
              color: PicPacColors.textMuted,
            ),
          ),
          const SizedBox(height: 6.0),
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(10.0),
              onTap: () async {
                Clipboard.setData(ClipboardData(text: shareUrl));
                onToast?.call('Ссылка скопирована!');
                final uri = Uri.parse(shareUrl);
                try {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                } catch (_) {}
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
                decoration: BoxDecoration(
                  color: PicPacColors.surfaceGrey,
                  borderRadius: BorderRadius.circular(10.0),
                  border: Border.all(color: PicPacColors.borderDefault),
                ),
                child: Row(
                  children: [
                    const Icon(LucideIcons.link, size: 16.0, color: PicPacColors.primaryCoral),
                    const SizedBox(width: 8.0),
                    Expanded(
                      child: Text(
                        shareUrl,
                        style: const TextStyle(
                          fontSize: 13.0,
                          fontWeight: FontWeight.w600,
                          color: PicPacColors.primaryCoral,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Icon(LucideIcons.copy, size: 16.0, color: PicPacColors.textMuted),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 14.0),
          Text(
            'Код альбома:',
            style: PicPacTypography.buttonTextDark.copyWith(
              fontSize: 12.0,
              color: PicPacColors.textMuted,
            ),
          ),
          const SizedBox(height: 6.0),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            decoration: BoxDecoration(
              color: PicPacColors.surfaceGrey,
              borderRadius: BorderRadius.circular(10.0),
              border: Border.all(color: PicPacColors.borderDefault),
            ),
            child: Center(
              child: Text(
                displayCode,
                style: const TextStyle(
                  fontSize: 26.0,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 4.0,
                  color: PicPacColors.textDark,
                ),
              ),
            ),
          ),
        ],
      ),
      actionsPadding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
      actions: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: PicPacColors.primaryCoral,
                foregroundColor: PicPacColors.white,
                elevation: 0,
                minimumSize: const Size.fromHeight(48.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              icon: const Icon(LucideIcons.share2, size: 18.0),
              label: const Text(
                'Поделиться ссылкой',
                style: TextStyle(
                  fontSize: 15.0,
                  fontWeight: FontWeight.w700,
                ),
              ),
              onPressed: () async {
                Clipboard.setData(ClipboardData(text: shareUrl));
                final box = context.findRenderObject() as RenderBox?;
                final origin = box != null
                    ? box.localToGlobal(Offset.zero) & box.size
                    : const Rect.fromLTWH(0, 0, 100, 100);

                await SharePlus.instance.share(
                  ShareParams(
                    text: 'Присоединяйся к созданию фотоальбома в PicPac!\n\nСсылка для входа: $shareUrl\nКод альбома: $rawCode',
                    subject: 'Приглашение в фотоальбом PicPac',
                    sharePositionOrigin: origin,
                  ),
                );
              },
            ),
            const SizedBox(height: 10.0),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: PicPacColors.textDark,
                minimumSize: const Size.fromHeight(44.0),
                side: const BorderSide(color: PicPacColors.borderDefault, width: 1.2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Выход',
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
