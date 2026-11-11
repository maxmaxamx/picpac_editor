import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'core/services/deep_link_service.dart';
import 'core/theme/app_theme.dart';
import 'features/onboarding/presentation/screens/onboarding_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const ProviderScope(
      child: PicPacApp(),
    ),
  );
}

class PicPacApp extends ConsumerWidget {
  const PicPacApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Инициализируем обработку входящих ссылок picpac://join?code=...
    ref.watch(deepLinkServiceProvider);

    return ShadApp(
      navigatorKey: appNavigatorKey,
      title: 'picPac.by — Коллективный фотоальбом',
      debugShowCheckedModeBanner: false,
      theme: PicPacTheme.shadTheme,
      materialThemeBuilder: (context, theme) => PicPacTheme.lightTheme,
      home: const OnboardingScreen(),
    );
  }
}
