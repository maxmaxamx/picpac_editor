process.env.NODE_ENV = 'test';

import { initDatabase } from './config/database.js';
import { setupModels, sequelize } from './models/index.js';
import { app } from './index.js';
import http from 'http';

async function runTests() {
  console.log('🧪 Запуск интеграционного тестирования REST API picPac.by...\n');

  // 1. Инициализация БД
  await initDatabase();
  setupModels();
  await sequelize.sync({ force: true });

  const testServer = http.createServer(app);
  await new Promise<void>((resolve) => testServer.listen(3001, resolve));
  const baseUrl = 'http://localhost:3001';

  try {
    // 2. Тест: Регистрация гостя (Хост Артём)
    console.log('1. Тест регистрации организатора (POST /api/auth/guest)...');
    const hostRes = await fetch(`${baseUrl}/api/auth/guest`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ displayName: 'Артём' }),
    });
    const hostData = await hostRes.json() as any;
    if (!hostRes.ok || !hostData.token) {
      throw new Error(`Ошибка входа хоста: ${JSON.stringify(hostData)}`);
    }
    console.log(`   ✅ Хост создан: ${hostData.user.displayName} (ID: ${hostData.user.id})`);
    const hostToken = hostData.token;

    // 3. Тест: Регистрация гостя (Участник Алина)
    console.log('2. Тест регистрации участника (POST /api/auth/guest)...');
    const editorRes = await fetch(`${baseUrl}/api/auth/guest`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ displayName: 'Алина' }),
    });
    const editorData = await editorRes.json() as any;
    if (!editorRes.ok || !editorData.token) {
      throw new Error(`Ошибка входа редактора: ${JSON.stringify(editorData)}`);
    }
    console.log(`   ✅ Участник создан: ${editorData.user.displayName} (ID: ${editorData.user.id})`);
    const editorToken = editorData.token;

    // 4. Тест: Создание альбома организатором (POST /api/albums)
    console.log('3. Тест создания альбома с генерацией разворотов и слотов (POST /api/albums)...');
    const albumRes = await fetch(`${baseUrl}/api/albums`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        Authorization: `Bearer ${hostToken}`,
      },
      body: JSON.stringify({
        title: 'Выпускной 11-Б • 2026',
        format: 'vertical_21x30',
        lamination: 'glossy',
        totalSpreads: 10,
      }),
    });
    const albumData = await albumRes.json() as any;
    if (!albumRes.ok || !albumData.album) {
      throw new Error(`Ошибка создания альбома: ${JSON.stringify(albumData)}`);
    }
    const album = albumData.album;
    console.log(`   ✅ Альбом создан: "${album.title}"`);
    console.log(`   🔑 Инвайт-код для входа: ${album.inviteCode}`);
    console.log(`   📄 Разворотов: ${album.totalSpreads}, Страниц: ${album.totalPages}`);

    // 5. Тест: Вход в альбом по инвайт-коду (POST /api/albums/join)
    console.log('4. Тест присоединения участника по коду (POST /api/albums/join)...');
    const joinRes = await fetch(`${baseUrl}/api/albums/join`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        Authorization: `Bearer ${editorToken}`,
      },
      body: JSON.stringify({
        inviteCode: album.inviteCode,
      }),
    });
    const joinData = await joinRes.json() as any;
    if (!joinRes.ok) {
      throw new Error(`Ошибка присоединения: ${JSON.stringify(joinData)}`);
    }
    console.log(`   ✅ Алина успешно присоединилась! Роль: ${joinData.role}`);

    // 6. Тест: Получение полной структуры альбома (GET /api/albums/:id/full)
    console.log('5. Тест получения структуры альбома со страницами и слотами (GET /api/albums/:id/full)...');
    const fullRes = await fetch(`${baseUrl}/api/albums/${album.id}/full`, {
      headers: {
        Authorization: `Bearer ${hostToken}`,
      },
    });
    const fullData = await fullRes.json() as any;
    if (!fullRes.ok || !fullData.album) {
      throw new Error(`Ошибка получения альбома: ${JSON.stringify(fullData)}`);
    }

    const fullAlbum = fullData.album;
    const pagesCount = fullAlbum.pages?.length || 0;
    let totalSlots = 0;
    for (const page of fullAlbum.pages || []) {
      totalSlots += page.slots?.length || 0;
    }
    const membersCount = fullAlbum.members?.length || 0;

    console.log(`   ✅ Страниц загружено: ${pagesCount} (ожидалось 20)`);
    console.log(`   ✅ Слотов сгенерировано: ${totalSlots} (ожидалось 80)`);
    console.log(`   ✅ Участников в альбоме: ${membersCount} (ожидалось 2)`);

    if (pagesCount !== 20 || totalSlots !== 80 || membersCount !== 2) {
      throw new Error('Количество сгенерированных элементов не совпадает со спецификацией!');
    }

    // 7. Тест: Загрузка медиа в альбом (POST /api/albums/:id/media)
    console.log('6. Тест загрузки фотографии в пул медиатеки с генерацией WebP превью (POST /api/albums/:id/media)...');
    const formData = new FormData();
    const pngPixel = Buffer.from('iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==', 'base64');
    const blob = new Blob([pngPixel], { type: 'image/png' });
    formData.append('file', blob, 'test_photo.png');

    const uploadRes = await fetch(`${baseUrl}/api/albums/${album.id}/media`, {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${hostToken}`,
      },
      body: formData,
    });
    const uploadData = await uploadRes.json() as any;
    if (!uploadRes.ok || !uploadData.media) {
      throw new Error(`Ошибка загрузки медиа: ${JSON.stringify(uploadData)}`);
    }
    console.log(`   ✅ Медиа успешно загружено: ${uploadData.media.id}`);
    console.log(`   🖼️ WebP превью: ${uploadData.media.thumbUrl}`);

    console.log('\n🎉 ВСЕ ИНТЕГРАЦИОННЫЕ ТЕСТЫ БЭКЕНДА УСПЕШНО ПРОЙДЕНЫ!');
  } finally {
    testServer.close();
  }
}

runTests()
  .then(() => process.exit(0))
  .catch((err) => {
    console.error('❌ Ошибка теста:', err);
    process.exit(1);
  });
