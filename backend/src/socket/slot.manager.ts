import { Op } from 'sequelize';
import { Slot, SlotReaction, CoverVote, MediaPool } from '../models/index.js';

export interface UserContext {
  userId: string;
  displayName: string;
}

export class SlotManager {
  /**
   * Атомарная блокировка слота на 60 секунд (Фаза 3.2)
   */
  public async lockSlot(slotId: string, user: UserContext) {
    const slot = await Slot.findByPk(slotId);
    if (!slot) {
      throw new Error('Слот не найден');
    }

    const now = new Date();

    // Если слот уже заблокирован ДРУГИМ пользователем и время блокировки не истекло
    if (
      slot.lockedByUserId &&
      slot.lockedByUserId !== user.userId &&
      slot.lockedUntil &&
      slot.lockedUntil > now
    ) {
      const remainingSeconds = Math.ceil((slot.lockedUntil.getTime() - now.getTime()) / 1000);
      throw new Error(
        `Слот уже редактирует ${slot.lockedByName || 'другой участник'} (осталось ${remainingSeconds} сек)`
      );
    }

    // Блокируем на 60 секунд
    const lockedUntil = new Date(Date.now() + 60 * 1000);
    slot.lockedByUserId = user.userId;
    slot.lockedByName = user.displayName;
    slot.lockedUntil = lockedUntil;
    await slot.save();

    return slot;
  }

  /**
   * Добровольное снятие блокировки слота
   */
  public async unlockSlot(slotId: string, user: UserContext) {
    const slot = await Slot.findByPk(slotId);
    if (!slot) return null;

    if (slot.lockedByUserId === user.userId) {
      slot.lockedByUserId = null;
      slot.lockedByName = null;
      slot.lockedUntil = null;
      await slot.save();
    }

    return slot;
  }

  /**
   * Снятие всех блокировок пользователя при дисконнекте
   */
  public async unlockAllUserSlots(userId: string): Promise<string[]> {
    const slots = await Slot.findAll({
      where: {
        lockedByUserId: userId,
      },
    });

    const updatedSlotIds: string[] = [];
    for (const slot of slots) {
      slot.lockedByUserId = null;
      slot.lockedByName = null;
      slot.lockedUntil = null;
      await slot.save();
      updatedSlotIds.push(slot.id);
    }

    return updatedSlotIds;
  }

  /**
   * Привязка фото из пула к слоту (Механика в 2 тапа)
   */
  public async assignMedia(
    slotId: string,
    mediaId: string,
    user: UserContext,
    caption?: string
  ) {
    const slot = await Slot.findByPk(slotId);
    if (!slot) {
      throw new Error('Слот не найден');
    }

    slot.mediaId = mediaId;
    if (caption !== undefined) {
      slot.caption = caption;
    }
    slot.authorName = user.displayName;
    // Снимаем блокировку после успешного размещения
    slot.lockedByUserId = null;
    slot.lockedByName = null;
    slot.lockedUntil = null;
    await slot.save();

    // Загружаем слот с привязанным фото
    return await Slot.findByPk(slotId, {
      include: [
        { model: MediaPool, as: 'media' },
        { model: SlotReaction, as: 'reactions' },
      ],
    });
  }

  /**
   * Очистка фото и данных со слота
   */
  public async clearMedia(slotId: string) {
    const slot = await Slot.findByPk(slotId);
    if (!slot) {
      throw new Error('Слот не найден');
    }

    slot.mediaId = null;
    slot.caption = null;
    slot.authorName = null;
    slot.lockedByUserId = null;
    slot.lockedByName = null;
    slot.lockedUntil = null;
    await slot.save();

    return slot;
  }

  /**
   * Обновление подписи к фото
   */
  public async updateCaption(slotId: string, caption: string) {
    const slot = await Slot.findByPk(slotId);
    if (!slot) throw new Error('Слот не найден');

    slot.caption = caption.trim().slice(0, 50);
    await slot.save();
    return slot;
  }

  /**
   * Добавление / удаление быстрой реакции
   */
  public async toggleReaction(slotId: string, emoji: string, userId: string) {
    const existing = await SlotReaction.findOne({
      where: { slotId, userId, emoji },
    });

    if (existing) {
      await existing.destroy();
    } else {
      await SlotReaction.create({
        slotId,
        userId,
        emoji,
      });
    }

    // Возвращаем актуальные реакции слота
    const reactions = await SlotReaction.findAll({ where: { slotId } });
    const counts: Record<string, number> = {};
    for (const r of reactions) {
      counts[r.emoji] = (counts[r.emoji] || 0) + 1;
    }

    return { slotId, reactions: counts };
  }

  /**
   * Голосование за обложку
   */
  public async voteCover(albumId: string, mediaId: string, userId: string) {
    const existing = await CoverVote.findOne({
      where: { albumId, userId },
    });

    if (existing) {
      existing.mediaId = mediaId;
      await existing.save();
    } else {
      await CoverVote.create({
        albumId,
        mediaId,
        userId,
      });
    }

    // Подсчет голосов по кандидатам
    const allVotes = await CoverVote.findAll({ where: { albumId } });
    const voteCounts: Record<string, number> = {};
    for (const v of allVotes) {
      voteCounts[v.mediaId] = (voteCounts[v.mediaId] || 0) + 1;
    }

    return { albumId, votes: voteCounts, totalVotes: allVotes.length };
  }
}

export const slotManager = new SlotManager();

