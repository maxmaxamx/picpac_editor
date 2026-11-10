import { Transaction } from 'sequelize';
import { v4 as uuidv4 } from 'uuid';
import { sequelize, Album, AlbumMember, Page, Slot, MediaPool } from '../models/index.js';

export function generateInviteCode(): string {
  // 6-значный цифровой код для удобного ввода с мобильной клавиатуры
  const min = 100000;
  const max = 999999;
  return Math.floor(min + Math.random() * (max - min + 1)).toString();
}

export interface CreateAlbumDTO {
  title: string;
  hostUserId: string;
  templateId?: string;
  format?: 'square_20x20' | 'vertical_21x30';
  lamination?: 'glossy' | 'grainy';
  totalSpreads?: number;
}

export async function createAlbumTransaction(dto: CreateAlbumDTO) {
  const totalSpreads = dto.totalSpreads || 10;
  const totalPages = totalSpreads * 2;
  const inviteCode = generateInviteCode();

  return await sequelize.transaction(async (t: Transaction) => {
    // 1. Создание альбома
    const album = await Album.create(
      {
        inviteCode,
        title: dto.title,
        hostUserId: dto.hostUserId,
        templateId: dto.templateId || 'school_drive',
        format: dto.format || 'vertical_21x30',
        lamination: dto.lamination || 'glossy',
        totalSpreads,
        totalPages,
        status: 'draft',
        copiesCount: 1,
      },
      { transaction: t }
    );

    // 2. Добавление хоста в участники
    await AlbumMember.create(
      {
        albumId: album.id,
        userId: dto.hostUserId,
        role: 'host',
      },
      { transaction: t }
    );

    // 3. Автоматическая генерация разворотов, страниц и слотов
    for (let spread = 1; spread <= totalSpreads; spread++) {
      // Левая страница разворота
      const leftPageNum = spread * 2 - 1;
      const leftPage = await Page.create(
        {
          albumId: album.id,
          pageNumber: leftPageNum,
          side: 'left',
          layoutType: 'grid_4',
        },
        { transaction: t }
      );

      // 4 слота для левой страницы
      for (let s = 0; s < 4; s++) {
        await Slot.create(
          {
            pageId: leftPage.id,
            slotIndex: s,
          },
          { transaction: t }
        );
      }

      // Правая страница разворота
      const rightPageNum = spread * 2;
      const rightPage = await Page.create(
        {
          albumId: album.id,
          pageNumber: rightPageNum,
          side: 'right',
          layoutType: 'grid_4',
        },
        { transaction: t }
      );

      // 4 слота для правой страницы
      for (let s = 0; s < 4; s++) {
        await Slot.create(
          {
            pageId: rightPage.id,
            slotIndex: s,
          },
          { transaction: t }
        );
      }
    }

    // 4. Добавление стартовых качественных фотографий в общий пул альбома (MediaPool)
    const starterPhotos = [
      {
        id: uuidv4(),
        albumId: album.id,
        uploaderId: dto.hostUserId,
        uploaderName: 'Участник',
        originalUrl: 'https://images.unsplash.com/photo-1544717305-2782549b5136?w=1200&fit=crop',
        thumbUrl: 'https://images.unsplash.com/photo-1544717305-2782549b5136?w=600&fit=crop',
        width: 1200,
        height: 800,
      },
      {
        id: uuidv4(),
        albumId: album.id,
        uploaderId: dto.hostUserId,
        uploaderName: 'Участник',
        originalUrl: 'https://images.unsplash.com/photo-1577896851231-70ef18881754?w=1200&fit=crop',
        thumbUrl: 'https://images.unsplash.com/photo-1577896851231-70ef18881754?w=600&fit=crop',
        width: 1200,
        height: 800,
      },
      {
        id: uuidv4(),
        albumId: album.id,
        uploaderId: dto.hostUserId,
        uploaderName: 'Участник',
        originalUrl: 'https://images.unsplash.com/photo-1509062522246-3755977927d7?w=1200&fit=crop',
        thumbUrl: 'https://images.unsplash.com/photo-1509062522246-3755977927d7?w=600&fit=crop',
        width: 1200,
        height: 800,
      },
      {
        id: uuidv4(),
        albumId: album.id,
        uploaderId: dto.hostUserId,
        uploaderName: 'Участник',
        originalUrl: 'https://images.unsplash.com/photo-1511632765486-a01980e01a18?w=1200&fit=crop',
        thumbUrl: 'https://images.unsplash.com/photo-1511632765486-a01980e01a18?w=600&fit=crop',
        width: 1200,
        height: 800,
      },
      {
        id: uuidv4(),
        albumId: album.id,
        uploaderId: dto.hostUserId,
        uploaderName: 'Участник',
        originalUrl: 'https://images.unsplash.com/photo-1491438590914-bc09fcaaf77a?w=1200&fit=crop',
        thumbUrl: 'https://images.unsplash.com/photo-1491438590914-bc09fcaaf77a?w=600&fit=crop',
        width: 1200,
        height: 800,
      },
      {
        id: uuidv4(),
        albumId: album.id,
        uploaderId: dto.hostUserId,
        uploaderName: 'Участник',
        originalUrl: 'https://images.unsplash.com/photo-1529156069898-49953e39b3ac?w=1200&fit=crop',
        thumbUrl: 'https://images.unsplash.com/photo-1529156069898-49953e39b3ac?w=600&fit=crop',
        width: 1200,
        height: 800,
      },
      {
        id: uuidv4(),
        albumId: album.id,
        uploaderId: dto.hostUserId,
        uploaderName: 'Участник',
        originalUrl: 'https://images.unsplash.com/photo-1523240795612-9a054b0db644?w=1200&fit=crop',
        thumbUrl: 'https://images.unsplash.com/photo-1523240795612-9a054b0db644?w=600&fit=crop',
        width: 1200,
        height: 800,
      },
      {
        id: uuidv4(),
        albumId: album.id,
        uploaderId: dto.hostUserId,
        uploaderName: 'Участник',
        originalUrl: 'https://images.unsplash.com/photo-1427504494785-3a9ca7044f45?w=1200&fit=crop',
        thumbUrl: 'https://images.unsplash.com/photo-1427504494785-3a9ca7044f45?w=600&fit=crop',
        width: 1200,
        height: 800,
      },
    ];

    for (const p of starterPhotos) {
      await MediaPool.create(p, { transaction: t });
    }

    return album;
  });
}

