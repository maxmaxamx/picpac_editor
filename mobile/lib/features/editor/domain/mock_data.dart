import 'models.dart';

class MockData {
  static const List<MemberModel> activeMembers = [
    MemberModel(
      id: 'm1',
      name: 'Алина',
      avatarUrl:
          'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150&auto=format&fit=crop&q=80',
    ),
    MemberModel(
      id: 'm2',
      name: 'Артём',
      avatarUrl:
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150&auto=format&fit=crop&q=80',
    ),
    MemberModel(
      id: 'm3',
      name: 'София',
      avatarUrl:
          'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=150&auto=format&fit=crop&q=80',
    ),
    MemberModel(
      id: 'm4',
      name: 'Максим',
      avatarUrl:
          'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=150&auto=format&fit=crop&q=80',
    ),
  ];

  static const List<MediaPoolItem> poolPhotos = [
    MediaPoolItem(
      id: 'p1',
      imageUrl:
          'https://images.unsplash.com/photo-1523240795612-9a054b0db644?w=400&auto=format&fit=crop&q=80',
      uploaderName: 'Артём',
    ),
    MediaPoolItem(
      id: 'p2',
      imageUrl:
          'https://images.unsplash.com/photo-1511632765486-a01980e01a18?w=400&auto=format&fit=crop&q=80',
      uploaderName: 'Алина',
    ),
    MediaPoolItem(
      id: 'p3',
      imageUrl:
          'https://images.unsplash.com/photo-1529156069898-49953e39b3ac?w=400&auto=format&fit=crop&q=80',
      uploaderName: 'София',
    ),
    MediaPoolItem(
      id: 'p4',
      imageUrl:
          'https://images.unsplash.com/photo-1543269865-cbf427effbad?w=400&auto=format&fit=crop&q=80',
      uploaderName: 'Данила',
    ),
    MediaPoolItem(
      id: 'p5',
      imageUrl:
          'https://images.unsplash.com/photo-1517486808906-6ca8b3f04846?w=400&auto=format&fit=crop&q=80',
      uploaderName: 'Полина',
    ),
    MediaPoolItem(
      id: 'p6',
      imageUrl:
          'https://images.unsplash.com/photo-1522202176988-66273c2fd55f?w=400&auto=format&fit=crop&q=80',
      uploaderName: 'Максим',
    ),
    MediaPoolItem(
      id: 'p7',
      imageUrl:
          'https://images.unsplash.com/photo-1492684223066-81342ee5ff30?w=400&auto=format&fit=crop&q=80',
      uploaderName: 'Алина',
    ),
    MediaPoolItem(
      id: 'p8',
      imageUrl:
          'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400&auto=format&fit=crop&q=80',
      uploaderName: 'Артём',
    ),
  ];

  static List<PageModel> generatePages() {
    return List.generate(20, (pageIndex) {
      final pageNumber = pageIndex + 1;
      final side = pageNumber % 2 == 0 ? 'left' : 'right';

      if (pageNumber == 4) {
        // Страница 4 специально содержит все 4 состояния слотов из спецификации
        return PageModel(
          pageNumber: pageNumber,
          side: side,
          layoutType: 'grid_4',
          slots: [
            // Состояние Г — Заполненный слот
            const SlotModel(
              id: 'slot_4_0',
              slotIndex: 0,
              status: SlotStatus.filled,
              imageUrl:
                  'https://images.unsplash.com/photo-1523240795612-9a054b0db644?w=600&auto=format&fit=crop&q=80',
              caption: 'Максим на олимпиаде',
              authorName: 'добавил Артём',
              reactions: {'❤️': 4, '🔥': 2},
            ),
            // Состояние Б — Выбран текущим пользователем
            const SlotModel(
              id: 'slot_4_1',
              slotIndex: 1,
              status: SlotStatus.selected,
            ),
            // Состояние В — Заблокирован другим участником (Realtime Lock)
            const SlotModel(
              id: 'slot_4_2',
              slotIndex: 2,
              status: SlotStatus.locked,
              lockedByName: 'Алина',
              lockRemainingTime: '00:48',
            ),
            // Состояние А — Пустой слот
            const SlotModel(
              id: 'slot_4_3',
              slotIndex: 3,
              status: SlotStatus.empty,
            ),
          ],
        );
      }

      // Определяем разнообразный макет и число слотов для каждой страницы
      String layoutType;
      int slotsCount;
      String? headline;
      String? subhead;

      switch (pageNumber) {
        case 1:
          layoutType = 'editorial_quote';
          slotsCount = 2;
          headline = 'GO, BOYS!';
          subhead = '(да, это твой выпускной)';
          break;
        case 2:
          layoutType = 'hero_top_trio_4';
          slotsCount = 4;
          break;
        case 3:
          layoutType = 'split_vertical_2';
          slotsCount = 2;
          break;
        case 5:
          layoutType = 'checkerboard_3';
          slotsCount = 3;
          headline = "LET'S";
          subhead = 'GO';
          break;
        case 6:
          layoutType = 'hero_centered';
          slotsCount = 1;
          break;
        case 7:
          layoutType = 'split_vertical_3';
          slotsCount = 3;
          break;
        case 8:
          layoutType = 'single_full';
          slotsCount = 1;
          break;
        case 9:
          layoutType = 'hero_top_split_bottom_3';
          slotsCount = 3;
          break;
        case 10:
          layoutType = 'split_horizontal_2';
          slotsCount = 2;
          break;
        case 11:
          layoutType = 'split_vertical_2';
          slotsCount = 2;
          break;
        case 12:
          layoutType = 'hero_top_trio_4';
          slotsCount = 4;
          break;
        case 13:
          layoutType = 'editorial_quote';
          slotsCount = 1;
          headline = 'MEMORIES';
          subhead = 'лучшие дни вместе';
          break;
        case 14:
          layoutType = 'hero_centered';
          slotsCount = 1;
          break;
        case 15:
          layoutType = 'checkerboard_3';
          slotsCount = 3;
          headline = 'FOREVER';
          subhead = 'YOUNG';
          break;
        case 16:
          layoutType = 'single_full';
          slotsCount = 1;
          break;
        case 17:
          layoutType = 'split_vertical_3';
          slotsCount = 3;
          break;
        case 18:
          layoutType = 'hero_top_split_bottom_3';
          slotsCount = 3;
          break;
        default:
          layoutType = 'grid_4';
          slotsCount = 4;
          break;
      }

      // Для первых 18 страниц — моковая заполненность
      final isFilledPage = pageNumber <= 18;
      return PageModel(
        pageNumber: pageNumber,
        side: side,
        layoutType: layoutType,
        headline: headline,
        subhead: subhead,
        slots: List.generate(slotsCount, (slotIdx) {
          if (isFilledPage) {
            final photo = poolPhotos[(pageIndex * 2 + slotIdx) % poolPhotos.length];
            return SlotModel(
              id: 'slot_${pageNumber}_$slotIdx',
              slotIndex: slotIdx,
              status: SlotStatus.filled,
              imageUrl: photo.imageUrl,
              caption: 'Кадр #${pageNumber * 4 + slotIdx}',
              authorName: 'добавил ${photo.uploaderName}',
              reactions: {'❤️': (slotIdx + 1) * 2},
            );
          } else {
            return SlotModel(
              id: 'slot_${pageNumber}_$slotIdx',
              slotIndex: slotIdx,
              status: SlotStatus.empty,
            );
          }
        }),
      );
    });
  }
}

