import { Response } from 'express';
import { AuthenticatedRequest } from '../middlewares/auth.middleware.js';
import { Album, AlbumMember, Page, Slot, MediaPool, SlotReaction, CoverVote, User } from '../models/index.js';
import { createAlbumTransaction } from '../services/album.service.js';
import { io } from '../index.js';

export async function createAlbum(req: AuthenticatedRequest, res: Response) {
  try {
    const userId = req.user?.userId;
    if (!userId) {
      res.status(401).json({ error: 'Пользователь не авторизован' });
      return;
    }

    const title = (req.body.title || req.body.name || '').toString().trim();
    const format = req.body.format || 'vertical_21x30';
    const lamination = req.body.lamination || 'glossy';
    const totalSpreads = req.body.totalSpreads || req.body.spreadsCount || 10;

    if (!title || title.length === 0) {
      res.status(400).json({ error: 'Поле title/name обязательно' });
      return;
    }

    const album = await createAlbumTransaction({
      title,
      hostUserId: userId,
      format,
      lamination,
      totalSpreads: Number(totalSpreads),
    });

    const albumJson = album.toJSON();
    (albumJson as any).name = album.title;
    (albumJson as any).spreadsCount = album.totalSpreads;

    res.status(201).json({
      album: albumJson,
      message: 'Альбом успешно создан со всеми страницами и слотами',
    });
  } catch (err: any) {
    console.error('Ошибка создания альбома:', err);
    res.status(500).json({ error: 'Не удалось создать альбом' });
  }
}

export async function joinAlbum(req: AuthenticatedRequest, res: Response) {
  try {
    const userId = req.user?.userId;
    if (!userId) {
      res.status(401).json({ error: 'Пользователь не авторизован' });
      return;
    }

    const { inviteCode } = req.body;
    if (!inviteCode || typeof inviteCode !== 'string') {
      res.status(400).json({ error: 'Поле inviteCode обязательно' });
      return;
    }

    const cleanCode = inviteCode.replace(/\D/g, '').trim();
    const album = await Album.findOne({
      where: { inviteCode: cleanCode },
    });

    if (!album) {
      res.status(404).json({ error: 'Альбом с таким кодом не найден' });
      return;
    }

    // Проверяем, состоит ли уже пользователь в альбоме
    let member = await AlbumMember.findOne({
      where: { albumId: album.id, userId },
    });

    if (!member) {
      member = await AlbumMember.create({
        albumId: album.id,
        userId,
        role: album.hostUserId === userId ? 'host' : 'editor',
      });
    }

    const albumJson = album.toJSON();
    (albumJson as any).name = album.title;
    (albumJson as any).spreadsCount = album.totalSpreads;

    res.json({
      album: albumJson,
      role: member.role,
      message: 'Вы успешно присоединились к альбому',
    });
  } catch (err: any) {
    console.error('Ошибка присоединения к альбому:', err);
    res.status(500).json({ error: 'Внутренняя ошибка сервера' });
  }
}

export async function getAlbumFull(req: AuthenticatedRequest, res: Response) {
  try {
    const { id } = req.params;

    const album = await Album.findByPk(id, {
      include: [
        {
          model: Page,
          as: 'pages',
          include: [
            {
              model: Slot,
              as: 'slots',
              include: [
                {
                  model: SlotReaction,
                  as: 'reactions',
                },
                {
                  model: MediaPool,
                  as: 'media',
                },
              ],
            },
          ],
        },
        {
          model: MediaPool,
          as: 'mediaPool',
        },
        {
          model: AlbumMember,
          as: 'members',
          include: [
            {
              model: User,
              as: 'user',
              attributes: ['id', 'displayName', 'avatarColor', 'avatarUrl'],
            },
          ],
        },
        {
          model: CoverVote,
          as: 'coverVotes',
        },
      ],
      order: [
        [{ model: Page, as: 'pages' }, 'pageNumber', 'ASC'],
        [{ model: Page, as: 'pages' }, { model: Slot, as: 'slots' }, 'slotIndex', 'ASC'],
      ],
    });

    if (!album) {
      res.status(404).json({ error: 'Альбом не найден' });
      return;
    }

    const albumJson = album.toJSON();
    (albumJson as any).name = album.title;
    (albumJson as any).spreadsCount = album.totalSpreads;

    res.json({ album: albumJson });
  } catch (err: any) {
    console.error('Ошибка получения альбома:', err);
    res.status(500).json({ error: 'Не удалось получить данные альбома' });
  }
}

