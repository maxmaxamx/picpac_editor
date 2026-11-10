import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

String get defaultServerUrl {
  if (kIsWeb) return 'http://localhost:3000';
  if (Platform.isAndroid) return 'http://10.0.2.2:3000';
  return 'http://localhost:3000';
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
  final int spreadsCount;
  final String inviteCode;
  final String status;

  const AlbumData({
    required this.id,
    required this.name,
    required this.format,
    required this.lamination,
    required this.spreadsCount,
    required this.inviteCode,
    required this.status,
  });

  factory AlbumData.fromJson(Map<String, dynamic> json) {
    return AlbumData(
      id: json['id'] as String,
      name: json['name'] as String,
      format: json['format'] as String? ?? '21x30',
      lamination: json['lamination'] as String? ?? 'glossy',
      spreadsCount: (json['spreadsCount'] as num?)?.toInt() ?? 10,
      inviteCode: json['inviteCode'] as String? ?? '',
      status: json['status'] as String? ?? 'draft',
    );
  }
}

class ApiClient {
  final Dio _dio;
  String? _token;
  final String baseUrl;

  ApiClient({String? baseUrl})
      : baseUrl = baseUrl ?? defaultServerUrl,
        _dio = Dio(
          BaseOptions(
            baseUrl: baseUrl ?? defaultServerUrl,
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

  void setToken(String? token) {
    _token = token;
  }

  String resolveUrl(String? path) {
    if (path == null || path.isEmpty) return '';
    if (path.startsWith('http://') || path.startsWith('https://')) return path;
    if (path.startsWith('/')) return '$baseUrl$path';
    return '$baseUrl/$path';
  }

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

  Future<AlbumData> createAlbum({
    required String name,
    required String format,
    required String lamination,
    required int spreadsCount,
  }) async {
    final response = await _dio.post(
      '/api/albums',
      data: {
        'name': name.trim(),
        'format': format,
        'lamination': lamination,
        'spreadsCount': spreadsCount,
      },
    );

    final data = response.data as Map<String, dynamic>;
    final albumJson = data['album'] as Map<String, dynamic>;
    return AlbumData.fromJson(albumJson);
  }

  Future<AlbumData> joinAlbum(String inviteCode) async {
    final response = await _dio.post(
      '/api/albums/join',
      data: {'inviteCode': inviteCode.trim()},
    );

    final data = response.data as Map<String, dynamic>;
    final albumJson = data['album'] as Map<String, dynamic>;
    return AlbumData.fromJson(albumJson);
  }

  Future<Map<String, dynamic>> getAlbumFull(String albumId) async {
    final response = await _dio.get('/api/albums/$albumId/full');
    final data = response.data as Map<String, dynamic>;
    return data['album'] as Map<String, dynamic>;
  }

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
}

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});

