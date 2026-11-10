import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/session/session_state.dart';
import '../../../../core/theme/picpac_colors.dart';
import '../../../../core/theme/picpac_typography.dart';
import '../../../../core/widgets/picpac_image.dart';
import '../../../checkout/presentation/screens/checkout_screen.dart';
import '../../domain/mock_data.dart';
import '../../domain/models.dart';
import '../controllers/editor_controller.dart';
import '../widgets/zone1_top_bar.dart';
import '../widgets/zone2_page_minimap.dart';
import '../widgets/zone3_spread_canvas.dart';
import '../widgets/zone4_media_pool.dart';
import '../widgets/zone5_bottom_dock.dart';

class SpreadEditorScreen extends ConsumerStatefulWidget {
  final String? albumId;
  final String albumTitle;
  final String userName;
  final double aspectRatio;
  final int spreadsCount;

  const SpreadEditorScreen({
    super.key,
    this.albumId,
    this.albumTitle = 'Выпускной 11-Б • 2026',
    this.userName = 'Артём',
    this.aspectRatio = 3.0 / 4.0,
    this.spreadsCount = 10,
  });

  @override
  ConsumerState<SpreadEditorScreen> createState() => _SpreadEditorScreenState();
}

class _SpreadEditorScreenState extends ConsumerState<SpreadEditorScreen> {
  int _selectedCoverPhotoIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.albumId != null && widget.albumId!.isNotEmpty) {
        final session = ref.read(sessionProvider);
        final user = session.user ??
            UserProfile(
              userId: 'user_${DateTime.now().millisecondsSinceEpoch}',
              displayName: widget.userName,
            );
        ref.read(editorControllerProvider.notifier).loadAlbum(
              albumId: widget.albumId!,
              user: user,
            );
      } else {
        ref.read(editorControllerProvider.notifier).initMock(
              albumTitle: widget.albumTitle,
              aspectRatio: widget.aspectRatio,
              spreadsCount: widget.spreadsCount,
            );
      }
    });
  }

  void _onPageSelected(int pageNumber) {
    ref.read(editorControllerProvider.notifier).selectPage(pageNumber);
  }

  void _onSlotTap(SlotModel slot) {
    if (slot.status == SlotStatus.locked) {
      _showToast(
        context,
        '${slot.lockedByName ?? "Участник"} сейчас выбирает фото для этого слота',
      );
      return;
    }

    if (slot.status == SlotStatus.filled) {
      _openPhotoDetailSheet(slot);
      return;
    }

    ref.read(editorControllerProvider.notifier).onSlotTap(slot);
  }

  void _onPoolPhotoTap(MediaPoolItem photo) {
    final state = ref.read(editorControllerProvider);
    if (state.selectedSlotId == null) {
      // Если слот не был выбран заранее, автоматически выбираем первый пустой слот текущей страницы
      final currentPage = state.currentPage;
      final emptySlot = currentPage.slots.where((s) => s.status == SlotStatus.empty).firstOrNull;

      if (emptySlot != null) {
        ref.read(editorControllerProvider.notifier).onSlotTap(emptySlot);
        ref.read(editorControllerProvider.notifier).assignPhotoToSlot(photo);
        _showToast(context, 'Фото размещено в пустой слот страницы ${currentPage.pageNumber}');
        return;
      }

      _showToast(context, 'Сначала выберите слот на странице альбома');
      return;
    }

    ref.read(editorControllerProvider.notifier).assignPhotoToSlot(photo);
    _showToast(context, 'Фото добавлено в разворот!');
  }

  void _openPhotoDetailSheet(SlotModel slot) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: PicPacColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      builder: (sheetContext) {
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
                Text(
                  'Редактирование фото',
                  style: PicPacTypography.h2Section,
                ),
                const SizedBox(height: 12.0),
                if (slot.imageUrl != null)
                  SizedBox(
                    height: 180.0,
                    child: PicPacImage(
                      imageUrl: slot.imageUrl,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                const SizedBox(height: 16.0),
                Text(
                  'Подпись (до 50 символов):',
                  style: PicPacTypography.metaInfo,
                ),
                const SizedBox(height: 6.0),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                  decoration: BoxDecoration(
                    color: PicPacColors.surfaceGrey,
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(color: PicPacColors.borderDefault),
                  ),
                  child: Text(
                    slot.caption ?? 'Без подписи',
                    style: PicPacTypography.photoCaption,
                  ),
                ),
                const SizedBox(height: 16.0),
                Text(
                  'Быстрые реакции:',
                  style: PicPacTypography.metaInfo,
                ),
                const SizedBox(height: 8.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: ['❤️', '🔥', '👍', '😂'].map((emoji) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.pop(sheetContext);
                        _addReactionToSlot(slot, emoji);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 8.0,
                        ),
                        decoration: BoxDecoration(
                          color: PicPacColors.surfaceGrey,
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Text(
                          emoji,
                          style: const TextStyle(fontSize: 22.0),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20.0),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pop(sheetContext);
                          _removeSlotPhoto(slot);
                        },
                        child: Container(
                          height: 44.0,
                          decoration: BoxDecoration(
                            color: PicPacColors.surfaceGrey,
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Очистить слот',
                            style: PicPacTypography.buttonTextDark,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12.0),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.pop(sheetContext),
                        child: Container(
                          height: 44.0,
                          decoration: BoxDecoration(
                            color: PicPacColors.textDark,
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Закрыть',
                            style: PicPacTypography.buttonText,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _addReactionToSlot(SlotModel slot, String emoji) {
    ref.read(editorControllerProvider.notifier).toggleReaction(slot.id, emoji);
  }

  void _removeSlotPhoto(SlotModel slot) {
    ref.read(editorControllerProvider.notifier).clearSlot(slot.id);
    _showToast(context, 'Слот очищен');
  }

  /// Полноэкранный просмотр всей медиатеки альбома в виде сетки
  void _openMediaPoolFullScreen() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: PicPacColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      builder: (sheetContext) {
        return DraggableScrollableSheet(
          initialChildSize: 0.9,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            final pool = ref.watch(editorControllerProvider).poolPhotos;

            return Column(
              children: [
                Center(
                  child: Container(
                    width: 36.0,
                    height: 4.0,
                    margin: const EdgeInsets.symmetric(vertical: 12.0),
                    decoration: BoxDecoration(
                      color: PicPacColors.borderDefault,
                      borderRadius: BorderRadius.circular(2.0),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Медиатека альбома (${pool.length})',
                          style: PicPacTypography.h1Title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(sheetContext);
                          _openAddPhotoDialog();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                          decoration: BoxDecoration(
                            color: PicPacColors.primaryCoralSoft,
                            borderRadius: BorderRadius.circular(6.0),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(LucideIcons.plus, size: 14.0, color: PicPacColors.primaryCoral),
                              const SizedBox(width: 4.0),
                              Text(
                                'Добавить',
                                style: PicPacTypography.buttonText.copyWith(
                                  color: PicPacColors.primaryCoral,
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 16.0, color: PicPacColors.borderDefault),
                Expanded(
                  child: pool.isEmpty
                      ? Center(
                          child: Text(
                            'В пуле пока нет фото.\nНажмите "+ Добавить", чтобы загрузить.',
                            textAlign: TextAlign.center,
                            style: PicPacTypography.photoCaption,
                          ),
                        )
                      : GridView.builder(
                          controller: scrollController,
                          padding: const EdgeInsets.all(16.0),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 10.0,
                            mainAxisSpacing: 10.0,
                            childAspectRatio: 1.0,
                          ),
                          itemCount: pool.length,
                          itemBuilder: (context, index) {
                            final item = pool[index];
                            return GestureDetector(
                              onTap: () {
                                Navigator.pop(sheetContext);
                                _onPoolPhotoTap(item);
                              },
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    PicPacImage(
                                      imageUrl: item.imageUrl,
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    Positioned(
                                      bottom: 0,
                                      left: 0,
                                      right: 0,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
                                        color: Colors.black54,
                                        child: Text(
                                          item.uploaderName,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 9.0,
                                            fontWeight: FontWeight.w500,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
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
              ],
            );
          },
        );
      },
    );
  }

  /// Диалог загрузки своего фото
  Future<void> _openAddPhotoDialog() async {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: PicPacColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      builder: (sheetContext) {
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
                Text(
                  'Добавить фото в общий пул',
                  style: PicPacTypography.h2Section,
                ),
                const SizedBox(height: 16.0),
                ListTile(
                  leading: const Icon(LucideIcons.image, color: PicPacColors.primaryCoral),
                  title: Text(
                    'Выбрать из галереи телефона',
                    style: PicPacTypography.photoCaption.copyWith(fontWeight: FontWeight.w600),
                  ),
                  tileColor: PicPacColors.surfaceGrey,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                  onTap: () async {
                    Navigator.pop(sheetContext);
                    await _pickFromGallery();
                  },
                ),
                const SizedBox(height: 8.0),
                ListTile(
                  leading: const Icon(LucideIcons.camera, color: PicPacColors.primaryCoral),
                  title: Text(
                    'Сделать снимок камерой',
                    style: PicPacTypography.photoCaption.copyWith(fontWeight: FontWeight.w600),
                  ),
                  tileColor: PicPacColors.surfaceGrey,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                  onTap: () async {
                    Navigator.pop(sheetContext);
                    await _pickFromCamera();
                  },
                ),
                const SizedBox(height: 8.0),
                ListTile(
                  leading: const Icon(LucideIcons.sparkles, color: PicPacColors.primaryCoral),
                  title: Text(
                    'Добавить выпускной кадр (образец)',
                    style: PicPacTypography.photoCaption.copyWith(fontWeight: FontWeight.w600),
                  ),
                  tileColor: PicPacColors.surfaceGrey,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _addPresetPhoto();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickFromGallery() async {
    try {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );
      if (image != null) {
        final bytes = await image.readAsBytes();
        await ref.read(editorControllerProvider.notifier).addCustomPhoto(
              imageUrl: image.path,
              uploaderName: widget.userName,
              fileBytes: bytes,
              fileName: image.name,
            );
        if (mounted) _showToast(context, 'Фотография добавлена в общий пул!');
      }
    } catch (e) {
      if (mounted) _showToast(context, 'Не удалось выбрать фото: $e');
    }
  }

  Future<void> _pickFromCamera() async {
    try {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );
      if (image != null) {
        final bytes = await image.readAsBytes();
        await ref.read(editorControllerProvider.notifier).addCustomPhoto(
              imageUrl: image.path,
              uploaderName: widget.userName,
              fileBytes: bytes,
              fileName: image.name,
            );
        if (mounted) _showToast(context, 'Снимок с камеры добавлен в пул!');
      }
    } catch (e) {
      if (mounted) _showToast(context, 'Камера недоступна: $e');
    }
  }

  void _addPresetPhoto() {
    final samplePhotos = [
      'https://images.unsplash.com/photo-1544717305-2782549b5136?w=600&fit=crop',
      'https://images.unsplash.com/photo-1577896851231-70ef18881754?w=600&fit=crop',
      'https://images.unsplash.com/photo-1509062522246-3755977927d7?w=600&fit=crop',
      'https://images.unsplash.com/photo-1511632765486-a01980e01a18?w=600&fit=crop',
      'https://images.unsplash.com/photo-1491438590914-bc09fcaaf77a?w=600&fit=crop',
    ];
    final randomIndex = DateTime.now().millisecondsSinceEpoch % samplePhotos.length;
    ref.read(editorControllerProvider.notifier).addCustomPhoto(
          imageUrl: samplePhotos[randomIndex],
          uploaderName: widget.userName,
        );
    _showToast(context, 'Школьное фото добавлено в пул альбома!');
  }

  /// Выбор сетки страницы (1, 2, 3 или 4 слота)
  void _openLayoutSelectorSheet() {
    final state = ref.read(editorControllerProvider);
    final currentPage = state.currentPage;
    final currentSlotsCount = currentPage.slots.length;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: PicPacColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      builder: (sheetContext) {
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
                Text(
                  'Сетка страницы ${currentPage.pageNumber}',
                  style: PicPacTypography.h2Section,
                ),
                const SizedBox(height: 8.0),
                Text(
                  'Выберите количество фото на текущей странице:',
                  style: PicPacTypography.photoCaption,
                ),
                const SizedBox(height: 16.0),
                _buildLayoutOption(
                  title: '1 фото на всю страницу',
                  subtitle: 'Одно главное крупное акцентное фото',
                  slotsCount: 1,
                  isSelected: currentSlotsCount == 1,
                  sheetContext: sheetContext,
                ),
                const SizedBox(height: 8.0),
                _buildLayoutOption(
                  title: '2 фото вертикально',
                  subtitle: 'Две фотографии друг над другом',
                  slotsCount: 2,
                  isSelected: currentSlotsCount == 2,
                  sheetContext: sheetContext,
                ),
                const SizedBox(height: 8.0),
                _buildLayoutOption(
                  title: '3 фото (1 большое + 2 малых)',
                  subtitle: 'Панорамный верхний снимок и два внизу',
                  slotsCount: 3,
                  isSelected: currentSlotsCount == 3,
                  sheetContext: sheetContext,
                ),
                const SizedBox(height: 8.0),
                _buildLayoutOption(
                  title: '4 фото (сетка 2×2)',
                  subtitle: 'Классическое расположение для группы',
                  slotsCount: 4,
                  isSelected: currentSlotsCount >= 4,
                  sheetContext: sheetContext,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLayoutOption({
    required String title,
    required String subtitle,
    required int slotsCount,
    required bool isSelected,
    required BuildContext sheetContext,
  }) {
    return ListTile(
      onTap: () {
        Navigator.pop(sheetContext);
        final currentPageNum = ref.read(editorControllerProvider).currentPageNumber;
        ref.read(editorControllerProvider.notifier).setPageLayout(currentPageNum, slotsCount);
        _showToast(context, 'Сетка страницы изменена: $slotsCount фото');
      },
      leading: Container(
        width: 36.0,
        height: 36.0,
        decoration: BoxDecoration(
          color: isSelected ? PicPacColors.primaryCoralSoft : PicPacColors.surfaceGrey,
          borderRadius: BorderRadius.circular(6.0),
        ),
        alignment: Alignment.center,
        child: Text(
          '$slotsCount',
          style: TextStyle(
            color: isSelected ? PicPacColors.primaryCoral : PicPacColors.textDark,
            fontWeight: FontWeight.w700,
            fontSize: 16.0,
          ),
        ),
      ),
      title: Text(
        title,
        style: PicPacTypography.buttonTextDark.copyWith(
          color: isSelected ? PicPacColors.primaryCoral : PicPacColors.textDark,
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
        ),
      ),
      subtitle: Text(subtitle, style: PicPacTypography.metaInfo),
      trailing: isSelected
          ? const Icon(LucideIcons.check, color: PicPacColors.primaryCoral, size: 20.0)
          : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
        side: BorderSide(
          color: isSelected ? PicPacColors.primaryCoral : PicPacColors.borderDefault,
        ),
      ),
      tileColor: isSelected ? PicPacColors.primaryCoralSoft.withValues(alpha: 0.3) : PicPacColors.white,
    );
  }

  /// Просмотр участников альбома
  void _openMembersSheet() {
    final state = ref.read(editorControllerProvider);
    final members = state.members;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: PicPacColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      builder: (sheetContext) {
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
                        'Код: ${state.inviteCode.isNotEmpty ? state.inviteCode : "849204"}',
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
      },
    );
  }

  /// Голосование за обложку книги
  void _openCoverVotingSheet() {
    final pool = ref.read(editorControllerProvider).poolPhotos;
    final photosList = pool.isNotEmpty ? pool : MockData.poolPhotos;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: PicPacColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final activePhoto = photosList[_selectedCoverPhotoIndex.clamp(0, photosList.length - 1)];

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
                    Text(
                      '👑 Голосование за обложку альбома',
                      style: PicPacTypography.h2Section,
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      'Выберите фотографию, которая украсит твердый переплет книги:',
                      style: PicPacTypography.photoCaption.copyWith(
                        color: PicPacColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    SizedBox(
                      height: 180.0,
                      child: PicPacImage(
                        imageUrl: activePhoto.imageUrl,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    const SizedBox(height: 12.0),
                    // Карусель миниатюр кандидатов на обложку
                    SizedBox(
                      height: 54.0,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: photosList.length,
                        separatorBuilder: (context, index) => const SizedBox(width: 8.0),
                        itemBuilder: (ctx, idx) {
                          final p = photosList[idx];
                          final isCurrent = idx == _selectedCoverPhotoIndex;
                          return GestureDetector(
                            onTap: () {
                              setSheetState(() {
                                _selectedCoverPhotoIndex = idx;
                              });
                            },
                            child: Container(
                              width: 54.0,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(6.0),
                                border: Border.all(
                                  color: isCurrent ? PicPacColors.primaryCoral : PicPacColors.borderDefault,
                                  width: isCurrent ? 2.0 : 1.0,
                                ),
                              ),
                              child: PicPacImage(
                                imageUrl: p.imageUrl,
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(sheetContext);
                        final state = ref.read(editorControllerProvider);
                        if (state.selectedSlotId != null) {
                          ref.read(editorControllerProvider.notifier).voteCover(state.selectedSlotId!);
                        }
                        _showToast(context, 'Ваш голос за обложку альбома сохранен!');
                      },
                      child: Container(
                        height: 44.0,
                        decoration: BoxDecoration(
                          color: PicPacColors.primaryCoral,
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Голосовать за этот вариант',
                          style: PicPacTypography.buttonText,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _openOrderSheet() {
    final state = ref.read(editorControllerProvider);
    Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (_) => CheckoutScreen(
          albumTitle: state.albumTitle.isNotEmpty ? state.albumTitle : widget.albumTitle,
          userName: widget.userName,
          itemsCost: 2.90,
          discount: 0.81,
        ),
      ),
    );
  }

  void _showShareDialog(String inviteCode) {
    final displayCode = inviteCode.isNotEmpty
        ? (inviteCode.length == 6
            ? '${inviteCode.substring(0, 3)} - ${inviteCode.substring(3)}'
            : inviteCode)
        : '849 - 204';

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: PicPacColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          title: Text(
            'Пригласить одноклассников',
            style: PicPacTypography.h2Section,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Отправьте 6-значный код для совместного заполнения альбома:',
                style: PicPacTypography.photoCaption,
              ),
              const SizedBox(height: 16.0),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                decoration: BoxDecoration(
                  color: PicPacColors.surfaceGrey,
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(color: PicPacColors.borderDefault),
                ),
                alignment: Alignment.center,
                child: Text(
                  displayCode,
                  style: const TextStyle(
                    fontSize: 22.0,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 4.0,
                    color: PicPacColors.textDark,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                'Скопировать ссылку',
                style: PicPacTypography.buttonTextDark.copyWith(
                  color: PicPacColors.primaryCoral,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showToast(BuildContext context, String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: PicPacTypography.buttonText.copyWith(fontSize: 13.0),
        ),
        backgroundColor: PicPacColors.textDark,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final editorState = ref.watch(editorControllerProvider);

    final pages = editorState.pages.isNotEmpty
        ? editorState.pages
        : MockData.generatePages();
    final members = editorState.members.isNotEmpty
        ? editorState.members
        : MockData.activeMembers;
    final poolPhotos = editorState.poolPhotos.isNotEmpty
        ? editorState.poolPhotos
        : MockData.poolPhotos;
    final currentPage = editorState.currentPage;
    final filledPagesCount = editorState.filledPagesCount;
    final title = editorState.albumTitle.isNotEmpty
        ? editorState.albumTitle
        : widget.albumTitle;

    return Scaffold(
      backgroundColor: PicPacColors.surfaceGrey,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // ЗОНА 1: Top AppBar (Высота 52px, фон #FFFFFF)
            Zone1TopBar(
              title: title,
              members: members,
              onBackTap: () {
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                } else {
                  _showToast(context, 'Возврат к списку альбомов');
                }
              },
              onShareTap: () => _showShareDialog(editorState.inviteCode),
              onMembersTap: _openMembersSheet,
            ),

            // ЗОНА 2: Мини-карта страниц (Высота 44px, фон #F5F5F5) с автоскроллом
            Zone2PageMinimap(
              pages: pages,
              currentPage: editorState.currentPageNumber,
              onPageSelected: _onPageSelected,
            ),

            // ЗОНА 3: Рабочий стол и Холст страницы (Expanded)
            Expanded(
              child: Zone3SpreadCanvas(
                page: currentPage,
                totalPages: pages.length,
                onPageChange: _onPageSelected,
                onSlotTap: _onSlotTap,
                aspectRatio: widget.aspectRatio,
              ),
            ),

            // ЗОНА 4: Панель «Общая медиатека» (Высота 98px, фон #FFFFFF)
            Zone4MediaPool(
              photos: poolPhotos,
              onPhotoTap: _onPoolPhotoTap,
              onUploadTap: _openAddPhotoDialog,
              onExpandTap: _openMediaPoolFullScreen,
            ),

            // ЗОНА 5: Нижний док управления (Высота 64px + SafeArea, фон #FFFFFF)
            Zone5BottomDock(
              filledPagesCount: filledPagesCount,
              totalPagesCount: pages.length,
              coverVotesCount: 5,
              onCoverTap: _openCoverVotingSheet,
              onLayoutTap: _openLayoutSelectorSheet,
              onOrderTap: _openOrderSheet,
            ),
          ],
        ),
      ),
    );
  }
}
