import { Response } from 'express';
import path from 'path';
import fs from 'fs';
import sharp from 'sharp';
import { v4 as uuidv4 } from 'uuid';
import { AuthenticatedRequest } from '../middlewares/auth.middleware.js';
import { MediaPool, Album } from '../models/index.js';
import { io } from '../index.js';

export async function uploadMedia(req: AuthenticatedRequest, res: Response) {
  try {
    const userId = req.user?.userId;
    const userName = req.user?.displayName || 'Участник';
    const { id: albumId } = req.params;

    if (!userId) {
      res.status(401).json({ error: 'Пользователь не авторизован' });
      return;
    }

    if (!req.file) {
      res.status(400).json({ error: 'Файл изображения не загружен' });
      return;
    }

    const album = await Album.findByPk(albumId);
    if (!album) {
      res.status(404).json({ error: 'Альбом не найден' });
      return;
    }

    const fileId = uuidv4();
    const originalExt = path.extname(req.file.originalname) || '.jpg';
    const originalFileName = `${fileId}_orig${originalExt}`;
    const thumbFileName = `${fileId}_thumb.webp`;

    const uploadsDir = path.resolve(process.cwd(), 'uploads');
    const originalsDir = path.join(uploadsDir, 'originals');
    const thumbsDir = path.join(uploadsDir, 'thumbs');

    if (!fs.existsSync(originalsDir)) fs.mkdirSync(originalsDir, { recursive: true });
    if (!fs.existsSync(thumbsDir)) fs.mkdirSync(thumbsDir, { recursive: true });

    const originalFilePath = path.join(originalsDir, originalFileName);
    const thumbFilePath = path.join(thumbsDir, thumbFileName);

    // 1. Сохраняем оригинал
    await fs.promises.writeFile(originalFilePath, req.file.buffer);

    // 2. Генерируем оптимизированное легкое WebP превью (600x600 max, 80% качество) через sharp
    const metadata = await sharp(req.file.buffer)
      .resize({ width: 600, height: 600, fit: 'inside', withoutEnlargement: true })
      .webp({ quality: 80 })
      .toFile(thumbFilePath);

    const originalUrl = `/uploads/originals/${originalFileName}`;
    const thumbUrl = `/uploads/thumbs/${thumbFileName}`;

    // 3. Запись в базу данных в MediaPool
    const media = await MediaPool.create({
      id: fileId,
      albumId,
      uploaderId: userId,
      uploaderName: userName,
      originalUrl,
      thumbUrl,
      width: metadata.width || null,
      height: metadata.height || null,
    });

    console.log(`🖼️ [Media Upload] Фото загружено в альбом ${albumId}: ${media.id} (WebP: ${metadata.size} байт)`);

    // 4. Оповещаем всех участников комнаты через WebSocket (Realtime sync)
    io.to(albumId).emit('media:added', {
      albumId,
      media,
    });

    res.status(201).json({
      media,
      message: 'Фотография успешно загружена и оптимизирована',
    });
  } catch (err: any) {
    console.error('Ошибка загрузки медиа:', err);
    res.status(500).json({ error: 'Ошибка при сохранении изображения' });
  }
}

