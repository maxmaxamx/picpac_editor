import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../theme/picpac_colors.dart';
import '../theme/picpac_typography.dart';
import '../session/session_state.dart';
import '../../features/checkout/presentation/screens/checkout_screen.dart';
import '../../features/onboarding/presentation/screens/album_templates_screen.dart';

// 1. Иконка Корзины (Shopping Bag)
const String kNavCartSvg = '''
<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
  <path d="M6 2 3 6v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2V6l-3-4Z"/>
  <path d="M3 6h18"/>
  <path d="M16 10a4 4 0 0 1-8 0"/>
</svg>
''';

// 2. Иконка Знака плюса (Plus / Add)
const String kNavPlusSvg = '''
<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.6" stroke-linecap="round" stroke-linejoin="round">
  <line x1="12" y1="5" x2="12" y2="19"/>
  <line x1="5" y1="12" x2="19" y2="12"/>
</svg>
''';

// 3. Иконка Профиля (User Account)
const String kNavProfileSvg = '''
<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
  <path d="M19 21v-2a4 4 0 0 0-4-4H9a4 4 0 0 0-4 4v2"/>
  <circle cx="12" cy="7" r="4"/>
</svg>
''';

class PicPacBottomNavBar extends ConsumerWidget {
  final int currentIndex;
  final ValueChanged<int>? onTap;
  final VoidCallback? onCartTap;
  final VoidCallback? onPlusTap;
  final VoidCallback? onProfileTap;

  const PicPacBottomNavBar({
    super.key,
    this.currentIndex = 1,
    this.onTap,
    this.onCartTap,
    this.onPlusTap,
    this.onProfileTap,
  });

  void _handleCart(BuildContext context, WidgetRef ref) {
    if (onCartTap != null) {
      onCartTap!();
      return;
    }
    _showCartSheet(context, ref);
  }

