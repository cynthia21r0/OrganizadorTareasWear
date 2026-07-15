import 'package:dio/dio.dart';

class WearApiClient {
  WearApiClient._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
      ),
    );
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
      ),
    );
  }

  static final WearApiClient instance = WearApiClient._internal();

  static const String baseUrl =
      'https://organizadortareasback.onrender.com/api';

  late final Dio _dio;
  Dio get dio => _dio;

  String? token;
  String? userId;
}
