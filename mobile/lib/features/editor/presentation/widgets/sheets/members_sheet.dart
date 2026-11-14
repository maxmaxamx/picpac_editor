import 'package:flutter/material.dart';
import '../../../../../core/theme/picpac_colors.dart';
import '../../../../../core/theme/picpac_typography.dart';
import '../../../domain/models.dart';

/// Шит просмотра участников альбома (SOLID: SRP)
class MembersSheet extends StatelessWidget {
  final List<MemberModel> members;
  final String inviteCode;

  const MembersSheet({
    super.key,
    required this.members,
    required this.inviteCode,
  });

  static void show(
    BuildContext context, {
    required List<MemberModel> members,
    required String inviteCode,
  }) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: PicPacColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      builder: (_) => MembersSheet(
        members: members,
        inviteCode: inviteCode,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Участники альбома (${members.length})',
                  style: PicPacTypography.h2Section,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                  decoration: BoxDecoration(
                    color: PicPacColors.surfaceGrey,
                    borderRadius: BorderRadius.circular(6.0),
                  ),
                  child: Text(
                    'Код: ${inviteCode.isNotEmpty ? inviteCode : "849204"}',
                    style: PicPacTypography.metaInfo.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            ...members.map((member) {
              return Container(
                margin: const EdgeInsets.only(bottom: 8.0),
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                decoration: BoxDecoration(
                  color: PicPacColors.surfaceGrey,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Row(
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 18.0,
                          backgroundImage: NetworkImage(member.avatarUrl),
                        ),
                        if (member.isOnline)
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Container(
                              width: 10.0,
                              height: 10.0,
                              decoration: BoxDecoration(
                                color: const Color(0xFF22C55E),
                                shape: BoxShape.circle,
                                border: Border.all(color: PicPacColors.white, width: 1.5),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(width: 12.0),
                    Expanded(
                      child: Text(
                        member.name,
                        style: PicPacTypography.buttonTextDark,
                      ),
                    ),
                    Text(
                      member.isOnline ? 'в сети' : 'был(а) недавно',
                      style: PicPacTypography.metaInfo.copyWith(
                        color: member.isOnline ? const Color(0xFF22C55E) : PicPacColors.textMuted,
                        fontWeight: member.isOnline ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

