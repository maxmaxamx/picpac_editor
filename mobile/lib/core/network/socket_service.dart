import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'api_client.dart';

class OnlineUser {
  final String userId;
  final String displayName;
  final String avatarColor;
  final String? avatarUrl;

  const OnlineUser({
    required this.userId,
    required this.displayName,
    required this.avatarColor,
    this.avatarUrl,
  });

  factory OnlineUser.fromJson(Map<String, dynamic> json) {
    return OnlineUser(
      userId: json['userId'] as String? ?? json['id'] as String? ?? '',
      displayName: json['displayName'] as String? ?? 'Участник',
      avatarColor: json['avatarColor'] as String? ?? '#FF4D4D',
      avatarUrl: json['avatarUrl'] as String?,
    );
  }
}

class SocketService {
  io.Socket? _socket;
  String? _currentAlbumId;
  UserProfile? _currentUser;

  final _presenceController = StreamController<List<OnlineUser>>.broadcast();
  final _slotUpdatedController = StreamController<Map<String, dynamic>>.broadcast();
  final _reactionsUpdatedController = StreamController<Map<String, dynamic>>.broadcast();
  final _coverVotedController = StreamController<Map<String, dynamic>>.broadcast();
  final _mediaAddedController = StreamController<Map<String, dynamic>>.broadcast();
  final _pageUpdatedController = StreamController<Map<String, dynamic>>.broadcast();
  final _connectionStateController = StreamController<bool>.broadcast();

  Stream<List<OnlineUser>> get presenceStream => _presenceController.stream;
  Stream<Map<String, dynamic>> get slotUpdatedStream => _slotUpdatedController.stream;
  Stream<Map<String, dynamic>> get reactionsUpdatedStream => _reactionsUpdatedController.stream;
  Stream<Map<String, dynamic>> get coverVotedStream => _coverVotedController.stream;
  Stream<Map<String, dynamic>> get mediaAddedStream => _mediaAddedController.stream;
  Stream<Map<String, dynamic>> get pageUpdatedStream => _pageUpdatedController.stream;
  Stream<bool> get connectionStateStream => _connectionStateController.stream;

  bool get isConnected => _socket?.connected ?? false;

  void connect({
    required String serverUrl,
    required String albumId,
    required UserProfile user,
  }) {
    disconnect();

    _currentAlbumId = albumId;
    _currentUser = user;

    final options = io.OptionBuilder()
        .setTransports(['websocket'])
        .enableAutoConnect()
        .enableReconnection()
        .setAuth({'token': user.token})
        .build();

    final socket = io.io(serverUrl, options);
    _socket = socket;

    socket.onConnect((_) {
      debugPrint('⚡ [Socket.io] Connected to server: $serverUrl');
      _connectionStateController.add(true);

      // Присоединяемся к комнате альбома
      socket.emit('room:join', {
        'albumId': albumId,
        'user': {
          'userId': user.userId,
          'displayName': user.displayName,
        },
      });
    });

    socket.onDisconnect((_) {
      debugPrint('🔌 [Socket.io] Disconnected');
      _connectionStateController.add(false);
    });

    socket.onConnectError((err) {
      debugPrint('❌ [Socket.io] Connection error: $err');
      _connectionStateController.add(false);
    });

    // Обработка входящих событий от бэкенда
    socket.on('presence:update', (data) {
      if (data is Map && data['onlineUsers'] is List) {
        final list = (data['onlineUsers'] as List)
            .map((u) => OnlineUser.fromJson(Map<String, dynamic>.from(u as Map)))
            .toList();
        _presenceController.add(list);
      }
    });

    socket.on('slot:updated', (data) {
      if (data is Map && data['slot'] is Map) {
        _slotUpdatedController.add(Map<String, dynamic>.from(data['slot'] as Map));
      }
    });

    socket.on('slot:reactions_updated', (data) {
      if (data is Map) {
        _reactionsUpdatedController.add(Map<String, dynamic>.from(data));
      }
    });

    socket.on('cover:vote_updated', (data) {
      if (data is Map) {
        _coverVotedController.add(Map<String, dynamic>.from(data));
      }
    });

    socket.on('media:added', (data) {
      if (data is Map && data['media'] is Map) {
        _mediaAddedController.add(Map<String, dynamic>.from(data['media'] as Map));
      }
    });

    socket.on('page:updated', (data) {
      if (data is Map) {
        _pageUpdatedController.add(Map<String, dynamic>.from(data));
      }
    });
  }

  void clearMedia(String slotId) {
    if (_socket == null || _currentAlbumId == null) return;
    _socket!.emit('slot:clear_media', {
      'albumId': _currentAlbumId,
      'slotId': slotId,
    });
  }

  void updatePageLayout({
    required int pageNumber,
    required String layout,
  }) {
    if (_socket == null || _currentAlbumId == null) return;
    _socket!.emit('page:update_layout', {
      'albumId': _currentAlbumId,
      'pageNumber': pageNumber,
      'layout': layout,
    });
  }

  void lockSlot(String slotId) {
    if (_socket == null || _currentAlbumId == null || _currentUser == null) return;
    _socket!.emit('slot:lock', {
      'albumId': _currentAlbumId,
      'slotId': slotId,
      'user': {
        'userId': _currentUser!.userId,
        'displayName': _currentUser!.displayName,
      },
    });
  }

  void unlockSlot(String slotId) {
    if (_socket == null || _currentAlbumId == null || _currentUser == null) return;
    _socket!.emit('slot:unlock', {
      'albumId': _currentAlbumId,
      'slotId': slotId,
      'user': {
        'userId': _currentUser!.userId,
        'displayName': _currentUser!.displayName,
      },
    });
  }

  void assignMedia({
    required String slotId,
    required String mediaId,
    String? caption,
  }) {
    if (_socket == null || _currentAlbumId == null || _currentUser == null) return;
    _socket!.emit('slot:assign_media', {
      'albumId': _currentAlbumId,
      'slotId': slotId,
      'mediaId': mediaId,
      'caption': caption,
      'user': {
        'userId': _currentUser!.userId,
        'displayName': _currentUser!.displayName,
      },
    });
  }

  void updateCaption({
    required String slotId,
    required String caption,
  }) {
    if (_socket == null || _currentAlbumId == null) return;
    _socket!.emit('slot:update_caption', {
      'albumId': _currentAlbumId,
      'slotId': slotId,
      'caption': caption,
    });
  }

  void toggleReaction({
    required String slotId,
    required String emoji,
  }) {
    if (_socket == null || _currentAlbumId == null || _currentUser == null) return;
    _socket!.emit('slot:toggle_reaction', {
      'albumId': _currentAlbumId,
      'slotId': slotId,
      'emoji': emoji,
      'user': {
        'userId': _currentUser!.userId,
        'displayName': _currentUser!.displayName,
      },
    });
  }

  void voteCover(String slotId) {
    if (_socket == null || _currentAlbumId == null || _currentUser == null) return;
    _socket!.emit('cover:vote', {
      'albumId': _currentAlbumId,
      'slotId': slotId,
      'user': {
        'userId': _currentUser!.userId,
        'displayName': _currentUser!.displayName,
      },
    });
  }

  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
    _currentAlbumId = null;
    _currentUser = null;
  }

  void dispose() {
    disconnect();
    _presenceController.close();
    _slotUpdatedController.close();
    _reactionsUpdatedController.close();
    _coverVotedController.close();
    _mediaAddedController.close();
    _connectionStateController.close();
  }
}

final socketServiceProvider = Provider<SocketService>((ref) {
  final service = SocketService();
  ref.onDispose(() => service.dispose());
  return service;
});