export async function assignSlotMedia(req: AuthenticatedRequest, res: Response) {
  try {
    const { id: albumId, slotId } = req.params;
    const { mediaId, caption } = req.body;
    const userId = req.user?.userId;
    const displayName = req.user?.displayName || 'Участник';

    const slot = await Slot.findByPk(slotId);
    if (!slot) {
      res.status(404).json({ error: 'Слот не найден' });
      return;
    }

    slot.mediaId = mediaId;
    if (caption !== undefined) slot.caption = caption;
    slot.authorName = displayName;
    slot.lockedByUserId = null;
    slot.lockedByName = null;
    slot.lockedUntil = null;
    await slot.save();

    const updated = await Slot.findByPk(slotId, {
      include: [
        { model: MediaPool, as: 'media' },
        { model: SlotReaction, as: 'reactions' },
      ],
    });

    io.to(albumId).emit('slot:updated', {
      albumId,
      slot: updated,
    });

    res.json({ slot: updated });
  } catch (err: any) {
    console.error('Ошибка назначения фото в слот:', err);
    res.status(500).json({ error: 'Не удалось привязать фото' });
  }
}

export async function clearSlotMedia(req: AuthenticatedRequest, res: Response) {
  try {
    const { id: albumId, slotId } = req.params;

    const slot = await Slot.findByPk(slotId);
    if (!slot) {
      res.status(404).json({ error: 'Слот не найден' });
      return;
    }

    slot.mediaId = null;
    slot.caption = null;
    slot.authorName = null;
    slot.lockedByUserId = null;
    slot.lockedByName = null;
    slot.lockedUntil = null;
    await slot.save();

    io.to(albumId).emit('slot:updated', {
      albumId,
      slot: {
        ...slot.toJSON(),
        media: null,
      },
    });

    res.json({ slot });
  } catch (err: any) {
    console.error('Ошибка очистки слота:', err);
    res.status(500).json({ error: 'Не удалось очистить слот' });
  }
}

export async function updatePageLayout(req: AuthenticatedRequest, res: Response) {
  try {
    const { id: albumId, pageNumber } = req.params;
    const layout = req.body.layoutType || req.body.layout || 'grid_4';

    const page = await Page.findOne({
      where: { albumId, pageNumber: Number(pageNumber) },
    });

    if (!page) {
      res.status(404).json({ error: 'Страница не найдена' });
      return;
    }

    page.layoutType = layout;
    await page.save();

    io.to(albumId).emit('page:updated', {
      albumId,
      pageNumber: Number(pageNumber),
      layoutType: layout,
    });

    res.json({ page });
  } catch (err: any) {
    console.error('Ошибка смены сетки страницы:', err);
    res.status(500).json({ error: 'Не удалось сменить сетку' });
  }
}

export async function getAlbumMedia(req: AuthenticatedRequest, res: Response) {
  try {
    const { id: albumId } = req.params;
    const media = await MediaPool.findAll({
      where: { albumId },
      order: [['createdAt', 'DESC']],
    });
    res.json({ media });
  } catch (err: any) {
    res.status(500).json({ error: 'Не удалось загрузить медиатеку' });
  }
}

export async function createOrder(req: AuthenticatedRequest, res: Response) {
  try {
    const { id: albumId } = req.params;
    const { pickupPointId, pickupPointName, phone, customerName, email, comment } = req.body;

    const album = await Album.findByPk(albumId);
    if (!album) {
      res.status(404).json({ error: 'Альбом не найден' });
      return;
    }

    const orderNumber = `PP-${Date.now().toString().slice(-6)}`;
    album.status = 'ordered';
    await album.save();

    console.log(`📦 [Order Created] Заказ ${orderNumber} для альбома "${album.title}": ${customerName}, ${phone}, ${pickupPointName}`);

    res.status(201).json({
      orderNumber,
      message: 'Заказ успешно создан и отправлен в печать picPac.by',
    });
  } catch (err: any) {
    console.error('Ошибка оформления заказа:', err);
    res.status(500).json({ error: 'Не удалось оформить заказ' });
  }
}

