import { Request, Response } from 'express';
import { authService } from '../services/auth.service.js';

export async function guestLogin(req: Request, res: Response) {
  try {
    const { displayName, avatarColor } = req.body;

    if (!displayName || typeof displayName !== 'string' || displayName.trim().length === 0) {
      res.status(400).json({ error: 'Поле displayName обязательно для заполнения' });
      return;
    }

    const result = await authService.loginGuest(displayName, avatarColor);
    res.status(201).json(result);
  } catch (err: any) {
    console.error('Ошибка при входе гостя:', err);
    res.status(500).json({ error: 'Внутренняя ошибка сервера' });
  }
}
