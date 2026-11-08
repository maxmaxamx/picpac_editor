import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/main.dart';

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

  testWidgets('SpreadEditorScreen visual skeleton smoke test', (WidgetTester tester) async {
    // Set typical mobile phone screen size (e.g. iPhone 15: 393 x 852)
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

    // Verify album title and dock CTA are present
    expect(find.text('Выпускной 11-Б • 2026'), findsOneWidget);
    expect(find.text('👑 Обложка'), findsOneWidget);
  });
}
