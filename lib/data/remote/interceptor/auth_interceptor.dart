import 'package:dio/dio.dart';
import '../../local/secure_storage.dart';
import '../../../core/config/app_config.dart';

/// Adjunta el access token a cada request y refresca el token en un 401.
class AuthInterceptor extends Interceptor {
  final SecureStorage _secureStorage;
  final Dio _dioParaRefresh;
  bool _refrescando = false;

  AuthInterceptor(this._secureStorage, this._dioParaRefresh);

  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final rutasPublicas = [
      AppConfig.loginEndpoint,
      AppConfig.registroEndpoint,
      AppConfig.refreshEndpoint,
    ];
    final esPublica = rutasPublicas.any((ruta) => options.path.contains(ruta));

    if (!esPublica) {
      final token = await _secureStorage.obtenerAccessToken();
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    handler.next(options);
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    final esUnauthorized = err.response?.statusCode == 401;
    final esRefreshEndpoint = err.requestOptions.path.contains(AppConfig.refreshEndpoint);

    if (esUnauthorized && !esRefreshEndpoint && !_refrescando) {
      _refrescando = true;
      try {
        final refreshToken = await _secureStorage.obtenerRefreshToken();
        if (refreshToken == null) {
          _refrescando = false;
          return handler.next(err);
        }

        final response = await _dioParaRefresh.post(
          AppConfig.refreshEndpoint,
          data: {'refresh': refreshToken},
        );
        final nuevoAccess = response.data['access'] as String;
        await _secureStorage.guardarAccessToken(nuevoAccess);

        // Reintenta la petición original con el nuevo token
        final opts = err.requestOptions;
        opts.headers['Authorization'] = 'Bearer $nuevoAccess';
        final clone = await _dioParaRefresh.fetch(opts);
        _refrescando = false;
        return handler.resolve(clone);
      } catch (_) {
        await _secureStorage.limpiar();
        _refrescando = false;
        return handler.next(err);
      }
    }

    handler.next(err);
  }
}
