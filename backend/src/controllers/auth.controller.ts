import { Request, Response } from 'express';
import { User } from '../models/index.js';
import { generateToken } from '../middlewares/auth.middleware.js';

// Палитра приятных цветов аватарок для участников
const DEFAULT_AVATAR_COLORS = [
  '#FF4D4D', // picPac coral
  '#3B82F6', // blue
  '#10B981', // green
  '#F59E0B', // amber
  '#8B5CF6', // purple
  '#EC4899', // pink
];

export async function guestLogin(req: Request, res: Response) {
  try {
    const { displayName, avatarColor } = req.body;

    if (!displayName || typeof displayName !== 'string' || displayName.trim().length === 0) {
      res.status(400).json({ error: 'Поле displayName обязательно для заполнения' });
      return;
    }

    const trimmedName = displayName.trim();
    const color =
      avatarColor ||
      DEFAULT_AVATAR_COLORS[Math.floor(Math.random() * DEFAULT_AVATAR_COLORS.length)];

    const user = await User.create({
      displayName: trimmedName,
      avatarColor: color,
    });

    const token = generateToken({
      userId: user.id,
      displayName: user.displayName,
    });

    res.status(201).json({
      token,
      user: {
        id: user.id,
        displayName: user.displayName,
        avatarColor: user.avatarColor,
        avatarUrl: user.avatarUrl,
      },
    });
  } catch (err: any) {
    console.error('Ошибка при входе гостя:', err);
    res.status(500).json({ error: 'Внутренняя ошибка сервера' });
  }
}

