import 'dart:io';
import 'package:dio/dio.dart';
import 'package:ismgl/app/routes/app_routes.dart';
import 'package:ismgl/core/services/storage_service.dart';
import 'package:get/get.dart' hide FormData, MultipartFile;

class ApiService {
  static const String baseUrl = 'http://192.168.1.69/ismgl-api/api/v1';

  late final Dio _dio;
  final StorageService _storage = Get.find<StorageService>();

  ApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
      contentType: 'application/json',
      responseType: ResponseType.json,
    ));

    _setupInterceptors();
  }

  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Ajouter le token Bearer
          final token = _storage.getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          options.headers['Accept'] = 'application/json';

          // Auto refresh si token expiré
          if (_storage.isTokenExpired()) {
            final refreshed = await _refreshToken();
            if (refreshed) {
              final newToken = _storage.getToken();
              options.headers['Authorization'] = 'Bearer $newToken';
            }
          }

          return handler.next(options);
        },
        onResponse: (response, handler) {
          return handler.next(response);
        },
        onError: (DioException e, handler) async {
          if (e.response?.statusCode == 401) {
            // Tenter refresh
            final refreshed = await _refreshToken();
            if (refreshed) {
              // Rejouer la requête
              final opts = e.requestOptions;
              opts.headers['Authorization'] = 'Bearer ${_storage.getToken()}';
              try {
                final response = await _dio.fetch(opts);
                return handler.resolve(response);
              } catch (_) {}
            }

            // Déconnecter
            await _storage.clearSession();
            Get.offAllNamed(AppRoutes.login);
          }
          return handler.next(e);
        },
      ),
    );

    // Logger en dev
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      error: true,
      requestHeader: false,
    ));
  }

  Future<bool> _refreshToken() async {
    try {
      final refreshToken = _storage.getRefreshToken();
      if (refreshToken == null) return false;

      final response = await Dio().post(
        '$baseUrl/auth/refresh',
        data: {'refresh_token': refreshToken},
      );

      if (response.statusCode == 200) {
        final data = response.data['data'];
        await _storage.saveToken(data['token']);
        await _storage.saveRefreshToken(data['refresh_token']);
        await _storage.saveTokenExpiry(
          DateTime.now().add(Duration(seconds: data['expires_in'])),
        );
        return true;
      }
    } catch (_) {}
    return false;
  }

  // GET
  Future<Map<String, dynamic>> get(String endpoint,
      {Map<String, dynamic>? params}) async {
    try {
      final response = await _dio.get(endpoint, queryParameters: params);
      return response.data;
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  // POST
  Future<Map<String, dynamic>> post(String endpoint, {dynamic data}) async {
    try {
      final response = await _dio.post(endpoint, data: data);
      return response.data;
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  // PUT
  Future<Map<String, dynamic>> put(String endpoint, {dynamic data}) async {
    try {
      final response = await _dio.put(endpoint, data: data);
      return response.data;
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  // PATCH
  Future<Map<String, dynamic>> patch(String endpoint, {dynamic data}) async {
    try {
      final response = await _dio.patch(endpoint, data: data);
      return response.data;
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  // DELETE
  Future<Map<String, dynamic>> delete(String endpoint) async {
    try {
      final response = await _dio.delete(endpoint);
      return response.data;
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  // Upload multipart
  Future<Map<String, dynamic>> upload(
    String endpoint,
    Map<String, dynamic> fields, {
    Map<String, File>? files,
    String method = 'POST',
  }) async {
    try {
      final formData = FormData.fromMap(fields);

      if (files != null) {
        for (final entry in files.entries) {
          formData.files.add(MapEntry(
            entry.key,
            await MultipartFile.fromFile(entry.value.path),
          ));
        }
      }

      final response = method == 'POST'
          ? await _dio.post(endpoint, data: formData)
          : await _dio.put(endpoint, data: formData);

      return response.data;
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  Map<String, dynamic> _handleError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return {
        'success': false,
        'message': 'Délai de connexion dépassé. Vérifiez votre connexion.',
        'status_code': 408,
        'data': null
      };
    }

    if (e.type == DioExceptionType.connectionError) {
      return {
        'success': false,
        'message': 'Impossible de se connecter au serveur.',
        'status_code': 503,
        'data': null
      };
    }

    if (e.response != null) {
      return e.response!.data ??
          {
            'success': false,
            'message': 'Erreur serveur',
            'status_code': e.response!.statusCode,
            'data': null
          };
    }

    return {
      'success': false,
      'message': 'Une erreur inattendue est survenue.',
      'status_code': 500,
      'data': null
    };
  }
}
