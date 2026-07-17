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
        onError: (DioException e, handler) {
          handler.reject(
            DioException(
              requestOptions: e.requestOptions,
              response: e.response,
              type: e.type,
              error: _friendlyMessage(e),
            ),
          );
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
  String? userRole;

  static String _friendlyMessage(DioException e) {
    // Primero intentar leer el mensaje del body del backend
    final data = e.response?.data;
    if (data is Map) {
      final msg = data['message'];
      if (msg is String && msg.isNotEmpty) return msg;
      if (msg is List && msg.isNotEmpty) return (msg.first as String);
    }

    switch (e.response?.statusCode) {
      case 400: return 'Datos incorrectos. Revisa los campos.';
      case 401: return 'Sesión expirada. Inicia sesión de nuevo.';
      case 403: return 'No tienes permiso para esta acción.';
      case 404: return 'No se encontró el recurso.';
      case 409: return 'Ya existe un registro con esos datos.';
      case 422: return 'Información inválida.';
      case 500:
      case 502:
      case 503: return 'Error en el servidor. Intenta más tarde.';
    }

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Sin respuesta del servidor. Verifica tu conexión.';
      case DioExceptionType.connectionError:
        return 'Sin conexión. Verifica tu red.';
      default:
        return 'Ocurrió un error inesperado.';
    }
  }
}

// Extrae el mensaje limpio de cualquier excepción
String friendlyError(Object e) {
  if (e is DioException) {
    return (e.error as String?) ?? WearApiClient._friendlyMessage(e);
  }
  return e.toString().replaceFirst('Exception: ', '');
}
