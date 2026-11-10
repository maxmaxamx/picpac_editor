export interface OnlineUser {
  userId: string;
  displayName: string;
  avatarColor: string;
  avatarUrl?: string | null;
  socketId: string;
}

class PresenceManager {
  // albumId -> Map<socketId, OnlineUser>
  private rooms: Map<string, Map<string, OnlineUser>> = new Map();

  public userJoined(albumId: string, socketId: string, user: Omit<OnlineUser, 'socketId'>): OnlineUser[] {
    if (!this.rooms.has(albumId)) {
      this.rooms.set(albumId, new Map());
    }

    const room = this.rooms.get(albumId)!;
    room.set(socketId, { ...user, socketId });

    return this.getOnlineUsers(albumId);
  }

  public userLeft(socketId: string): { albumId: string; remainingUsers: OnlineUser[]; leftUser?: OnlineUser } | null {
    for (const [albumId, room] of this.rooms.entries()) {
      if (room.has(socketId)) {
        const leftUser = room.get(socketId);
        room.delete(socketId);

        if (room.size === 0) {
          this.rooms.delete(albumId);
        }

        return {
          albumId,
          remainingUsers: this.getOnlineUsers(albumId),
          leftUser,
        };
      }
    }
    return null;
  }

  public getOnlineUsers(albumId: string): OnlineUser[] {
    const room = this.rooms.get(albumId);
    if (!room) return [];

    // Возвращаем уникальных пользователей (если открыто несколько вкладок одним юзером)
    const unique = new Map<string, OnlineUser>();
    for (const user of room.values()) {
      if (!unique.has(user.userId)) {
        unique.set(user.userId, user);
      }
    }
    return Array.from(unique.values());
  }
}

export const presenceManager = new PresenceManager();

