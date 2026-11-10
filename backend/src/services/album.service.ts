import { Transaction } from 'sequelize';
import { sequelize, Album, AlbumMember, Page, Slot } from '../models/index.js';

export function generateInviteCode(): string {
  // 6-значный цифровой код для удобного ввода с мобильной клавиатуры
  const min = 100000;
  const max = 999999;
  return Math.floor(min + Math.random() * (max - min + 1)).toString();
}

export interface CreateAlbumDTO {
  title: string;
  hostUserId: string;
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

    return album;
  });
}

