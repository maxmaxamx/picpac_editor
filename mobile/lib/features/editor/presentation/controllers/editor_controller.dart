import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/socket_service.dart';
import '../../domain/mock_data.dart';
import '../../domain/models.dart';

class EditorState {
  final bool isLoading;
  final String? errorMessage;
  final String albumId;
  final String albumTitle;
  final String inviteCode;
  final double aspectRatio;
  final int spreadsCount;
  final List<PageModel> pages;
  final List<MemberModel> members;
  final List<MediaPoolItem> poolPhotos;
  final int currentPageNumber;
  final String? selectedSlotId;
  final bool isSocketConnected;
  final String templateId;
  final String? winningCoverId;
  final Map<String, int> coverVotes;
  final int totalCoverVotes;

  const EditorState({
    this.isLoading = false,
    this.errorMessage,
    this.albumId = '',
    this.albumTitle = 'Выпускной 11-Б • 2026',
    this.inviteCode = '',
    this.aspectRatio = 3.0 / 4.0,
    this.spreadsCount = 10,
    this.pages = const [],
    this.members = const [],
    this.poolPhotos = const [],
    this.currentPageNumber = 0, // Страница 0 — Обложка альбома по умолчанию
    this.selectedSlotId,
    this.isSocketConnected = false,
    this.templateId = 'school_drive',
    this.winningCoverId,
    this.coverVotes = const {},
    this.totalCoverVotes = 0,
  });

  PageModel get currentPage {
    if (currentPageNumber == 0) {
      return const PageModel(pageNumber: 0, side: 'cover', slots: []);
    }
    if (pages.isEmpty) {
      return const PageModel(pageNumber: 1, side: 'left', slots: []);
    }
    return pages.firstWhere(
      (p) => p.pageNumber == currentPageNumber,
      orElse: () => pages.first,
    );
  }

  MediaPoolItem? get winningCoverPhoto {
    if (poolPhotos.isEmpty) return null;
    if (winningCoverId != null) {
      final match = poolPhotos.where((p) => p.id == winningCoverId);
      if (match.isNotEmpty) return match.first;
    }
    if (coverVotes.isNotEmpty) {
      String? topId;
      int topVotes = 0;
      coverVotes.forEach((mId, count) {
        if (count > topVotes) {
          topVotes = count;
          topId = mId;
        }
      });
      if (topId != null) {
        final match = poolPhotos.where((p) => p.id == topId);
        if (match.isNotEmpty) return match.first;
      }
    }
    return poolPhotos.first;
  }

  int get filledPagesCount =>
      pages.where((p) => p.filledSlotsCount == 4).length;

  EditorState copyWith({
    bool? isLoading,
    String? errorMessage,
    String? albumId,
    String? albumTitle,
    String? inviteCode,
    double? aspectRatio,
    int? spreadsCount,
    List<PageModel>? pages,
    List<MemberModel>? members,
    List<MediaPoolItem>? poolPhotos,
    int? currentPageNumber,
    String? selectedSlotId,
    bool clearSelectedSlot = false,
    bool? isSocketConnected,
    String? templateId,
    String? winningCoverId,
    Map<String, int>? coverVotes,
    int? totalCoverVotes,
  }) {
    return EditorState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      albumId: albumId ?? this.albumId,
      albumTitle: albumTitle ?? this.albumTitle,
      inviteCode: inviteCode ?? this.inviteCode,
      aspectRatio: aspectRatio ?? this.aspectRatio,
      spreadsCount: spreadsCount ?? this.spreadsCount,
      pages: pages ?? this.pages,
      members: members ?? this.members,
      poolPhotos: poolPhotos ?? this.poolPhotos,
      currentPageNumber: currentPageNumber ?? this.currentPageNumber,
      selectedSlotId: clearSelectedSlot ? null : (selectedSlotId ?? this.selectedSlotId),
      isSocketConnected: isSocketConnected ?? this.isSocketConnected,
      templateId: templateId ?? this.templateId,
      winningCoverId: winningCoverId ?? this.winningCoverId,
      coverVotes: coverVotes ?? this.coverVotes,
      totalCoverVotes: totalCoverVotes ?? this.totalCoverVotes,
    );
  }
}

class EditorController extends Notifier<EditorState> {
  StreamSubscription? _presenceSub;
  StreamSubscription? _slotUpdatedSub;
  StreamSubscription? _reactionsUpdatedSub;
  StreamSubscription? _coverVotedSub;
  StreamSubscription? _mediaAddedSub;
  StreamSubscription? _pageUpdatedSub;
  StreamSubscription? _connectionSub;

