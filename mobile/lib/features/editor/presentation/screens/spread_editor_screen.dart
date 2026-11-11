import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/session/session_state.dart';
import '../../../../core/theme/picpac_colors.dart';
import '../../../../core/theme/picpac_typography.dart';
import '../../../../core/widgets/picpac_image.dart';
import '../../../cart/presentation/screens/cart_screen.dart';
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
  final String templateId;

  const SpreadEditorScreen({
    super.key,
    this.albumId,
    this.albumTitle = 'Выпускной 11-Б • 2026',
    this.userName = 'Артём',
    this.aspectRatio = 3.0 / 4.0,
    this.spreadsCount = 10,
    this.templateId = 'school_drive',
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
              templateId: widget.templateId,
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

  /// Выбор сетки страницы (разнообразные дизайнерские макеты)
  void _openLayoutSelectorSheet() {
    final state = ref.read(editorControllerProvider);
    final currentPage = state.currentPage;
    final currentLayout = currentPage.layoutType;
    final currentSlotsCount = currentPage.slots.length;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: PicPacColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      builder: (sheetContext) {
        return DraggableScrollableSheet(
          initialChildSize: 0.75,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                    Center(
                      child: Container(
                        width: 36.0,
                        height: 4.0,
                        margin: const EdgeInsets.only(bottom: 14.0),
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
                    const SizedBox(height: 6.0),
                    Text(
                      'Выберите расположение и стиль фотографий:',
                      style: PicPacTypography.photoCaption,
                    ),
                    const SizedBox(height: 16.0),

                    // Одиночные фото
                    _buildLayoutCategoryHeader('1 ФОТОГРАФИЯ (АКЦЕНТ)'),
                    _buildLayoutOption(
                      title: '1 фото на всю страницу',
                      subtitle: 'Полностраничный панорамный акцент',
                      layout: 'single_full',
                      badgeText: '1',
                      isSelected: currentLayout == 'single_full' || (currentSlotsCount == 1 && currentLayout != 'hero_centered'),
                      sheetContext: sheetContext,
                    ),
                    const SizedBox(height: 8.0),
                    _buildLayoutOption(
                      title: '1 фото с паспарту',
                      subtitle: 'Элегантные широкие поля в стиле арт-альбома',
                      layout: 'hero_centered',
                      badgeText: '1',
                      isSelected: currentLayout == 'hero_centered',
                      sheetContext: sheetContext,
                    ),
                    const SizedBox(height: 16.0),

                    // 2 фото
                    _buildLayoutCategoryHeader('2 ФОТОГРАФИИ'),
                    _buildLayoutOption(
                      title: '2 фото вертикально',
                      subtitle: 'Два стройных портрета рядом (колонки)',
                      layout: 'split_vertical_2',
                      badgeText: '2',
                      isSelected: currentLayout == 'split_vertical_2',
                      sheetContext: sheetContext,
                    ),
                    const SizedBox(height: 8.0),
                    _buildLayoutOption(
                      title: '2 фото горизонтально',
                      subtitle: 'Две фотографии друг над другом',
                      layout: 'split_horizontal_2',
                      badgeText: '2',
                      isSelected: currentLayout == 'split_horizontal_2',
                      sheetContext: sheetContext,
                    ),
                    const SizedBox(height: 8.0),
                    _buildLayoutOption(
                      title: 'Журнальный заголовок + фото',
                      subtitle: 'Стильный крупный слоган (GO, BOYS!) и 2 фото',
                      layout: 'editorial_quote',
                      badgeText: '2',
                      isSelected: currentLayout == 'editorial_quote',
                      sheetContext: sheetContext,
                    ),
                    const SizedBox(height: 16.0),

                    // 3 фото
                    _buildLayoutCategoryHeader('3 ФОТОГРАФИИ (КОЛЛАЖИ)'),
                    _buildLayoutOption(
                      title: 'Шахматный коллаж (LET\'S GO)',
                      subtitle: '3 фото в шахматном порядке с типографикой',
                      layout: 'checkerboard_3',
                      badgeText: '3',
                      isSelected: currentLayout == 'checkerboard_3',
                      sheetContext: sheetContext,
                    ),
                    const SizedBox(height: 8.0),
                    _buildLayoutOption(
                      title: '3 фото (1 большое + 2 малых)',
                      subtitle: 'Панорамный верхний снимок и два внизу',
                      layout: 'hero_top_split_bottom_3',
                      badgeText: '3',
                      isSelected: currentLayout == 'hero_top_split_bottom_3',
                      sheetContext: sheetContext,
                    ),
                    const SizedBox(height: 8.0),
                    _buildLayoutOption(
                      title: '3 фото полосами',
                      subtitle: 'Три вертикальных портрета рядом в ряд',
                      layout: 'split_vertical_3',
                      badgeText: '3',
                      isSelected: currentLayout == 'split_vertical_3',
                      sheetContext: sheetContext,
                    ),
                    const SizedBox(height: 16.0),

                    // 4 фото
                    _buildLayoutCategoryHeader('4 ФОТОГРАФИИ (ГРУППОВЫЕ)'),
                    _buildLayoutOption(
                      title: '1 широкое + 3 портрета внизу',
                      subtitle: 'Широкое фото сверху и 3 портрета в ряд снизу',
                      layout: 'hero_top_trio_4',
                      badgeText: '4',
                      isSelected: currentLayout == 'hero_top_trio_4',
                      sheetContext: sheetContext,
                    ),
                    const SizedBox(height: 8.0),
                    _buildLayoutOption(
                      title: '4 фото (сетка 2×2)',
                      subtitle: 'Классическое расположение для группы',
                      layout: 'grid_4',
                      badgeText: '4',
                      isSelected: currentLayout == 'grid_4',
                      sheetContext: sheetContext,
                    ),
                    const SizedBox(height: 16.0),
                  ],
                ),
              ),
            ),
          );
          },
        );
      },
    );
  }

  Widget _buildLayoutCategoryHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, top: 4.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
          color: PicPacColors.textMuted,
        ),
      ),
    );
  }

  Widget _buildLayoutOption({
    required String title,
    required String subtitle,
    required dynamic layout,
    required String badgeText,
    required bool isSelected,
    required BuildContext sheetContext,
  }) {
    return ListTile(
      onTap: () {
        Navigator.pop(sheetContext);
        final currentPageNum = ref.read(editorControllerProvider).currentPageNumber;
        ref.read(editorControllerProvider.notifier).setPageLayout(currentPageNum, layout);
        _showToast(context, 'Сетка страницы изменена: $title');
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
          badgeText,
          style: TextStyle(
            color: isSelected ? PicPacColors.primaryCoral : PicPacColors.textDark,
            fontWeight: FontWeight.w700,
            fontSize: 15.0,
          ),
        ),
      ),
      title: Text(
        title,
        style: PicPacTypography.buttonTextDark.copyWith(
          color: isSelected ? PicPacColors.primaryCoral : PicPacColors.textDark,
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          fontSize: 13.5,
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
            final editorState = ref.watch(editorControllerProvider);
            final pool = editorState.poolPhotos;
            final photosList = pool.isNotEmpty ? pool : MockData.poolPhotos;
            final safeIndex = _selectedCoverPhotoIndex.clamp(0, photosList.length - 1);
            final activePhoto = photosList[safeIndex];
            final photoVotes = editorState.coverVotes[activePhoto.id] ?? 0;
            final isLeader = editorState.winningCoverPhoto?.id == activePhoto.id;

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
                        const Icon(LucideIcons.crown, color: Color(0xFFF59E0B), size: 22.0),
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
                    // Карусель миниатюр кандидатов на обложку
                    SizedBox(
                      height: 60.0,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: photosList.length,
                        separatorBuilder: (context, index) => const SizedBox(width: 8.0),
                        itemBuilder: (ctx, idx) {
                          final p = photosList[idx];
                          final isCurrent = idx == safeIndex;
                          final vCount = editorState.coverVotes[p.id] ?? 0;
                          return GestureDetector(
                            onTap: () {
                              setSheetState(() {
                                _selectedCoverPhotoIndex = idx;
                              });
                            },
                            child: Stack(
                              children: [
                                Container(
                                  width: 60.0,
                                  height: 60.0,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8.0),
                                    border: Border.all(
                                      color: isCurrent ? PicPacColors.primaryCoral : PicPacColors.borderDefault,
                                      width: isCurrent ? 2.5 : 1.0,
                                    ),
                                  ),
                                  child: PicPacImage(
                                    imageUrl: p.imageUrl,
                                    borderRadius: BorderRadius.circular(6.0),
                                  ),
                                ),
                                if (vCount > 0)
                                  Positioned(
                                    top: 3.0,
                                    right: 3.0,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withValues(alpha: 0.7),
                                        borderRadius: BorderRadius.circular(4.0),
                                      ),
                                      child: Text(
                                        '$vCount',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 9.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    GestureDetector(
                      onTap: () {
                        ref.read(editorControllerProvider.notifier).voteCover(activePhoto.id);
                        Navigator.pop(sheetContext);
                        _showToast(context, 'Ваш голос за обложку альбома сохранен!');
                      },
                      child: Container(
                        height: 46.0,
                        decoration: BoxDecoration(
                          color: PicPacColors.primaryCoral,
                          borderRadius: BorderRadius.circular(8.0),
                          boxShadow: [
                            BoxShadow(
                              color: PicPacColors.primaryCoral.withValues(alpha: 0.25),
                              blurRadius: 8.0,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
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
    final albumTitle = state.albumTitle.isNotEmpty ? state.albumTitle : widget.albumTitle;
    final spreadsCount = (state.pages.length / 2).ceil();

    // Сохраняем актуальный альбом в сессии для корзины
    final currentSession = ref.read(sessionProvider);
    final updatedAlbum = AlbumData(
      id: currentSession.currentAlbum?.id ?? 'album_editor',
      name: albumTitle,
      format: currentSession.currentAlbum?.format ?? '20x20',
      lamination: currentSession.currentAlbum?.lamination ?? 'soft_touch',
      templateId: state.templateId,
      spreadsCount: spreadsCount,
      inviteCode: currentSession.currentAlbum?.inviteCode ?? '849204',
      status: 'ready_to_order',
    );
    ref.read(sessionProvider.notifier).setAlbum(updatedAlbum);

    // Добавляем или обновляем CartItem в сессии с превью обложки
    ref.read(sessionProvider.notifier).addOrUpdateCartItem(
      CartItem(
        id: updatedAlbum.id,
        title: albumTitle,
        format: '20×20 см',
        spreadsCount: spreadsCount,
        templateId: state.templateId,
        coverImageUrl: state.winningCoverPhoto?.imageUrl,
        price: 72.90,
        oldPrice: 95.00,
        quantity: 1,
        isSelected: true,
      ),
    );

    Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (_) => const CartScreen(),
      ),
    );
  }

  void _showShareDialog(String inviteCode) {
    final rawCode = inviteCode.isNotEmpty ? inviteCode : '849204';
    final displayCode = rawCode.length == 6
        ? '${rawCode.substring(0, 3)} - ${rawCode.substring(3)}'
        : rawCode;
    final shareUrl = 'picpac://join?code=$rawCode';

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
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
              // Ссылка на приложение с кодом
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
                    _showToast(context, 'Ссылка скопирована!');
                    final uri = Uri.parse(shareUrl);
                    try {
                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                    } catch (_) {}
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                    decoration: BoxDecoration(
                      color: PicPacColors.surfaceGrey,
                      borderRadius: BorderRadius.circular(10.0),
                      border: Border.all(color: PicPacColors.borderDefault),
                    ),
                    child: Row(
                      children: [
                        const Icon(LucideIcons.link, size: 16.0, color: PicPacColors.textMuted),
                        const SizedBox(width: 8.0),
                        Expanded(
                          child: Text(
                            shareUrl,
                            style: PicPacTypography.photoCaption.copyWith(
                              fontSize: 13.0,
                              color: PicPacColors.primaryCoral,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(LucideIcons.copy, size: 18.0, color: PicPacColors.textDark),
                          tooltip: 'Скопировать ссылку',
                          constraints: const BoxConstraints(),
                          padding: EdgeInsets.zero,
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: shareUrl));
                            _showToast(context, 'Ссылка скопирована в буфер обмена!');
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14.0),
              // Код альбома
              Text(
                'Код альбома:',
                style: PicPacTypography.buttonTextDark.copyWith(
                  fontSize: 12.0,
                  color: PicPacColors.textMuted,
                ),
              ),
              const SizedBox(height: 6.0),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
                decoration: BoxDecoration(
                  color: PicPacColors.surfaceGrey,
                  borderRadius: BorderRadius.circular(10.0),
                  border: Border.all(color: PicPacColors.borderDefault),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      displayCode,
                      style: const TextStyle(
                        fontSize: 22.0,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 4.0,
                        color: PicPacColors.textDark,
                      ),
                    ),
                    const SizedBox(width: 12.0),
                    IconButton(
                      icon: const Icon(LucideIcons.copy, size: 18.0, color: PicPacColors.textDark),
                      tooltip: 'Скопировать код',
                      constraints: const BoxConstraints(),
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: rawCode));
                        _showToast(context, 'Код $rawCode скопирован!');
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          actionsPadding: const EdgeInsets.fromLTRB(20.0, 8.0, 20.0, 18.0),
          actions: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Кнопка "Поделиться ссылкой" (растянута по центру, сверху)
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

                // 2. Кнопка "Выход" (под кнопкой поделиться, растянута по центру)
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: PicPacColors.textDark,
                    minimumSize: const Size.fromHeight(44.0),
                    side: const BorderSide(color: PicPacColors.borderDefault, width: 1.2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  onPressed: () => Navigator.pop(dialogContext),
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
                templateId: editorState.templateId,
                albumTitle: title,
                winningPhoto: editorState.winningCoverPhoto,
                votesCount: editorState.coverVotes[editorState.winningCoverPhoto?.id] ?? 0,
                totalVotes: editorState.totalCoverVotes,
                onVoteTap: _openCoverVotingSheet,
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
              coverVotesCount: editorState.totalCoverVotes,
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
