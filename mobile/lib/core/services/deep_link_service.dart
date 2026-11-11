import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../network/api_client.dart';
import '../session/session_state.dart';
import '../../features/editor/presentation/screens/spread_editor_screen.dart';

final GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();

class DeepLinkService {
  final Ref _ref;
  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _sub;
  bool _isProcessing = false;

  DeepLinkService(this._ref);

  void init() {
    // 1. Слушаем входящие диплинки во время работы приложения
    _sub = _appLinks.uriLinkStream.listen(
      (uri) {
        _handleUri(uri);
      },
      onError: (err) {
        debugPrint('DeepLink error: $err');
      },
    );

    // 2. Обрабатываем начальный диплинк, если приложение было запущено по ссылке
    _appLinks.getInitialLink().then((uri) {
      if (uri != null) {
        _handleUri(uri);
      }
    }).catchError((err) {
      debugPrint('DeepLink initial error: $err');
    });
  }

  Future<void> _handleUri(Uri uri) async {
    if (_isProcessing) return;

    // Поддерживаемые форматы:
    // picpac://join?code=849204
    // picpac://album/849204
    // https://picpac.by/join?code=849204
    String? code = uri.queryParameters['code'];
    if (code == null && uri.pathSegments.isNotEmpty) {
      code = uri.pathSegments.last;
    }
    if (code == null) return;

    final match = RegExp(r'\b\d{6}\b').firstMatch(code);
    final cleanCode = match != null ? match.group(0)! : code.trim();
    if (cleanCode.length != 6) return;

    _isProcessing = true;

    try {
      final apiClient = _ref.read(apiClientProvider);
      final session = _ref.read(sessionProvider);
      final user = session.user ?? await apiClient.guestAuth('Участник');
      final album = await apiClient.joinAlbum(cleanCode);

      _ref.read(sessionProvider.notifier).setUser(user);
      _ref.read(sessionProvider.notifier).setAlbum(album);

      final nav = appNavigatorKey.currentState;
      if (nav != null) {
        nav.push<void>(
          MaterialPageRoute(
            builder: (_) => SpreadEditorScreen(
              albumId: album.id,
              albumTitle: album.name,
              userName: user.displayName,
              spreadsCount: album.spreadsCount,
              aspectRatio: album.format == '20x20' ? 1.0 : (3.0 / 4.0),
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint('Не удалось открыть альбом по диплинку $uri: $e');
    } finally {
      _isProcessing = false;
    }
  }

  void dispose() {
    _sub?.cancel();
  }
}

final deepLinkServiceProvider = Provider<DeepLinkService>((ref) {
  final service = DeepLinkService(ref);
  service.init();
  ref.onDispose(() => service.dispose());
  return service;
});
