import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/picpac_colors.dart';
import '../../../../core/theme/picpac_typography.dart';
import '../../domain/models.dart';

class Zone1TopBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<MemberModel> members;
  final VoidCallback? onBackTap;
  final VoidCallback? onShareTap;
  final VoidCallback? onMembersTap;

  const Zone1TopBar({
    super.key,
    required this.title,
    required this.members,
    this.onBackTap,
    this.onShareTap,
    this.onMembersTap,
  });

  @override
  Size get preferredSize => const Size.fromHeight(52.0);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52.0,
      decoration: const BoxDecoration(
        color: PicPacColors.white,
        border: Border(
          bottom: BorderSide(
            color: PicPacColors.borderDefault,
            width: 1.0,
          ),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Row(
        children: [
          // Кнопка назад
          GestureDetector(
            onTap: onBackTap,
            behavior: HitTestBehavior.opaque,
            child: const Padding(
              padding: EdgeInsets.only(right: 8.0),
              child: Icon(
                LucideIcons.chevronLeft,
                size: 22.0,
                color: PicPacColors.textDark,
              ),
            ),
          ),

          // Название альбома
          Expanded(
            child: Text(
              title,
              style: PicPacTypography.h1Title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          const SizedBox(width: 8.0),

          // Стек аватаров онлайн (до 4 кружков диаметром 28px с нахлестом -8px)
          GestureDetector(
            onTap: onMembersTap,
            behavior: HitTestBehavior.opaque,
            child: _buildAvatarStack(members),
          ),

          const SizedBox(width: 8.0),

          // Компактная кнопка шеринга/приглашения
          GestureDetector(
            onTap: onShareTap,
            behavior: HitTestBehavior.opaque,
            child: Container(
              width: 32.0,
              height: 32.0,
              decoration: BoxDecoration(
                color: PicPacColors.surfaceGrey,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: const Icon(
                LucideIcons.share2,
                size: 16.0,
                color: PicPacColors.textDark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarStack(List<MemberModel> membersList) {
    final displayMembers = membersList.take(4).toList();
    if (displayMembers.isEmpty) return const SizedBox.shrink();

    // Расчет ширины для нахлеста: диаметр 28px, нахлест -8px (сдвиг 20px на аватар)
    final double stackWidth = 28.0 + (displayMembers.length - 1) * 20.0;

    return SizedBox(
      width: stackWidth,
      height: 28.0,
      child: Stack(
        children: [
          for (int i = 0; i < displayMembers.length; i++)
            Positioned(
              left: i * 20.0,
              child: Stack(
                children: [
                  Container(
                    width: 28.0,
                    height: 28.0,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: PicPacColors.white,
                        width: 2.0,
                      ),
                    ),
                    child: ClipOval(
                      child: CachedNetworkImage(
                        imageUrl: displayMembers[i].avatarUrl,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: PicPacColors.surfaceGrey,
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: PicPacColors.surfaceGrey,
                          child: const Icon(
                            LucideIcons.user,
                            size: 14.0,
                            color: PicPacColors.textMuted,
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (displayMembers[i].isOnline)
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 8.0,
                        height: 8.0,
                        decoration: BoxDecoration(
                          color: PicPacColors.onlineGreen,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: PicPacColors.white,
                            width: 1.5,
                          ),
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

