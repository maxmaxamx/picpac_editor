import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

String get defaultServerUrl {
  const fromEnv = String.fromEnvironment('API_URL');
  if (fromEnv.isNotEmpty) return fromEnv;
  if (kIsWeb) return 'http://localhost:3000';
  if (Platform.isAndroid) return 'http://10.0.2.2:3000';
  // Локальный сетевой IP для одновременного входа с двух устройств (телефон + компьютер/телефон)
  return 'http://192.168.1.15:3000';
}

class UserProfile {
  final String userId;
  final String displayName;
  final String? token;

  const UserProfile({
    required this.userId,
    required this.displayName,
    this.token,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json, {String? token}) {
    return UserProfile(
      userId: json['id'] as String,
      displayName: json['displayName'] as String,
      token: token ?? json['token'] as String?,
    );
  }
}

class AlbumData {
  final String id;
  final String name;
  final String format;
  final String lamination;
  final String templateId;
  final int spreadsCount;
  final String inviteCode;
  final String status;
  final String? winningCoverId;

  const AlbumData({
    required this.id,
    required this.name,
    required this.format,
    required this.lamination,
    this.templateId = 'school_drive',
    required this.spreadsCount,
    required this.inviteCode,
    required this.status,
    this.winningCoverId,
  });

  factory AlbumData.fromJson(Map<String, dynamic> json) {
    return AlbumData(
      id: json['id'] as String,
      name: (json['title'] ?? json['name']) as String? ?? 'Наш фотоальбом',
      format: (json['format'] as String?) ?? 'vertical_21x30',
      lamination: (json['lamination'] as String?) ?? 'glossy',
      templateId: (json['templateId'] as String?) ?? 'school_drive',
      spreadsCount: (json['totalSpreads'] ?? json['spreadsCount'] as num?)?.toInt() ?? 10,
      inviteCode: json['inviteCode'] as String? ?? '',
      status: json['status'] as String? ?? 'draft',
      winningCoverId: json['winningCoverId'] as String?,
    );
  }
}

/// Интерфейс аутентификации (SOLID: ISP)
abstract class IAuthApi {
  void setToken(String? token);
  Future<UserProfile> guestAuth(String displayName);
}

/// Интерфейс работы с альбомами (SOLID: ISP)
abstract class IAlbumApi {
  Future<AlbumData> createAlbum({
    required String name,
    required String format,
    required String lamination,
    required int spreadsCount,
    String? templateId,
  });

  Future<AlbumData> joinAlbum(String inviteCode);
  Future<Map<String, dynamic>> getAlbumFull(String albumId);
}

/// Интерфейс загрузки медиа (SOLID: ISP)
abstract class IMediaApi {
  String get baseUrl;
  String resolveUrl(String? path);
  Future<Map<String, dynamic>> uploadMedia({
    required String albumId,
    required List<int> fileBytes,
    required String fileName,
  });
}

/// Интерфейс управления слотами и разворотами (SOLID: ISP)
abstract class ISlotApi {
  Future<Map<String, dynamic>> assignSlotMedia({
    required String albumId,
    required String slotId,
    required String mediaId,
    String? caption,
  });

  Future<void> clearSlotMedia({
    required String albumId,
    required String slotId,
  });

  Future<void> updatePageLayout({
    required String albumId,
    required int pageNumber,
    required String layoutType,
  });
}

/// Интерфейс оформления заказов (SOLID: ISP)
abstract class IOrderApi {
  Future<Map<String, dynamic>> createOrder({
    required String albumId,
    required String pickupPointId,
    required String pickupPointName,
    required String phone,
    required String customerName,
    required String email,
    String? comment,
  });
}

/// Единый абстрактный контракт API-клиента (SOLID: DIP, LSP)
abstract class IApiClient implements IAuthApi, IAlbumApi, IMediaApi, ISlotApi, IOrderApi {
  void updateBaseUrl(String newUrl);
  Future<bool> checkHealth();
}

class ApiClient implements IApiClient {
  final Dio _dio;
  String? _token;
  String _baseUrl;

  @override
  String get baseUrl => _baseUrl;

