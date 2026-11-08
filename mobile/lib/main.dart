import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'core/theme/app_theme.dart';
import 'features/editor/presentation/screens/spread_editor_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const ProviderScope(
      child: PicPacApp(),
    ),
  );
}

class PicPacApp extends StatelessWidget {
  const PicPacApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ShadApp(
      title: 'picPac.by — Коллективный фотоальбом',
      debugShowCheckedModeBanner: false,
      theme: PicPacTheme.shadTheme,
      materialThemeBuilder: (context, theme) => PicPacTheme.lightTheme,
      home: const SpreadEditorScreen(),
    );
  }
}
