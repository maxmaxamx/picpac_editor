import { Response } from 'express';
import { AuthenticatedRequest } from '../middlewares/auth.middleware.js';
import {
  createAlbumTransaction,
  joinAlbumService,
  getAlbumFullService,
  assignSlotMediaService,
  clearSlotMediaService,
  updatePageLayoutService,
  getAlbumMediaService,
} from '../services/album.service.js';
import { orderService } from '../services/order.service.js';
import { io } from '../index.js';

/// Контроллер работы с альбомами (SOLID: SRP, DIP)
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
    const templateId = req.body.templateId || 'school_drive';

    if (!title || title.length === 0) {
      res.status(400).json({ error: 'Поле title/name обязательно' });
      return;
    }

    const album = await createAlbumTransaction({
      title,
      hostUserId: userId,
      templateId,
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

    const result = await joinAlbumService(inviteCode, userId);
    res.json({
      album: result.album,
      role: result.role,
      message: 'Вы успешно присоединились к альбому',
    });
  } catch (err: any) {
    if (err.message === 'ALBUM_NOT_FOUND') {
      res.status(404).json({ error: 'Альбом с таким кодом не найден' });
      return;
    }
    console.error('Ошибка присоединения к альбому:', err);
    res.status(500).json({ error: 'Внутренняя ошибка сервера' });
  }
}

export async function getAlbumFull(req: AuthenticatedRequest, res: Response) {
  try {
    const { id } = req.params;
    const albumJson = await getAlbumFullService(id);
    res.json({ album: albumJson });
  } catch (err: any) {
    if (err.message === 'ALBUM_NOT_FOUND') {
      res.status(404).json({ error: 'Альбом не найден' });
      return;
    }
    console.error('Ошибка получения альбома:', err);
    res.status(500).json({ error: 'Не удалось получить данные альбома' });
  }
}

export async function assignSlotMedia(req: AuthenticatedRequest, res: Response) {
  try {
    const { id: albumId, slotId } = req.params;
    const { mediaId, caption } = req.body;
    const displayName = req.user?.displayName || 'Организатор';

    const updated = await assignSlotMediaService(slotId, mediaId, caption, displayName);

    io.to(albumId).emit('slot:updated', {
      albumId,
      slot: updated,
    });

    res.json({ slot: updated });
  } catch (err: any) {
    if (err.message === 'SLOT_NOT_FOUND') {
      res.status(404).json({ error: 'Слот не найден' });
      return;
    }
    console.error('Ошибка назначения фото в слот:', err);
    res.status(500).json({ error: 'Не удалось привязать фото' });
  }
}

export async function clearSlotMedia(req: AuthenticatedRequest, res: Response) {
  try {
    const { id: albumId, slotId } = req.params;

    const slot = await clearSlotMediaService(slotId);

    io.to(albumId).emit('slot:updated', {
      albumId,
      slot: {
        ...slot.toJSON(),
        media: null,
      },
    });

    res.json({ slot });
  } catch (err: any) {
    if (err.message === 'SLOT_NOT_FOUND') {
      res.status(404).json({ error: 'Слот не найден' });
      return;
    }
    console.error('Ошибка очистки слота:', err);
    res.status(500).json({ error: 'Не удалось очистить слот' });
  }
}

export async function updatePageLayout(req: AuthenticatedRequest, res: Response) {
  try {
    const { id: albumId, pageNumber } = req.params;
    const layout = req.body.layoutType || req.body.layout || 'grid_4';

    const page = await updatePageLayoutService(albumId, Number(pageNumber), layout);

    io.to(albumId).emit('page:updated', {
      albumId,
      pageNumber: Number(pageNumber),
      layoutType: layout,
    });

    res.json({ page });
  } catch (err: any) {
    if (err.message === 'PAGE_NOT_FOUND') {
      res.status(404).json({ error: 'Страница не найдена' });
      return;
    }
    console.error('Ошибка смены сетки страницы:', err);
    res.status(500).json({ error: 'Не удалось сменить сетку' });
  }
}

export async function getAlbumMedia(req: AuthenticatedRequest, res: Response) {
  try {
    const { id: albumId } = req.params;
    const media = await getAlbumMediaService(albumId);
    res.json({ media });
  } catch (err: any) {
    res.status(500).json({ error: 'Не удалось загрузить медиатеку' });
  }
}

export async function createOrder(req: AuthenticatedRequest, res: Response) {
  try {
    const { id: albumId } = req.params;
    const { pickupPointId, pickupPointName, phone, customerName, email, comment } = req.body;

    const result = await orderService.createOrder({
      albumId,
      pickupPointId,
      pickupPointName,
      phone,
      customerName,
      email,
      comment,
    });

    res.status(201).json({
      orderNumber: result.orderNumber,
      message: 'Заказ успешно создан и отправлен в печать picPac.by',
    });
  } catch (err: any) {
    if (err.message === 'ALBUM_NOT_FOUND') {
      res.status(404).json({ error: 'Альбом не найден' });
      return;
    }
    console.error('Ошибка оформления заказа:', err);
    res.status(500).json({ error: 'Не удалось оформить заказ' });
  }
}
