import express from 'express';
import http from 'http';
import { Server } from 'socket.io';
import cors from 'cors';
import dotenv from 'dotenv';
import path from 'path';
import { initDatabase } from './config/database.js';
import { setupModels, sequelize, User, Album } from './models/index.js';
import { createAlbumTransaction } from './services/album.service.js';
import apiRouter from './routes/index.js';
import { setupSocketHandlers } from './socket/index.js';

dotenv.config();

const app = express();
const server = http.createServer(app);

// Настройка Socket.io для Realtime (Фаза 3)
const io = new Server(server, {
  cors: {
    origin: '*',
    methods: ['GET', 'POST'],
  },
});

const PORT = Number(process.env.PORT) || 3000;

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Статическая папка для превью и оригиналов фото
const uploadsPath = path.resolve(process.cwd(), 'uploads');
app.use('/uploads', express.static(uploadsPath));

// Healthcheck
app.get('/health', (req, res) => {
  res.json({
    status: 'ok',
    service: 'picPac.by Album Collaboration API',
    time: new Date().toISOString(),
  });
});

// API Routes
app.use('/api', apiRouter);

// Инициализация WebSocket-обработчиков (Фаза 3: Presence, Slot Locks, Media, Reactions, Cover Voting)
setupSocketHandlers(io);

export async function startServer() {
  try {
    // 1. Инициализация подключения к БД
    await initDatabase();

    // 2. Регистрация моделей и ассоциаций
    setupModels();

    // 3. Синхронизация схемы таблиц
    await sequelize.sync();
    console.log('✅ Схема таблиц синхронизирована (Users, Albums, Pages, Slots, MediaPool, CoverVotes)');

    // 4. Гарантируем наличие базового альбома с кодом 849204 для мгновенного входа двух устройств
    await ensureDefaultAlbum();

    // 5. Запуск HTTP + WebSocket сервера
    server.listen(PORT, '0.0.0.0', () => {
      console.log(`🚀 Сервер picPac.by успешно запущен на http://localhost:${PORT}`);
    });
  } catch (err) {
    console.error('❌ Фатальная ошибка запуска сервера:', err);
    process.exit(1);
  }
}

async function ensureDefaultAlbum() {
  try {
    const existing = await Album.findOne({ where: { inviteCode: '849204' } });
    if (!existing) {
      let defaultHost = await User.findByPk('host_default_artem');
      if (!defaultHost) {
        defaultHost = await User.create({
          id: 'host_default_artem',
          displayName: 'Артём',
          avatarColor: '#FF4D4D',
        });
      }
      const album = await createAlbumTransaction({
        title: 'Выпускной 11-Б • 2026',
        hostUserId: defaultHost.id,
        totalSpreads: 10,
        format: 'vertical_21x30',
        lamination: 'glossy',
      });
      album.inviteCode = '849204';
      await album.save();
      console.log('🎉 Создан базовый альбом для двух устройств с PIN-кодом: 849204');
    }
  } catch (err) {
    console.error('Ошибка инициализации базового альбома:', err);
  }
}

// Запуск при прямом вызове
if (process.env.NODE_ENV !== 'test') {
  startServer();
}

export { app, server, io };

