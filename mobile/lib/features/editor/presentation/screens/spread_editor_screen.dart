import 'package:flutter/material.dart';
import '../../../../core/theme/picpac_colors.dart';
import '../../../../core/theme/picpac_typography.dart';
import '../../domain/mock_data.dart';
import '../../domain/models.dart';
import '../widgets/zone1_top_bar.dart';
import '../widgets/zone2_page_minimap.dart';
import '../widgets/zone3_spread_canvas.dart';
import '../widgets/zone4_media_pool.dart';
import '../widgets/zone5_bottom_dock.dart';

class SpreadEditorScreen extends StatefulWidget {
  const SpreadEditorScreen({super.key});

  @override
  State<SpreadEditorScreen> createState() => _SpreadEditorScreenState();
}

class _SpreadEditorScreenState extends State<SpreadEditorScreen> {
  late List<PageModel> _pages;
  late List<MemberModel> _members;
  late List<MediaPoolItem> _poolPhotos;

  // По умолчанию открываем страницу 4, где наглядно видны все 4 состояния слотов
  int _currentPageNumber = 4;
  String? _selectedSlotId = 'slot_4_1';

  @override
  void initState() {
    super.initState();
    _pages = MockData.generatePages();
    _members = MockData.activeMembers;
    _poolPhotos = MockData.poolPhotos;
  }

  PageModel get _currentPage {
    return _pages.firstWhere(
      (p) => p.pageNumber == _currentPageNumber,
      orElse: () => _pages.first,
    );
  }

  int get _filledPagesCount {
    return _pages.where((p) => p.filledSlotsCount == 4).length;
  }

  void _onPageSelected(int pageNumber) {
    setState(() {
      _currentPageNumber = pageNumber;
      _selectedSlotId = null;
    });
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

    // Переключение выбора слота (Механика вставки: Тап 1)
    setState(() {
      _selectedSlotId = slot.id;
      final pageIndex = _pages.indexWhere((p) => p.pageNumber == _currentPageNumber);
      if (pageIndex != -1) {
        final updatedSlots = _pages[pageIndex].slots.map((s) {
          if (s.id == slot.id) {
            return s.copyWith(status: SlotStatus.selected);
          } else if (s.status == SlotStatus.selected) {
            return s.copyWith(status: SlotStatus.empty);
          }
          return s;
        }).toList();

        _pages[pageIndex] = PageModel(
          pageNumber: _pages[pageIndex].pageNumber,
          side: _pages[pageIndex].side,
          slots: updatedSlots,
        );
      }
    });
  }