  ApiClient({String? baseUrl})
      : _baseUrl = (baseUrl ?? defaultServerUrl).trim().replaceAll(RegExp(r'/+$'), ''),
        _dio = Dio(
          BaseOptions(
            baseUrl: (baseUrl ?? defaultServerUrl).trim().replaceAll(RegExp(r'/+$'), ''),
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 15),
            headers: {'Content-Type': 'application/json'},
          ),
        ) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (_token != null && _token!.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $_token';
          }
          return handler.next(options);
        },
      ),
    );
  }

  @override
  void setToken(String? token) {
    _token = token;
  }

  @override
  void updateBaseUrl(String newUrl) {
    final clean = newUrl.trim().replaceAll(RegExp(r'/+$'), '');
    _baseUrl = clean;
    _dio.options.baseUrl = clean;
  }

  @override
  Future<bool> checkHealth() async {
    try {
      final res = await _dio.get('/health');
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  @override
  String resolveUrl(String? path) {
    if (path == null || path.isEmpty) return '';
    if (path.startsWith('http://') || path.startsWith('https://')) return path;
    if (path.startsWith('/')) return '$baseUrl$path';
    return '$baseUrl/$path';
  }

  @override
  Future<UserProfile> guestAuth(String displayName) async {
    final response = await _dio.post(
      '/api/auth/guest',
      data: {'displayName': displayName.trim()},
    );

    final data = response.data as Map<String, dynamic>;
    final token = data['token'] as String;
    final userJson = data['user'] as Map<String, dynamic>;
    setToken(token);

    return UserProfile.fromJson(userJson, token: token);
  }

  @override
  Future<AlbumData> createAlbum({
    required String name,
    required String format,
    required String lamination,
    required int spreadsCount,
    String? templateId,
  }) async {
    final response = await _dio.post(
      '/api/albums',
      data: {
        'title': name.trim(),
        'name': name.trim(),
        'templateId': templateId ?? 'school_drive',
        'format': format,
        'lamination': lamination,
        'totalSpreads': spreadsCount,
        'spreadsCount': spreadsCount,
      },
    );

    final data = response.data as Map<String, dynamic>;
    final albumJson = data['album'] as Map<String, dynamic>;
    return AlbumData.fromJson(albumJson);
  }

  @override
  Future<AlbumData> joinAlbum(String inviteCode) async {
    final response = await _dio.post(
      '/api/albums/join',
      data: {'inviteCode': inviteCode.trim()},
    );

    final data = response.data as Map<String, dynamic>;
    final albumJson = data['album'] as Map<String, dynamic>;
    return AlbumData.fromJson(albumJson);
  }

  @override
  Future<Map<String, dynamic>> getAlbumFull(String albumId) async {
    final response = await _dio.get('/api/albums/$albumId/full');
    final data = response.data as Map<String, dynamic>;
    return data['album'] as Map<String, dynamic>;
  }

  @override
  Future<Map<String, dynamic>> uploadMedia({
    required String albumId,
    required List<int> fileBytes,
    required String fileName,
  }) async {
    final formData = FormData.fromMap({
      'file': MultipartFile.fromBytes(fileBytes, filename: fileName),
    });

    final response = await _dio.post(
      '/api/albums/$albumId/media',
      data: formData,
    );

    final data = response.data as Map<String, dynamic>;
    return data['media'] as Map<String, dynamic>;
  }

  @override
  Future<Map<String, dynamic>> assignSlotMedia({
    required String albumId,
    required String slotId,
    required String mediaId,
    String? caption,
  }) async {
    final response = await _dio.post(
      '/api/albums/$albumId/slots/$slotId/assign',
      data: {
        'mediaId': mediaId,
        'caption': caption,
      },
    );
    return response.data as Map<String, dynamic>;
  }

  @override
  Future<void> clearSlotMedia({
    required String albumId,
    required String slotId,
  }) async {
    await _dio.post('/api/albums/$albumId/slots/$slotId/clear');
  }

  @override
  Future<void> updatePageLayout({
    required String albumId,
    required int pageNumber,
    required String layoutType,
  }) async {
    await _dio.post(
      '/api/albums/$albumId/pages/$pageNumber/layout',
      data: {'layoutType': layoutType},
    );
  }

  @override
  Future<Map<String, dynamic>> createOrder({
    required String albumId,
    required String pickupPointId,
    required String pickupPointName,
    required String phone,
    required String customerName,
    required String email,
    String? comment,
  }) async {
    final response = await _dio.post(
      '/api/albums/$albumId/checkout',
      data: {
        'pickupPointId': pickupPointId,
        'pickupPointName': pickupPointName,
        'phone': phone,
        'customerName': customerName,
        'email': email,
        'comment': comment,
      },
    );
    return response.data as Map<String, dynamic>;
  }
}

/// Провайдер абстрактного клиента API (SOLID: DIP)
final apiClientProvider = Provider<IApiClient>((ref) {
  return ApiClient();
});

/// Сегрегированные провайдеры (SOLID: ISP)
final authApiProvider = Provider<IAuthApi>((ref) => ref.watch(apiClientProvider));
final albumApiProvider = Provider<IAlbumApi>((ref) => ref.watch(apiClientProvider));
final mediaApiProvider = Provider<IMediaApi>((ref) => ref.watch(apiClientProvider));
final slotApiProvider = Provider<ISlotApi>((ref) => ref.watch(apiClientProvider));
final orderApiProvider = Provider<IOrderApi>((ref) => ref.watch(apiClientProvider));

