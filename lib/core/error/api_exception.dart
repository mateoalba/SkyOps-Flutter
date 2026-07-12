import 'package:dio/dio.dart';

/// Excepción compartida para todos los repositorios que consumen la API.
class ApiException implements Exception {
  final String mensaje;
  final int? codigoEstado;

  ApiException(this.mensaje, {this.codigoEstado});

  factory ApiException.fromDioException(DioException e) {
    final response = e.response;
    final data = response?.data;

    String mensaje = 'Ocurrió un error de conexión. Intenta nuevamente.';

    if (data is Map<String, dynamic>) {
      if (data['detail'] != null) {
        mensaje = data['detail'].toString();
      } else if (data.isNotEmpty) {
        // DRF suele devolver errores por campo: {"campo": ["mensaje"]}
        final primerCampo = data.entries.first;
        final valor = primerCampo.value;
        final detalle = valor is List ? valor.join(', ') : valor.toString();
        mensaje = '${primerCampo.key}: $detalle';
      }
    } else if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      mensaje = 'Tiempo de espera agotado. Verifica tu conexión.';
    } else if (e.type == DioExceptionType.connectionError) {
      mensaje = 'No se pudo conectar con el servidor de SkyOps.';
    }

    return ApiException(mensaje, codigoEstado: response?.statusCode);
  }

  @override
  String toString() => mensaje;
}
