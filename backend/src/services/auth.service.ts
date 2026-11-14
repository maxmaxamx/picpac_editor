import { User } from '../models/index.js';
import { generateToken } from '../middlewares/auth.middleware.js';

export const DEFAULT_AVATAR_COLORS = [
  '#FF4D4D', // picPac coral
  '#3B82F6', // blue
  '#10B981', // green
  '#F59E0B', // amber
  '#8B5CF6', // purple
  '#EC4899', // pink
];

export interface GuestLoginResult {
  token: string;
  user: {
    id: string;
    displayName: string;
    avatarColor: string;
    avatarUrl?: string | null;
  };
}

export class AuthService {
  /**
   * Регистрирует или авторизует гостевого пользователя
   */
  async loginGuest(displayName: string, avatarColor?: string): Promise<GuestLoginResult> {
    const trimmedName = displayName.trim();
    if (!trimmedName) {
      throw new Error('Поле displayName обязательно для заполнения');
    }

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

    return {
      token,
      user: {
        id: user.id,
        displayName: user.displayName,
        avatarColor: user.avatarColor,
        avatarUrl: user.avatarUrl,
      },
    };
  }
}

export const authService = new AuthService();
