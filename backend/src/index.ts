import express from 'express';
import http from 'http';
import { Server } from 'socket.io';
import cors from 'cors';
import dotenv from 'dotenv';
import path from 'path';
import { initDatabase } from './config/database.js';
import { setupModels, sequelize } from './models/index.js';
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

    // 4. Запуск HTTP + WebSocket сервера
    server.listen(PORT, '0.0.0.0', () => {
      console.log(`🚀 Сервер picPac.by успешно запущен на http://localhost:${PORT}`);
    });
  } catch (err) {
    console.error('❌ Фатальная ошибка запуска сервера:', err);
    process.exit(1);
  }
}

// Запуск при прямом вызове
if (process.env.NODE_ENV !== 'test') {
  startServer();
}

export { app, server, io };