  void _onPoolPhotoTap(MediaPoolItem photo) {
    // Механика вставки: Тап 2 по фото из нижнего пула
    if (_selectedSlotId == null) {
      _showToast(context, 'Сначала выберите слот на листе книги');
      return;
    }

    final pageIndex = _pages.indexWhere((p) => p.pageNumber == _currentPageNumber);
    if (pageIndex == -1) return;

    setState(() {
      final updatedSlots = _pages[pageIndex].slots.map((slot) {
        if (slot.id == _selectedSlotId) {
          return slot.copyWith(
            status: SlotStatus.filled,
            imageUrl: photo.imageUrl,
            authorName: 'добавил ${photo.uploaderName}',
            caption: 'Фото из пула',
            reactions: {'❤️': 1},
          );
        }
        return slot;
      }).toList();

      _pages[pageIndex] = PageModel(
        pageNumber: _pages[pageIndex].pageNumber,
        side: _pages[pageIndex].side,
        slots: updatedSlots,
      );
      _selectedSlotId = null;
    });

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
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: SizedBox(
                      height: 180.0,
                      child: Image.network(
                        slot.imageUrl!,
                        fit: BoxFit.cover,
                      ),
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
    final pageIndex = _pages.indexWhere((p) => p.pageNumber == _currentPageNumber);
    if (pageIndex == -1) return;

    setState(() {
      final updatedSlots = _pages[pageIndex].slots.map((s) {
        if (s.id == slot.id) {
          final newReactions = Map<String, int>.from(s.reactions);
          newReactions[emoji] = (newReactions[emoji] ?? 0) + 1;
          return s.copyWith(reactions: newReactions);
        }
        return s;
      }).toList();

      _pages[pageIndex] = PageModel(
        pageNumber: _pages[pageIndex].pageNumber,
        side: _pages[pageIndex].side,
        slots: updatedSlots,
      );
    });
  }

  void _removeSlotPhoto(SlotModel slot) {
    final pageIndex = _pages.indexWhere((p) => p.pageNumber == _currentPageNumber);
    if (pageIndex == -1) return;

    setState(() {
      final updatedSlots = _pages[pageIndex].slots.map((s) {
        if (s.id == slot.id) {
          return s.copyWith(
            status: SlotStatus.empty,
            imageUrl: null,
            caption: null,
            authorName: null,
            reactions: {},
          );
        }
        return s;
      }).toList();

      _pages[pageIndex] = PageModel(
        pageNumber: _pages[pageIndex].pageNumber,
        side: _pages[pageIndex].side,
        slots: updatedSlots,
      );
    });
  }

  void _openCoverVotingSheet() {
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
                  '👑 Голосование за обложку альбома',
                  style: PicPacTypography.h2Section,
                ),
                const SizedBox(height: 8.0),
                Text(
                  'Участники проголосовали 5 раз. Лидирует общий снимок на выпускном.',
                  style: PicPacTypography.photoCaption.copyWith(
                    color: PicPacColors.textMuted,
                  ),
                ),
                const SizedBox(height: 16.0),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: SizedBox(
                    height: 160.0,
                    child: Image.network(
                      _poolPhotos.first.imageUrl,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 16.0),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _showToast(context, 'Ваш голос за обложку учтен!');
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
  }

  void _openOrderSheet() {
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
                  '🛒 Оформление заказа picPac.by',
                  style: PicPacTypography.h2Section,
                ),
                const SizedBox(height: 8.0),
                Text(
                  'Готовность книги: $_filledPagesCount из ${_pages.length} страниц полностью заполнены.',
                  style: PicPacTypography.photoCaption,
                ),
                const SizedBox(height: 16.0),
                Container(
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: PicPacColors.primaryCoralSoft,
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(
                      color: PicPacColors.primaryCoral.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Тираж для класса: 25 шт.',
                        style: PicPacTypography.buttonTextDark,
                      ),
                      Text(
                        'Скидка -20%',
                        style: PicPacTypography.buttonText.copyWith(
                          color: PicPacColors.primaryCoral,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20.0),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _showToast(context, 'Заказ отправлен в типографию picPac.by!');
                  },
                  child: Container(
                    height: 44.0,
                    decoration: BoxDecoration(
                      color: PicPacColors.primaryCoral,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'Отправить заказ в печать',
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
  }

  void _showShareDialog() {
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
                child: const Text(
                  '8 4 9 - 2 0 4',
                  style: TextStyle(
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
    return Scaffold(
      backgroundColor: PicPacColors.surfaceGrey,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // ЗОНА 1: Top AppBar (Высота 52px, фон #FFFFFF)
            Zone1TopBar(
              title: 'Выпускной 11-Б • 2026',
              members: _members,
              onBackTap: () {
                _showToast(context, 'Возврат к списку альбомов');
              },
              onShareTap: _showShareDialog,
            ),

            // ЗОНА 2: Мини-карта страниц (Высота 44px, фон #F5F5F5)
            Zone2PageMinimap(
              pages: _pages,
              currentPage: _currentPageNumber,
              onPageSelected: _onPageSelected,
            ),

            // ЗОНА 3: Рабочий стол и Холст страницы (Expanded)
            Expanded(
              child: Zone3SpreadCanvas(
                page: _currentPage,
                totalPages: _pages.length,
                onPageChange: _onPageSelected,
                onSlotTap: _onSlotTap,
              ),
            ),

            // ЗОНА 4: Панель «Общая медиатека» (Высота 98px, фон #FFFFFF)
            Zone4MediaPool(
              photos: _poolPhotos,
              onPhotoTap: _onPoolPhotoTap,
              onUploadTap: () {
                _showToast(context, 'Открытие системной галереи телефона...');
              },
            ),

            // ЗОНА 5: Нижний док управления (Высота 64px + SafeArea, фон #FFFFFF)
            Zone5BottomDock(
              filledPagesCount: _filledPagesCount,
              totalPagesCount: _pages.length,
              coverVotesCount: 5,
              onCoverTap: _openCoverVotingSheet,
              onLayoutTap: () {
                _showToast(context, 'Выбор сетки: 1, 2, 3 или 4 слота');
              },
              onOrderTap: _openOrderSheet,
            ),
          ],
        ),
      ),
    );
  }
}