  ApiClient get _apiClient => ref.read(apiClientProvider);
  SocketService get _socketService => ref.read(socketServiceProvider);

  UserProfile? _currentUser;

  @override
  EditorState build() {
    ref.onDispose(() {
      _cancelSubscriptions();
    });
    return const EditorState();
  }

  void _cancelSubscriptions() {
    _presenceSub?.cancel();
    _slotUpdatedSub?.cancel();
    _reactionsUpdatedSub?.cancel();
    _coverVotedSub?.cancel();
    _mediaAddedSub?.cancel();
    _pageUpdatedSub?.cancel();
    _connectionSub?.cancel();
  }

  /// Инициализация с моковыми данными (для автономной работы и тестов)
  void initMock({
    String albumTitle = 'Выпускной 11-Б • 2026',
    String templateId = 'school_drive',
    double aspectRatio = 3.0 / 4.0,
    int spreadsCount = 10,
  }) {
    state = state.copyWith(
      albumTitle: albumTitle,
      templateId: templateId,
      aspectRatio: aspectRatio,
      spreadsCount: spreadsCount,
      pages: MockData.generatePages(),
      members: MockData.activeMembers,
      poolPhotos: MockData.poolPhotos,
      currentPageNumber: 0,
      selectedSlotId: 'slot_4_1',
    );
  }

