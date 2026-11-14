import { Album } from '../models/index.js';

export interface CreateOrderInput {
  albumId: string;
  pickupPointId: string;
  pickupPointName: string;
  phone: string;
  customerName: string;
  email: string;
  comment?: string;
}

export interface OrderResult {
  orderNumber: string;
  album: Album;
}

/// Сервис обработки заказов фотокниг (SOLID: SRP)
export class OrderService {
  public async createOrder(input: CreateOrderInput): Promise<OrderResult> {
    const { albumId, phone, customerName, pickupPointName } = input;

    const album = await Album.findByPk(albumId);
    if (!album) {
      throw new Error('ALBUM_NOT_FOUND');
    }

    const orderNumber = `PP-${Date.now().toString().slice(-6)}`;
    album.status = 'ordered';
    await album.save();

    console.log(`📦 [Order Created] Заказ ${orderNumber} для альбома "${album.title}": ${customerName}, ${phone}, ${pickupPointName}`);

    return {
      orderNumber,
      album,
    };
  }
}

export const orderService = new OrderService();

