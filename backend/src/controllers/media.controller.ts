import { Response } from 'express';
import { AuthenticatedRequest } from '../middlewares/auth.middleware.js';
import { mediaService } from '../services/media.service.js';
import { io } from '../index.js';

/// Контроллер загрузки медиа (SOLID: SRP, DIP)
export async function uploadMedia(req: AuthenticatedRequest, res: Response) {
  try {
    const userId = req.user?.userId;
    const userName = req.user?.displayName || (req.body?.uploaderName as string) || 'Организатор';
    const { id: albumId } = req.params;

    if (!userId) {
      res.status(401).json({ error: 'Пользователь не авторизован' });
      return;
    }

    if (!req.file) {
      res.status(400).json({ error: 'Файл изображения не загружен' });
      return;
    }

    const media = await mediaService.processAndSaveMedia({
      file: req.file,
      albumId,
      userId,
      userName,
    });

    // Оповещаем участников через сокеты в реальном времени
    io.to(albumId).emit('media:added', {
      albumId,
      media,
    });

    res.status(201).json({
      media,
      message: 'Фотография успешно загружена и оптимизирована',
    });
  } catch (err: any) {
    if (err.message === 'ALBUM_NOT_FOUND') {
      res.status(404).json({ error: 'Альбом не найден' });
      return;
    }
    console.error('Ошибка загрузки медиа:', err);
    res.status(500).json({ error: 'Ошибка при сохранении изображения' });
  }
}