  /// Загрузка живого альбома с бэкенда и подключение Socket.io Realtime
  Future<void> loadAlbum({
    required String albumId,
    required UserProfile user,
  }) async {
    _currentUser = user;
    state = state.copyWith(isLoading: true, errorMessage: null, albumId: albumId);

    try {
      final albumData = await _apiClient.getAlbumFull(albumId);
      final rawPages = (albumData['pages'] as List?) ?? [];
      final rawMediaPool = (albumData['mediaPool'] as List?) ?? [];
      final rawMembers = (albumData['members'] as List?) ?? [];
      final format = albumData['format'] as String? ?? '21x30';
      final spreadsCount = (albumData['spreadsCount'] ?? albumData['totalSpreads'] as num?)?.toInt() ?? 10;
      final albumName = (albumData['name'] ?? albumData['title']) as String? ?? 'Наш фотоальбом';
      final inviteCode = albumData['inviteCode'] as String? ?? '';

      final double calculatedAspectRatio = format == '20x20' ? 1.0 : (3.0 / 4.0);

      // Маппинг страниц и слотов из БД
      final List<PageModel> mappedPages = rawPages.map((pMap) {
        final pageNum = (pMap['pageNumber'] as num).toInt();
        final side = pMap['side'] as String? ?? 'left';
        final rawSlots = (pMap['slots'] as List?) ?? [];

        final mappedSlots = rawSlots.map((sMap) {
          final slotId = sMap['id'] as String;
          final slotIndex = (sMap['slotIndex'] as num).toInt();
          final media = sMap['media'] as Map<String, dynamic>?;
          final lockedByUserId = sMap['lockedByUserId'] as String?;
          final lockedUntilStr = sMap['lockedUntil'] as String?;

          SlotStatus status = SlotStatus.empty;
          String? imageUrl;
          String? authorName;
          String? lockedByName;

          if (media != null && media['thumbUrl'] != null) {
            status = SlotStatus.filled;
            imageUrl = _apiClient.resolveUrl(media['thumbUrl'] as String);
            authorName = media['uploaderName'] as String? ?? 'Участник';
          } else if (lockedByUserId != null) {
            final lockedUntil = lockedUntilStr != null ? DateTime.tryParse(lockedUntilStr) : null;
            final isStillLocked = lockedUntil == null || lockedUntil.isAfter(DateTime.now());

            if (isStillLocked) {
              if (lockedByUserId == user.userId) {
                status = SlotStatus.selected;
              } else {
                status = SlotStatus.locked;
                lockedByName = sMap['lockedByName'] as String? ?? 'Участник';
              }
            }
          }

          // Реакции на слот
          final rawReactions = (sMap['reactions'] as List?) ?? [];
          final Map<String, int> reactionsMap = {};
          for (final r in rawReactions) {
            final emoji = r['emoji'] as String? ?? '❤️';
            reactionsMap[emoji] = (reactionsMap[emoji] ?? 0) + 1;
          }

          return SlotModel(
            id: slotId,
            slotIndex: slotIndex,
            status: status,
            imageUrl: imageUrl,
            caption: sMap['caption'] as String?,
            authorName: authorName,
            lockedByName: lockedByName,
            reactions: reactionsMap,
          );
        }).toList();

        return PageModel(
          pageNumber: pageNum,
          side: side,
          slots: mappedSlots,
        );
      }).toList();

      // Маппинг пула медиа
      final List<MediaPoolItem> mappedPool = rawMediaPool.map((m) {
        final thumb = m['thumbUrl'] as String? ?? m['originalUrl'] as String?;
        return MediaPoolItem(
          id: m['id'] as String,
          imageUrl: _apiClient.resolveUrl(thumb),
          uploaderName: m['uploaderName'] as String? ?? 'Участник',
        );
      }).toList();

      // Маппинг участников
      final List<MemberModel> mappedMembers = rawMembers.map((m) {
        final u = m['user'] as Map<String, dynamic>? ?? {};
        final name = u['displayName'] as String? ?? 'Участник';
        final avatar = u['avatarUrl'] as String? ?? 'https://i.pravatar.cc/100?u=$name';
        return MemberModel(
          id: (u['id'] as String?) ?? (m['userId'] as String? ?? ''),
          name: name,
          avatarUrl: avatar,
          isOnline: false,
        );
      }).toList();

      final templateId = albumData['templateId'] as String? ?? 'school_drive';
      final winningCoverId = albumData['winningCoverId'] as String?;
      final rawCoverVotes = (albumData['coverVotes'] as List?) ?? [];
      final Map<String, int> coverVotesMap = {};
      for (final v in rawCoverVotes) {
        if (v is Map) {
          final mId = v['mediaId'] as String?;
          if (mId != null) {
            coverVotesMap[mId] = (coverVotesMap[mId] ?? 0) + 1;
          }
        }
      }
      final totalCoverVotes = coverVotesMap.values.fold<int>(0, (sum, count) => sum + count);

      state = state.copyWith(
        isLoading: false,
        albumTitle: albumName,
        templateId: templateId,
        winningCoverId: winningCoverId,
        coverVotes: coverVotesMap,
        totalCoverVotes: totalCoverVotes,
        inviteCode: inviteCode,
        aspectRatio: calculatedAspectRatio,
        spreadsCount: spreadsCount,
        pages: mappedPages.isNotEmpty ? mappedPages : MockData.generatePages(),
        members: mappedMembers.isNotEmpty ? mappedMembers : MockData.activeMembers,
        poolPhotos: mappedPool,
        currentPageNumber: 0,
      );

      // Подключаем Socket.io Realtime
      _setupRealtime(albumId, user);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Ошибка загрузки альбома: $e',
      );
    }
  }

  void _setupRealtime(String albumId, UserProfile user) {
    _cancelSubscriptions();

    _socketService.connect(
      serverUrl: _apiClient.baseUrl,
      albumId: albumId,
      user: user,
    );

    // Слушаем статус подключения
    _connectionSub = _socketService.connectionStateStream.listen((connected) {
      state = state.copyWith(isSocketConnected: connected);
    });

    // Слушаем присутствие участников (Online Presence)
    _presenceSub = _socketService.presenceStream.listen((onlineUsers) {
      final updatedMembers = state.members.map((member) {
        final isOnline = onlineUsers.any((u) => u.userId == member.id);
        return MemberModel(
          id: member.id,
          name: member.name,
          avatarUrl: member.avatarUrl,
          isOnline: isOnline,
        );
      }).toList();

      // Добавляем пользователей, которых еще не было в списке
      for (final online in onlineUsers) {
        if (!updatedMembers.any((m) => m.id == online.userId)) {
          updatedMembers.add(
            MemberModel(
              id: online.userId,
              name: online.displayName,
              avatarUrl: online.avatarUrl ?? 'https://i.pravatar.cc/100?u=${online.displayName}',
              isOnline: true,
            ),
          );
        }
      }

      state = state.copyWith(members: updatedMembers);
    });

    // Слушаем обновление слотов (Lock, Unlock, Assign, Caption)
    _slotUpdatedSub = _socketService.slotUpdatedStream.listen((slotData) {
      _applySlotUpdate(slotData);
    });

    // Слушаем новые фото в пуле (Media added)
    _mediaAddedSub = _socketService.mediaAddedStream.listen((mediaData) {
      final thumb = mediaData['thumbUrl'] as String? ?? mediaData['originalUrl'] as String?;
      final newItem = MediaPoolItem(
        id: mediaData['id'] as String,
        imageUrl: _apiClient.resolveUrl(thumb),
        uploaderName: mediaData['uploaderName'] as String? ?? 'Участник',
      );

      // Добавляем новое фото в начало пула
      state = state.copyWith(
        poolPhotos: [newItem, ...state.poolPhotos.where((p) => p.id != newItem.id)],
      );
    });

    // Слушаем изменение сетки страниц от других участников
    _pageUpdatedSub = _socketService.pageUpdatedStream.listen((pageData) {
      final pageNum = (pageData['pageNumber'] as num?)?.toInt();
      final layout = pageData['layout'] as String? ?? pageData['layoutType'] as String?;
      if (pageNum != null && layout != null) {
        final slotsCount = layout == 'single' ? 1 : (layout == 'split_2' ? 2 : 4);
        _applyPageLayoutLocal(pageNum, slotsCount);
      }
    });

    // Слушаем обновление голосования за обложку
    _coverVotedSub = _socketService.coverVotedStream.listen((data) {
      final rawVotes = data['votes'];
      final winningId = data['winningCoverId'] as String?;
      final Map<String, int> votesMap = {};
      if (rawVotes is Map) {
        rawVotes.forEach((key, val) {
          if (val is num) {
            votesMap[key.toString()] = val.toInt();
          }
        });
      }
      final total = votesMap.values.fold<int>(0, (sum, c) => sum + c);
      state = state.copyWith(
        coverVotes: votesMap.isNotEmpty ? votesMap : state.coverVotes,
        totalCoverVotes: total > 0 ? total : state.totalCoverVotes,
        winningCoverId: winningId ?? state.winningCoverId,
      );
    });
  }

  void _applySlotUpdate(Map<String, dynamic> slotData) {
    final slotId = slotData['id'] as String?;
    if (slotId == null) return;

    final media = slotData['media'] as Map<String, dynamic>?;
    final lockedByUserId = slotData['lockedByUserId'] as String?;
    final lockedByName = slotData['lockedByName'] as String?;
    final caption = slotData['caption'] as String?;

    final currentUserId = _currentUser?.userId;

    final updatedPages = state.pages.map((page) {
      final slotIndex = page.slots.indexWhere((s) => s.id == slotId);
      if (slotIndex == -1) return page;

      final oldSlot = page.slots[slotIndex];
      SlotStatus newStatus = SlotStatus.empty;
      String? imageUrl = oldSlot.imageUrl;
      String? authorName = oldSlot.authorName;

      if (media != null && (media['thumbUrl'] != null || media['originalUrl'] != null)) {
        newStatus = SlotStatus.filled;
        final rawUrl = media['thumbUrl'] as String? ?? media['originalUrl'] as String?;
        imageUrl = _apiClient.resolveUrl(rawUrl);
        authorName = media['uploaderName'] as String? ?? 'Участник';
      } else if (lockedByUserId != null) {
        if (lockedByUserId == currentUserId) {
          newStatus = SlotStatus.selected;
        } else {
          newStatus = SlotStatus.locked;
        }
      }

      final updatedSlot = oldSlot.copyWith(
        status: newStatus,
        imageUrl: imageUrl,
        authorName: authorName,
        lockedByName: lockedByName,
        caption: caption ?? oldSlot.caption,
      );

      final newSlots = List<SlotModel>.from(page.slots);
      newSlots[slotIndex] = updatedSlot;

      return PageModel(
        pageNumber: page.pageNumber,
        side: page.side,
        slots: newSlots,
      );
    }).toList();

    state = state.copyWith(pages: updatedPages);
  }

  void selectPage(int pageNumber) {
    if (state.selectedSlotId != null) {
      // Освобождаем блокировку при уходе со страницы
      _socketService.unlockSlot(state.selectedSlotId!);
    }
    state = state.copyWith(
      currentPageNumber: pageNumber,
      clearSelectedSlot: true,
    );
  }

  void onSlotTap(SlotModel slot) {
    if (slot.status == SlotStatus.locked) {
      return;
    }

    if (slot.status == SlotStatus.filled) {
      return;
    }

    // Если был выбран другой слот, разблокируем его
    if (state.selectedSlotId != null && state.selectedSlotId != slot.id) {
      _socketService.unlockSlot(state.selectedSlotId!);
    }

    final isAlreadySelected = state.selectedSlotId == slot.id;

    if (isAlreadySelected) {
      // Снимаем выбор
      _socketService.unlockSlot(slot.id);
      _updateSlotLocalStatus(slot.id, SlotStatus.empty);
      state = state.copyWith(clearSelectedSlot: true);
    } else {
      // Выбираем и блокируем слот (60 секунд таймер на бэкенде)
      _socketService.lockSlot(slot.id);
      _updateSlotLocalStatus(slot.id, SlotStatus.selected);
      state = state.copyWith(selectedSlotId: slot.id);
    }
  }

  void assignPhotoToSlot(MediaPoolItem photo) {
    final selectedId = state.selectedSlotId;
    if (selectedId == null) return;

    // 1. WebSocket sync
    _socketService.assignMedia(
      slotId: selectedId,
      mediaId: photo.id,
      caption: 'Фото из пула',
    );

    // 2. HTTP sync
    if (state.albumId.isNotEmpty) {
      _apiClient
          .assignSlotMedia(
            albumId: state.albumId,
            slotId: selectedId,
            mediaId: photo.id,
            caption: 'Фото из пула',
          )
          .catchError((_) => <String, dynamic>{});
    }

    // 3. Оптимистичное локальное обновление
    _updateSlotOptimisticAssigned(selectedId, photo);
    state = state.copyWith(clearSelectedSlot: true);
  }

  void updateCaption(String slotId, String newCaption) {
    _socketService.updateCaption(slotId: slotId, caption: newCaption);
    final updatedPages = state.pages.map((p) {
      return PageModel(
        pageNumber: p.pageNumber,
        side: p.side,
        slots: p.slots.map((s) {
          if (s.id == slotId) return s.copyWith(caption: newCaption);
          return s;
        }).toList(),
      );
    }).toList();
    state = state.copyWith(pages: updatedPages);
  }

  void toggleReaction(String slotId, String emoji) {
    _socketService.toggleReaction(slotId: slotId, emoji: emoji);
    // Локальный инкремент
    final updatedPages = state.pages.map((p) {
      return PageModel(
        pageNumber: p.pageNumber,
        side: p.side,
        slots: p.slots.map((s) {
          if (s.id == slotId) {
            final reactions = Map<String, int>.from(s.reactions);
            reactions[emoji] = (reactions[emoji] ?? 0) + 1;
            return s.copyWith(reactions: reactions);
          }
          return s;
        }).toList(),
      );
    }).toList();
    state = state.copyWith(pages: updatedPages);
  }


  void clearSlot(String slotId) {
    // 1. WebSocket sync
    _socketService.clearMedia(slotId);

    // 2. HTTP sync
    if (state.albumId.isNotEmpty) {
      _apiClient.clearSlotMedia(albumId: state.albumId, slotId: slotId).catchError((_) {});
    }

    // 3. Local optimistic update
    final updatedPages = state.pages.map((p) {
      return PageModel(
        pageNumber: p.pageNumber,
        side: p.side,
        slots: p.slots.map((s) {
          if (s.id == slotId) {
            return SlotModel(
              id: s.id,
              slotIndex: s.slotIndex,
              status: SlotStatus.empty,
              imageUrl: null,
              caption: null,
              authorName: null,
              lockedByName: null,
              reactions: const {},
            );
          }
          return s;
        }).toList(),
      );
    }).toList();

    state = state.copyWith(
      pages: updatedPages,
      clearSelectedSlot: state.selectedSlotId == slotId,
    );
  }

  void setPageLayout(int pageNumber, int slotsCount) {
    final targetCount = slotsCount.clamp(1, 4);
    final layoutType = targetCount == 1 ? 'single' : (targetCount == 2 ? 'split_2' : 'grid_4');

    // 1. WebSocket sync
    _socketService.updatePageLayout(
      pageNumber: pageNumber,
      layout: layoutType,
    );

    // 2. HTTP sync
    if (state.albumId.isNotEmpty) {
      _apiClient
          .updatePageLayout(
            albumId: state.albumId,
            pageNumber: pageNumber,
            layoutType: layoutType,
          )
          .catchError((_) => <String, dynamic>{});
    }

    // 3. Local update
    _applyPageLayoutLocal(pageNumber, targetCount);
  }

  void _applyPageLayoutLocal(int pageNumber, int targetCount) {
    final updatedPages = state.pages.map((p) {
      if (p.pageNumber != pageNumber) return p;

      final currentSlots = p.slots;
      final List<SlotModel> newSlots = [];

      for (int i = 0; i < targetCount; i++) {
        if (i < currentSlots.length) {
          newSlots.add(currentSlots[i].copyWith(slotIndex: i));
        } else {
          newSlots.add(
            SlotModel(
              id: 'slot_${pageNumber}_${i + 1}',
              slotIndex: i,
              status: SlotStatus.empty,
            ),
          );
        }
      }

      return PageModel(
        pageNumber: p.pageNumber,
        side: p.side,
        slots: newSlots,
      );
    }).toList();

    state = state.copyWith(pages: updatedPages);
  }

  Future<void> addCustomPhoto({
    required String imageUrl,
    required String uploaderName,
    List<int>? fileBytes,
    String? fileName,
  }) async {
    if (fileBytes != null && fileName != null && state.albumId.isNotEmpty) {
      try {
        final mediaData = await _apiClient.uploadMedia(
          albumId: state.albumId,
          fileBytes: fileBytes,
          fileName: fileName,
        );
        final thumb = mediaData['thumbUrl'] as String? ?? mediaData['originalUrl'] as String?;
        final uploadedItem = MediaPoolItem(
          id: mediaData['id'] as String,
          imageUrl: _apiClient.resolveUrl(thumb),
          uploaderName: mediaData['uploaderName'] as String? ?? uploaderName,
        );
        state = state.copyWith(
          poolPhotos: [uploadedItem, ...state.poolPhotos.where((p) => p.id != uploadedItem.id)],
        );
        return;
      } catch (e) {
        // Fallback to local
      }
    }

    final newItem = MediaPoolItem(
      id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
      imageUrl: imageUrl,
      uploaderName: uploaderName,
    );

    state = state.copyWith(
      poolPhotos: [newItem, ...state.poolPhotos.where((p) => p.id != newItem.id)],
    );
  }

  Future<void> uploadPhoto({
    required List<int> fileBytes,
    required String fileName,
  }) async {
    if (state.albumId.isEmpty) return;
    try {
      await _apiClient.uploadMedia(
        albumId: state.albumId,
        fileBytes: fileBytes,
        fileName: fileName,
      );
    } catch (e) {
      state = state.copyWith(errorMessage: 'Ошибка загрузки фото: $e');
    }
  }

  /// Голосование за фото обложки альбома
  void voteCover(String mediaId) {
    final currentCount = state.coverVotes[mediaId] ?? 0;
    final updatedMap = Map<String, int>.from(state.coverVotes);
    updatedMap[mediaId] = currentCount + 1;
    final newTotal = state.totalCoverVotes + 1;

    String? newLeader = state.winningCoverId;
    int maxV = 0;
    updatedMap.forEach((mId, cnt) {
      if (cnt > maxV) {
        maxV = cnt;
        newLeader = mId;
      }
    });

    state = state.copyWith(
      coverVotes: updatedMap,
      totalCoverVotes: newTotal,
      winningCoverId: newLeader,
    );

    _socketService.voteCover(mediaId: mediaId);
  }

  void _updateSlotLocalStatus(String slotId, SlotStatus status) {
    final updatedPages = state.pages.map((p) {
      return PageModel(
        pageNumber: p.pageNumber,
        side: p.side,
        slots: p.slots.map((s) {
          if (s.id == slotId) return s.copyWith(status: status);
          if (status == SlotStatus.selected && s.status == SlotStatus.selected) {
            return s.copyWith(status: SlotStatus.empty);
          }
          return s;
        }).toList(),
      );
    }).toList();
    state = state.copyWith(pages: updatedPages);
  }

  void _updateSlotOptimisticAssigned(String slotId, MediaPoolItem photo) {
    final updatedPages = state.pages.map((p) {
      return PageModel(
        pageNumber: p.pageNumber,
        side: p.side,
        slots: p.slots.map((s) {
          if (s.id == slotId) {
            return s.copyWith(
              status: SlotStatus.filled,
              imageUrl: photo.imageUrl,
              authorName: 'добавил ${photo.uploaderName}',
              caption: 'Фото из пула',
              reactions: {'❤️': 1},
            );
          }
          return s;
        }).toList(),
      );
    }).toList();
    state = state.copyWith(pages: updatedPages);
  }
}

final editorControllerProvider = NotifierProvider<EditorController, EditorState>(() {
  return EditorController();
});

