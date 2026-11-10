import { Server, Socket } from 'socket.io';
import { presenceManager } from './presence.manager.js';
import { slotManager } from './slot.manager.js';
import { Page } from '../models/index.js';

export function setupSocketHandlers(io: Server) {
  io.on('connection', (socket: Socket) => {
    let currentAlbumId: string | null = null;
    let currentUser: { userId: string; displayName: string; avatarColor?: string; avatarUrl?: string | null } | null = null;

    // 1. Вход в комнату альбома (Presence)
    socket.on('room:join', ({ albumId, user }: { albumId: string; user: any }) => {
      if (!albumId || !user?.userId) return;

      currentAlbumId = albumId;
      currentUser = user;
      socket.join(albumId);

      const onlineUsers = presenceManager.userJoined(albumId, socket.id, {
        userId: user.userId,
        displayName: user.displayName,
        avatarColor: user.avatarColor || '#FF4D4D',
        avatarUrl: user.avatarUrl,
      });

      console.log(`👤 [Presence] ${user.displayName} вошел в альбом ${albumId} (Всего онлайн: ${onlineUsers.length})`);

      // Транслируем обновленный список онлайн всем в комнате
      io.to(albumId).emit('presence:update', {
        albumId,
        onlineUsers,
      });
    });

    // 2. Атомарная блокировка слота (Slot Locking)
    socket.on('slot:lock', async ({ albumId, slotId, user }: { albumId: string; slotId: string; user: any }) => {
      try {
        const u = user || currentUser;
        if (!u?.userId) return;

        const updatedSlot = await slotManager.lockSlot(slotId, {
          userId: u.userId,
          displayName: u.displayName,
        });

        console.log(`🔒 [Lock] Слот ${slotId} заблокирован участником ${u.displayName}`);

        // Рассылаем всем участникам в комнате
        io.to(albumId).emit('slot:updated', {
          albumId,
          slot: updatedSlot,
        });
      } catch (err: any) {
        socket.emit('slot:lock_failed', {
          slotId,
          error: err.message || 'Не удалось заблокировать слот',
        });
      }
    });

    // 3. Снятие блокировки слота
    socket.on('slot:unlock', async ({ albumId, slotId, user }: { albumId: string; slotId: string; user: any }) => {
      try {
        const u = user || currentUser;
        if (!u?.userId) return;

        const updatedSlot = await slotManager.unlockSlot(slotId, {
          userId: u.userId,
          displayName: u.displayName,
        });

        if (updatedSlot) {
          console.log(`🔓 [Unlock] Слот ${slotId} разблокирован`);
          io.to(albumId).emit('slot:updated', {
            albumId,
            slot: updatedSlot,
          });
        }
      } catch (err: any) {
        console.error('Ошибка разблокировки слота:', err);
      }
    });

    // 4. Привязка фото из пула к слоту (Механика в 2 тапа)
    socket.on(
      'slot:assign_media',
      async ({
        albumId,
        slotId,
        mediaId,
        caption,
        user,
      }: {
        albumId: string;
        slotId: string;
        mediaId: string;
        caption?: string;
        user: any;
      }) => {
        try {
          const u = user || currentUser;
          if (!u?.userId) return;

          const updatedSlot = await slotManager.assignMedia(
            slotId,
            mediaId,
            { userId: u.userId, displayName: u.displayName },
            caption
          );

          console.log(`📸 [Slot Media] Фото ${mediaId} привязано к слоту ${slotId} автором ${u.displayName}`);

          io.to(albumId).emit('slot:updated', {
            albumId,
            slot: updatedSlot,
          });
        } catch (err: any) {
          socket.emit('slot:assign_failed', {
            slotId,
            error: err.message || 'Ошибка размещения фото',
          });
        }
      }
    );

    // 5. Очистка слота
    socket.on('slot:clear_media', async ({ albumId, slotId }: { albumId: string; slotId: string }) => {
      try {
        const updatedSlot = await slotManager.clearMedia(slotId);
        io.to(albumId).emit('slot:updated', {
          albumId,
          slot: {
            ...updatedSlot.toJSON(),
            media: null,
          },
        });
        console.log(`🗑️ [Slot Clear] Слот ${slotId} очищен`);
      } catch (err: any) {
        console.error('Ошибка очистки слота:', err);
      }
    });

    // 6. Смена сетки страницы (Layout)
    socket.on(
      'page:update_layout',
      async ({ albumId, pageNumber, layout }: { albumId: string; pageNumber: number; layout: string }) => {
        try {
          const page = await Page.findOne({
            where: { albumId, pageNumber },
          });
          if (page) {
            page.layoutType = layout as any;
            await page.save();

            io.to(albumId).emit('page:updated', {
              albumId,
              pageNumber,
              layout,
            });
            console.log(`📐 [Page Layout] Страница ${pageNumber} изменена на ${layout}`);
          }
        } catch (err: any) {
          console.error('Ошибка изменения сетки:', err);
        }
      }
    );

    // 7. Обновление подписи к фото
    socket.on(
      'slot:update_caption',
      async ({ albumId, slotId, caption }: { albumId: string; slotId: string; caption: string }) => {
        try {
          const updatedSlot = await slotManager.updateCaption(slotId, caption);
          io.to(albumId).emit('slot:updated', {
            albumId,
            slot: updatedSlot,
          });
        } catch (err: any) {
          console.error('Ошибка обновления подписи:', err);
        }
      }
    );

    // 6. Быстрые реакции на слот
    socket.on(
      'slot:toggle_reaction',
      async ({
        albumId,
        slotId,
        emoji,
        user,
      }: {
        albumId: string;
        slotId: string;
        emoji: string;
        user: any;
      }) => {
        try {
          const u = user || currentUser;
          if (!u?.userId) return;

          const result = await slotManager.toggleReaction(slotId, emoji, u.userId);

          io.to(albumId).emit('slot:reaction_updated', {
            albumId,
            ...result,
          });
        } catch (err: any) {
          console.error('Ошибка реакции на слот:', err);
        }
      }
    );

    // 7. Голосование за обложку
    socket.on(
      'cover:vote',
      async ({ albumId, mediaId, user }: { albumId: string; mediaId: string; user: any }) => {
        try {
          const u = user || currentUser;
          if (!u?.userId) return;

          const result = await slotManager.voteCover(albumId, mediaId, u.userId);

          io.to(albumId).emit('cover:votes_updated', result);
        } catch (err: any) {
          console.error('Ошибка голосования за обложку:', err);
        }
      }
    );

    // 8. Обработка отключения сокета
    socket.on('disconnect', async () => {
      const leftInfo = presenceManager.userLeft(socket.id);
      if (leftInfo) {
        console.log(`🔌 [Presence] Пользователь покинул альбом ${leftInfo.albumId}`);

        // Автоматическое снятие всех блокировок слотов этого пользователя
        if (leftInfo.leftUser) {
          const unlockedSlots = await slotManager.unlockAllUserSlots(leftInfo.leftUser.userId);
          if (unlockedSlots.length > 0) {
            console.log(`🔓 [Auto-Unlock] Сняты блокировки с ${unlockedSlots.length} слотов`);
          }
        }

        io.to(leftInfo.albumId).emit('presence:update', {
          albumId: leftInfo.albumId,
          onlineUsers: leftInfo.remainingUsers,
        });
      }
    });
  });
}

