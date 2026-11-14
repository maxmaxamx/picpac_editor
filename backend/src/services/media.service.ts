import path from 'path';
import fs from 'fs';
import sharp from 'sharp';
import { v4 as uuidv4 } from 'uuid';
import { MediaPool, Album } from '../models/index.js';

export interface SaveMediaInput {
  file: Express.Multer.File;
  albumId: string;
  userId: string;
  userName: string;
}

/// Сервис обработки и сохранения медиафайлов (SOLID: SRP, DIP)
export class MediaService {
  private uploadsDir: string;
  private originalsDir: string;
  private thumbsDir: string;

  constructor() {
    this.uploadsDir = path.resolve(process.cwd(), 'uploads');
    this.originalsDir = path.join(this.uploadsDir, 'originals');
    this.thumbsDir = path.join(this.uploadsDir, 'thumbs');
    this.ensureDirectories();
  }

  private ensureDirectories(): void {
    if (!fs.existsSync(this.originalsDir)) {
      fs.mkdirSync(this.originalsDir, { recursive: true });
    }
    if (!fs.existsSync(this.thumbsDir)) {
      fs.mkdirSync(this.thumbsDir, { recursive: true });
    }
  }

  public async processAndSaveMedia(input: SaveMediaInput): Promise<MediaPool> {
    const { file, albumId, userId, userName } = input;

    const album = await Album.findByPk(albumId);
    if (!album) {
      throw new Error('ALBUM_NOT_FOUND');
    }

    const fileId = uuidv4();
    const originalExt = path.extname(file.originalname) || '.jpg';
    const originalFileName = `${fileId}_orig${originalExt}`;
    const thumbFileName = `${fileId}_thumb.webp`;

    const originalFilePath = path.join(this.originalsDir, originalFileName);
    const thumbFilePath = path.join(this.thumbsDir, thumbFileName);

    // 1. Сохраняем оригинал
    await fs.promises.writeFile(originalFilePath, file.buffer);

    // 2. Генерируем оптимизированное легкое WebP превью (600x600 max, 80% качество) через sharp
    const metadata = await sharp(file.buffer)
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
    return media;
  }
}

export const mediaService = new MediaService();

