import { Response } from 'express';
import { AuthenticatedRequest } from '../middlewares/auth.middleware.js';
import { Album, AlbumMember, Page, Slot, MediaPool, SlotReaction, CoverVote, User } from '../models/index.js';
import { createAlbumTransaction } from '../services/album.service.js';

export async function createAlbum(req: AuthenticatedRequest, res: Response) {
  try {
    const userId = req.user?.userId;
    if (!userId) {
      res.status(401).json({ error: 'Пользователь не авторизован' });
      return;
    }

    const { title, format, lamination, totalSpreads } = req.body;

    if (!title || typeof title !== 'string' || title.trim().length === 0) {
      res.status(400).json({ error: 'Поле title обязательно' });
      return;
    }

    const album = await createAlbumTransaction({
      title: title.trim(),
      hostUserId: userId,
      format,
      lamination,
      totalSpreads: totalSpreads ? Number(totalSpreads) : 10,
    });

    res.status(201).json({
      album,
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

    const cleanCode = inviteCode.trim();
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

    res.json({
      album,
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

    res.json({ album });
  } catch (err: any) {
    console.error('Ошибка получения альбома:', err);
    res.status(500).json({ error: 'Не удалось получить данные альбома' });
  }
}

