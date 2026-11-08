import 'package:flutter/material.dart';

abstract class PicPacColors {
  // Кораллово-красный (Главный акцент бренда picPac.by)
  // Применение: Главная CTA-кнопка "В заказ", активная рамка выбранного слота, 
  // полиграфическая линия безопасности (safe zone), бейджи уведомлений/голосов.
  static const Color primaryCoral = Color(0xFFFF4D4D);
  static const Color primaryCoralSoft = Color(0xFFFFF0F0); // Подложка выбранного пустого слота

  // Графитовый / Черный (Логотип, заголовки, основное меню, читаемый текст, капсула навигации)
  static const Color textDark = Color(0xFF1A1A1A);
  static const Color pureBlack = Color(0xFF000000);

  // Белый (Фон шапки, подложка листа фотокниги, имитация полей фотоснимков, модальные окна)
  static const Color white = Color(0xFFFFFFFF);

  // Светло-серый (Фон "рабочего стола" под книгой, плашки второстепенных кнопок, границы)
  static const Color surfaceGrey = Color(0xFFF5F5F5);

  // Системные и вспомогательные оттенки
  static const Color borderDefault = Color(0xFFE5E5E5);   // Разделители и контуры
  static const Color borderDashed = Color(0xFFD4D4D4);    // Пунктир неактивного слота
  static const Color textMuted = Color(0xFF737373);       // Вторичный текст, авторы, таймеры
  static const Color onlineGreen = Color(0xFF22C55E);     // Индикатор присутствия (Realtime)
}

