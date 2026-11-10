import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../network/api_client.dart';

class SessionState {
  final UserProfile? user;
  final AlbumData? currentAlbum;

  const SessionState({
    this.user,
    this.currentAlbum,
  });

  SessionState copyWith({
    UserProfile? user,
    AlbumData? currentAlbum,
  }) {
    return SessionState(
      user: user ?? this.user,
      currentAlbum: currentAlbum ?? this.currentAlbum,
    );
  }
}

class SessionNotifier extends Notifier<SessionState> {
  @override
  SessionState build() {
    return const SessionState();
  }

  void setUser(UserProfile user) {
    state = state.copyWith(user: user);
  }

  void setAlbum(AlbumData album) {
    state = state.copyWith(currentAlbum: album);
  }

  void reset() {
    state = const SessionState();
  }
}

final sessionProvider = NotifierProvider<SessionNotifier, SessionState>(() {
  return SessionNotifier();
});

