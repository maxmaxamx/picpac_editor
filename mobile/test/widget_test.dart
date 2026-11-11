import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:mobile/main.dart';
import 'package:mobile/features/editor/presentation/screens/spread_editor_screen.dart';
import 'package:mobile/features/cart/presentation/screens/cart_screen.dart';
import 'package:mobile/features/checkout/presentation/screens/checkout_screen.dart';

class _TestHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (cert, host, port) => true;
  }
}

void main() {
  setUpAll(() {
    HttpOverrides.global = _TestHttpOverrides();
  });

  testWidgets('Onboarding join flow navigates to SpreadEditorScreen', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(393 * 3, 852 * 3);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const ProviderScope(
        child: PicPacApp(),
      ),
    );
    await tester.pump();

    expect(find.text('picPac'), findsOneWidget);
    expect(find.text('.by'), findsOneWidget);
    expect(find.text('Войти в альбом'), findsOneWidget);

    await tester.tap(find.text('Войти в альбом'));
    await tester.pumpAndSettle();

    expect(find.text('Выпускной 11-Б • 2026'), findsAtLeastNWidgets(1));
    expect(find.text('👑 Обложка'), findsAtLeastNWidgets(1));
  });

  testWidgets('Onboarding create flow navigates to AlbumParametersScreen and then SpreadEditorScreen', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(393 * 3, 852 * 3);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const ProviderScope(
        child: PicPacApp(),
      ),
    );
    await tester.pump();

    // Switch to Create mode
    await tester.tap(find.text('Создать альбом'));
    await tester.pumpAndSettle();

    expect(find.text('Выбрать параметры альбома'), findsOneWidget);
    await tester.tap(find.text('Выбрать параметры альбома'));
    await tester.pumpAndSettle();

    // Verify AlbumTemplatesScreen
    expect(find.text('Выбор шаблона'), findsOneWidget);
    expect(find.text('Классический выпускной'), findsAtLeastNWidgets(1));
    expect(find.text('Выбрать этот шаблон'), findsOneWidget);

    await tester.tap(find.text('Выбрать этот шаблон'));
    await tester.pumpAndSettle();

    // Verify AlbumParametersScreen
    expect(find.text('Параметры альбома'), findsOneWidget);
    expect(find.text('Формат альбома'), findsOneWidget);
    expect(find.text('20×20 см'), findsOneWidget);
    expect(find.text('21×30 см'), findsOneWidget);
    expect(find.text('Ламинация страниц'), findsOneWidget);
    expect(find.text('Глянцевая'), findsOneWidget);
    expect(find.text('Зернистая'), findsOneWidget);
    expect(find.text('Количество разворотов'), findsOneWidget);

    // Tap to proceed to canvas
    await tester.tap(find.text('Создать альбом и открыть холст'));
    await tester.pumpAndSettle();

    // Verify SpreadEditorScreen
    expect(find.text('Выпускной 11-Б • 2026'), findsAtLeastNWidgets(1));
  });

  testWidgets('Editor: expanding media pool opens full screen gallery modal', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(393 * 3, 852 * 3);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: SpreadEditorScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Tap on Media Pool header to expand
    expect(find.textContaining('Общий пул'), findsOneWidget);
    await tester.tap(find.textContaining('Общий пул'));
    await tester.pumpAndSettle();

    // Should open full screen sheet
    expect(find.textContaining('Медиатека альбома'), findsOneWidget);
    expect(find.text('Добавить'), findsOneWidget);
  });

  testWidgets('Editor: clearing a filled slot empties the slot', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(393 * 3, 852 * 3);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: SpreadEditorScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Navigate to page 4
    await tester.tap(find.text('Стр. 4'));
    await tester.pumpAndSettle();

    // On page 4, slot 4_0 is filled ("Максим на олимпиаде")
    expect(find.text('Максим на олимпиаде'), findsOneWidget);
    await tester.tap(find.text('Максим на олимпиаде'));
    await tester.pumpAndSettle();

    // Photo detail sheet opened
    expect(find.text('Редактирование фото'), findsOneWidget);
    expect(find.text('Очистить слот'), findsOneWidget);

    // Tap to clear slot
    await tester.tap(find.text('Очистить слот'));
    await tester.pumpAndSettle();

    // Slot is now empty!
    expect(find.text('Слот очищен'), findsOneWidget);
  });

  testWidgets('Editor: layout switcher changes page slots count', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(393 * 3, 852 * 3);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: SpreadEditorScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Tap layout icon in bottom dock
    expect(find.byIcon(LucideIcons.layoutGrid), findsOneWidget);
    await tester.tap(find.byIcon(LucideIcons.layoutGrid));
    await tester.pumpAndSettle();

    // Verify layout options
    expect(find.text('1 фото на всю страницу'), findsOneWidget);
    expect(find.text('2 фото вертикально'), findsOneWidget);
    expect(find.text('4 фото (сетка 2×2)'), findsOneWidget);

    // Select 1 photo
    await tester.tap(find.text('1 фото на всю страницу'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Сетка страницы изменена'), findsOneWidget);
  });

  testWidgets('CheckoutScreen displays all screenshot fields and allows selecting pickup point', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(393 * 3, 852 * 3);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: CheckoutScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify screen title
    expect(find.text('Оформление'), findsOneWidget);

    // Verify customer data card
    expect(find.text('Данные покупателя'), findsOneWidget);
    expect(find.text('+375 (__) ___-__-__'), findsOneWidget);
    expect(find.text('Имя*'), findsOneWidget);
    expect(find.text('Фамилия*'), findsOneWidget);
    expect(find.text('Эл. почта*'), findsOneWidget);
    expect(find.text('Комментарий к заказу'), findsOneWidget);

    // Verify payment info card matching screenshot
    expect(find.text('Информация об оплате'), findsOneWidget);
    expect(find.text('Стоимость позиций:'), findsOneWidget);
    expect(find.text('2,90 руб.'), findsOneWidget);
    expect(find.text('Доставка:'), findsOneWidget);
    expect(find.text('Бесплатно'), findsOneWidget);
    expect(find.text('Скидка:'), findsOneWidget);
    expect(find.text('-0,81 руб.'), findsOneWidget);
    expect(find.text('Итого к оплате:'), findsOneWidget);
    expect(find.text('2,09 руб.'), findsOneWidget);
    expect(find.text('Подтвердить и заказать'), findsOneWidget);

    // Open pickup points modal with mini-map
    expect(find.text('Изменить'), findsOneWidget);
    await tester.tap(find.text('Изменить'));
    await tester.pumpAndSettle();

    // Verify pickup points modal opened
    expect(find.text('Пункты выдачи picPac'), findsOneWidget);
    expect(find.text('Выбрать этот пункт'), findsOneWidget);
    expect(find.text('Европочта Отделение №124'), findsOneWidget);

    // Select Europoshta
    await tester.tap(find.text('Европочта Отделение №124'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Выбрать этот пункт'));
    await tester.pumpAndSettle();

    // Verify selection returned to checkout
    expect(find.text('Европочта Отделение №124'), findsOneWidget);
  });

  testWidgets('CartScreen displays added album with cover preview and navigates to checkout', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(393 * 3, 852 * 3);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: CartScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify cart header and album details
    expect(find.text('Корзина (1)'), findsOneWidget);
    expect(find.text('Выпускной 11-Б • 2026'), findsWidgets);
    expect(find.text('72,90 руб.'), findsWidgets);
    expect(find.text('Оформить заказ • 1'), findsOneWidget);

    // Tap checkout button
    await tester.tap(find.text('Оформить заказ • 1'));
    await tester.pumpAndSettle();

    // Verify it navigated to delivery and customer details screen
    expect(find.text('Оформление'), findsOneWidget);
    expect(find.text('Данные покупателя'), findsOneWidget);
  });
}
