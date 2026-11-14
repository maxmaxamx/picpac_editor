import 'models.dart';
import 'templates/template_registry.dart';

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

  /// Делегирование реестру шаблонов (SOLID: SRP, OCP)
  static Map<String, dynamic> getPageLayoutForTemplate(String templateId, int pageNumber) {
    return AlbumTemplateRegistry.getPageLayout(templateId, pageNumber);
  }

  static List<PageModel> generatePages({String templateId = 'school_drive'}) {
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

      // Определяем разнообразный макет в соответствии с выбранным шаблоном
      final layoutConfig = getPageLayoutForTemplate(templateId, pageNumber);
      final layoutType = layoutConfig['layout'] as String? ?? 'grid_4';
      final slotsCount = (layoutConfig['slots'] as num?)?.toInt() ?? 4;
      final headline = layoutConfig['headline'] as String?;
      final subhead = layoutConfig['subhead'] as String?;

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

