import 'package:dio/dio.dart';
import '../../domain/model/notificacion.dart';
import '../../domain/repository/notificacion_repository.dart';

class NotificacionRepositoryImpl implements NotificacionRepository {
  final Dio _dio;
  NotificacionRepositoryImpl(this._dio);

  static const String _endpoint = '/notificaciones/';

  @override
  Future<List<Notificacion>> listar() async {
    final res = await _dio.get(_endpoint);
    final data = res.data;
    final List<dynamic> lista = data is Map<String, dynamic>
        ? (data['resultados'] ?? data['results'] ?? []) as List<dynamic>
        : data as List<dynamic>;
    return lista.map((j) => Notificacion.fromJson(j as Map<String, dynamic>)).toList();
  }

  @override
  Future<Notificacion> obtener(int id) async {
    final res = await _dio.get('$_endpoint$id/');
    return Notificacion.fromJson(res.data as Map<String, dynamic>);
  }

  @override
  Future<Notificacion> crear(Notificacion item) async {
    final res = await _dio.post(_endpoint, data: item.toJson());
    return Notificacion.fromJson(res.data as Map<String, dynamic>);
  }

  @override
  Future<Notificacion> actualizar(int id, Notificacion item) async {
    final res = await _dio.put('$_endpoint$id/', data: item.toJson());
    return Notificacion.fromJson(res.data as Map<String, dynamic>);
  }

  @override
  Future<void> eliminar(int id) async {
    await _dio.delete('$_endpoint$id/');
  }

  @override
  Future<void> marcarLeida(int id) async {
    await _dio.post('$_endpoint$id/marcar-leida/');
  }
}
