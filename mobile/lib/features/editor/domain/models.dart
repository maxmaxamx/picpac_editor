enum SlotStatus {
  empty, // Состояние А — Пустой слот
  selected, // Состояние Б — Выбран текущим пользователем
  locked, // Состояние В — Заблокирован другим участником (Realtime Lock)
  filled, // Состояние Г — Заполненный слот
}

class SlotModel {
  final String id;
  final int slotIndex;
  final SlotStatus status;
  final String? imageUrl;
  final String? caption;
  final String? authorName;
  final String? lockedByName;
  final String? lockRemainingTime;
  final Map<String, int> reactions;

  const SlotModel({
    required this.id,
    required this.slotIndex,
    required this.status,
    this.imageUrl,
    this.caption,
    this.authorName,
    this.lockedByName,
    this.lockRemainingTime,
    this.reactions = const {},
  });

  SlotModel copyWith({
    String? id,
    int? slotIndex,
    SlotStatus? status,
    String? imageUrl,
    String? caption,
    String? authorName,
    String? lockedByName,
    String? lockRemainingTime,
    Map<String, int>? reactions,
  }) {
    return SlotModel(
      id: id ?? this.id,
      slotIndex: slotIndex ?? this.slotIndex,
      status: status ?? this.status,
      imageUrl: imageUrl ?? this.imageUrl,
      caption: caption ?? this.caption,
      authorName: authorName ?? this.authorName,
      lockedByName: lockedByName ?? this.lockedByName,
      lockRemainingTime: lockRemainingTime ?? this.lockRemainingTime,
      reactions: reactions ?? this.reactions,
    );
  }
}

class PageModel {
  final int pageNumber;
  final String side; // 'left' | 'right'
  final String layoutType; // 'grid_4', 'single_full', 'hero_centered', 'split_vertical_2', 'split_horizontal_2', 'split_vertical_3', 'hero_top_split_bottom_3', 'hero_top_trio_4', 'editorial_quote', 'checkerboard_3'
  final String? headline; // Дизайнерский заголовок (e.g. "GO, BOYS!", "CLASS OF 2026")
  final String? subhead; // Подзаголовок/цитата (e.g. "(да, это твой выпускной)")
  final List<SlotModel> slots;

  const PageModel({
    required this.pageNumber,
    required this.side,
    required this.slots,
    this.layoutType = 'grid_4',
    this.headline,
    this.subhead,
  });

  PageModel copyWith({
    int? pageNumber,
    String? side,
    String? layoutType,
    String? headline,
    String? subhead,
    List<SlotModel>? slots,
  }) {
    return PageModel(
      pageNumber: pageNumber ?? this.pageNumber,
      side: side ?? this.side,
      layoutType: layoutType ?? this.layoutType,
      headline: headline ?? this.headline,
      subhead: subhead ?? this.subhead,
      slots: slots ?? this.slots,
    );
  }

  int get filledSlotsCount =>
      slots.where((s) => s.status == SlotStatus.filled).length;
}

class MemberModel {
  final String id;
  final String name;
  final String avatarUrl;
  final bool isOnline;

  const MemberModel({
    required this.id,
    required this.name,
    required this.avatarUrl,
    this.isOnline = true,
  });
}

class MediaPoolItem {
  final String id;
  final String imageUrl;
  final String uploaderName;

  const MediaPoolItem({
    required this.id,
    required this.imageUrl,
    required this.uploaderName,
  });
}

