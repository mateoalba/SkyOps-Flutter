import 'package:dio/dio.dart';
import '../../../core/config/app_config.dart';
import '../../local/secure_storage.dart';
import '../interceptor/auth_interceptor.dart';

/// Fabrica la instancia de Dio usada por todos los repositorios,
/// con la URL base de SkyOps y el interceptor de autenticación/refresh.
class DioClient {
  static Dio crear(SecureStorage secureStorage) {
    final dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.baseUrl,
        connectTimeout: AppConfig.connectTimeout,
        receiveTimeout: AppConfig.receiveTimeout,
        headers: {'Content-Type': 'application/json'},
      ),
    );

    // Dio independiente (sin interceptores) para las llamadas de refresh,
    // así se evita un bucle infinito de reintentos.
    final dioRefresh = Dio(
      BaseOptions(
        baseUrl: AppConfig.baseUrl,
        connectTimeout: AppConfig.connectTimeout,
        receiveTimeout: AppConfig.receiveTimeout,
        headers: {'Content-Type': 'application/json'},
      ),
    );

    dio.interceptors.add(AuthInterceptor(secureStorage, dioRefresh));

    // Convierte los errores de Dio en un mensaje legible tomado del cuerpo
    // de la respuesta del backend (en vez del texto genérico de Dio).
    dio.interceptors.add(
      InterceptorsWrapper(
        onError: (DioException err, handler) {
          handler.next(err.copyWith(message: _mensajeAmigable(err)));
        },
      ),
    );

    if (const bool.fromEnvironment('dart.vm.product') == false) {
      dio.interceptors.add(LogInterceptor(requestBody: true, responseBody: true));
    }

    return dio;
  }

  static String _mensajeAmigable(DioException err) {
    final data = err.response?.data;
    if (data is Map) {
      final partes = <String>[];
      data.forEach((campo, valor) {
        final texto = valor is List ? valor.join(', ') : valor.toString();
        if (campo == 'detail' || campo == 'non_field_errors') {
          partes.add(texto);
        } else {
          partes.add('$campo: $texto');
        }
      });
      if (partes.isNotEmpty) return partes.join(' | ');
    } else if (data is String && data.trim().isNotEmpty) {
      return data;
    }
    return err.message ?? 'No se pudo conectar con el servidor.';
  }
}