  void _handlePlus(BuildContext context, WidgetRef ref) {
    if (onPlusTap != null) {
      onPlusTap!();
      return;
    }
    final session = ref.read(sessionProvider);
    final userName = session.user?.displayName.isNotEmpty == true ? session.user!.displayName : 'Участник';
    Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (_) => AlbumTemplatesScreen(
          albumTitle: 'Выпускной 11-Б • 2026',
          userName: userName,
        ),
      ),
    );
  }

  void _handleProfile(BuildContext context, WidgetRef ref) {
    if (onProfileTap != null) {
      onProfileTap!();
      return;
    }
    _showProfileSheet(context, ref);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        color: PicPacColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12.0,
            offset: const Offset(0, -3),
          ),
        ],
        border: const Border(
          top: BorderSide(
            color: PicPacColors.borderDefault,
            width: 0.8,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 60.0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // 1. Корзина
              Expanded(
                child: _buildNavItem(
                  context: context,
                  index: 0,
                  svgRaw: kNavCartSvg,
                  label: 'Корзина',
                  isSelected: currentIndex == 0,
                  onTap: () {
                    onTap?.call(0);
                    _handleCart(context, ref);
                  },
                ),
              ),

              // 2. Знак плюса (Центральная кнопка создания)
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    onTap?.call(1);
                    _handlePlus(context, ref);
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Center(
                    child: Container(
                      width: 44.0,
                      height: 44.0,
                      decoration: BoxDecoration(
                        color: PicPacColors.primaryCoral,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: PicPacColors.primaryCoral.withValues(alpha: 0.35),
                            blurRadius: 8.0,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(10.0),
                      child: SvgPicture.string(
                        kNavPlusSvg,
                        colorFilter: const ColorFilter.mode(
                          PicPacColors.white,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // 3. Профиль
              Expanded(
                child: _buildNavItem(
                  context: context,
                  index: 2,
                  svgRaw: kNavProfileSvg,
                  label: 'Профиль',
                  isSelected: currentIndex == 2,
                  onTap: () {
                    onTap?.call(2);
                    _handleProfile(context, ref);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required int index,
    required String svgRaw,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final color = isSelected ? PicPacColors.primaryCoral : PicPacColors.textMuted;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 24.0,
            height: 24.0,
            child: SvgPicture.string(
              svgRaw,
              colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
            ),
          ),
          const SizedBox(height: 3.0),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.0,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  void _showCartSheet(BuildContext context, WidgetRef ref) {
    final session = ref.read(sessionProvider);
    final album = session.currentAlbum;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: PicPacColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20.0, 16.0, 20.0, 20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 36.0,
                    height: 4.0,
                    decoration: BoxDecoration(
                      color: PicPacColors.borderDefault,
                      borderRadius: BorderRadius.circular(2.0),
                    ),
                  ),
                ),
                const SizedBox(height: 16.0),
                Row(
                  children: [
                    SizedBox(
                      width: 22.0,
                      height: 22.0,
                      child: SvgPicture.string(
                        kNavCartSvg,
                        colorFilter: const ColorFilter.mode(
                          PicPacColors.primaryCoral,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10.0),
                    Text('Корзина заказов', style: PicPacTypography.h2Section),
                  ],
                ),
                const SizedBox(height: 16.0),
                if (album != null) ...[
                  Container(
                    padding: const EdgeInsets.all(14.0),
                    decoration: BoxDecoration(
                      color: PicPacColors.surfaceGrey,
                      borderRadius: BorderRadius.circular(10.0),
                      border: Border.all(color: PicPacColors.borderDefault),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 44.0,
                          height: 44.0,
                          decoration: BoxDecoration(
                            color: PicPacColors.white,
                            borderRadius: BorderRadius.circular(8.0),
                            border: Border.all(color: PicPacColors.borderDefault),
                          ),
                          child: const Icon(
                            LucideIcons.bookOpen,
                            color: PicPacColors.primaryCoral,
                            size: 22.0,
                          ),
                        ),
                        const SizedBox(width: 12.0),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                album.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14.5,
                                  color: PicPacColors.textDark,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2.0),
                              Text(
                                '${album.spreadsCount} разворотов • ${album.format}',
                                style: PicPacTypography.photoCaption,
                              ),
                            ],
                          ),
                        ),
                        const Text(
                          '72,90 BYN',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 14.0,
                            color: PicPacColors.primaryCoral,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: PicPacColors.primaryCoral,
                      foregroundColor: PicPacColors.white,
                      minimumSize: const Size.fromHeight(48.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(sheetContext);
                      Navigator.push<void>(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CheckoutScreen(
                            albumTitle: album.name,
                            userName: session.user?.displayName ?? 'Участник',
                          ),
                        ),
                      );
                    },
                    child: const Text(
                      'Перейти к оформлению',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15.0),
                    ),
                  ),
                ] else ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24.0),
                    child: Column(
                      children: [
                        const Icon(LucideIcons.shoppingBag, size: 40.0, color: PicPacColors.textMuted),
                        const SizedBox(height: 10.0),
                        Text(
                          'Корзина пока пуста',
                          style: PicPacTypography.h2Section.copyWith(fontSize: 16.0),
                        ),
                        const SizedBox(height: 4.0),
                        Text(
                          'Создайте альбом или подключитесь по коду, чтобы заполнить фотокнигу',
                          textAlign: TextAlign.center,
                          style: PicPacTypography.photoCaption,
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  void _showProfileSheet(BuildContext context, WidgetRef ref) {
    final session = ref.read(sessionProvider);
    final user = session.user;
    final userName = user?.displayName.isNotEmpty == true ? user!.displayName : 'Гость';

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: PicPacColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20.0, 16.0, 20.0, 20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 36.0,
                    height: 4.0,
                    decoration: BoxDecoration(
                      color: PicPacColors.borderDefault,
                      borderRadius: BorderRadius.circular(2.0),
                    ),
                  ),
                ),
                const SizedBox(height: 16.0),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 26.0,
                      backgroundColor: PicPacColors.primaryCoral.withValues(alpha: 0.15),
                      child: Text(
                        userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                        style: const TextStyle(
                          fontSize: 22.0,
                          fontWeight: FontWeight.w800,
                          color: PicPacColors.primaryCoral,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14.0),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userName,
                            style: const TextStyle(
                              fontSize: 17.0,
                              fontWeight: FontWeight.w800,
                              color: PicPacColors.textDark,
                            ),
                          ),
                          const SizedBox(height: 2.0),
                          const Text(
                            'Участник picPac.by',
                            style: TextStyle(
                              fontSize: 12.0,
                              color: PicPacColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20.0),
                Container(
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: PicPacColors.surfaceGrey,
                    borderRadius: BorderRadius.circular(10.0),
                    border: Border.all(color: PicPacColors.borderDefault),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Платформа', style: TextStyle(fontSize: 13.0, color: PicPacColors.textMuted)),
                          Text('picPac Mobile 2026', style: PicPacTypography.metaInfo.copyWith(fontWeight: FontWeight.w600)),
                        ],
                      ),
                      const Divider(height: 16.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Статус аккаунта', style: TextStyle(fontSize: 13.0, color: PicPacColors.textMuted)),
                          const Text('Активен (Гость/Участник)', style: TextStyle(fontSize: 12.0, color: Color(0xFF16A34A), fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16.0),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: PicPacColors.textDark,
                    minimumSize: const Size.fromHeight(44.0),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                  ),
                  onPressed: () => Navigator.pop(sheetContext),
                  child: const Text('Закрыть'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
