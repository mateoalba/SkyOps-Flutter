import 'package:dio/dio.dart';
import '../../domain/model/asignacion.dart';
import '../../domain/repository/asignacion_repository.dart';

class AsignacionRepositoryImpl implements AsignacionRepository {
  final Dio _dio;
  AsignacionRepositoryImpl(this._dio);

  static const String _endpoint = '/asignaciones/';

  @override
  Future<List<Asignacion>> listar() async {
    final res = await _dio.get(_endpoint);
    final data = res.data;
    final List<dynamic> lista = data is Map<String, dynamic>
        ? (data['resultados'] ?? data['results'] ?? []) as List<dynamic>
        : data as List<dynamic>;
    return lista.map((j) => Asignacion.fromJson(j as Map<String, dynamic>)).toList();
  }

  @override
  Future<Asignacion> obtener(String id) async {
    final res = await _dio.get('$_endpoint$id/');
    return Asignacion.fromJson(res.data as Map<String, dynamic>);
  }

  @override
  Future<Asignacion> crear(Asignacion item) async {
    final res = await _dio.post(_endpoint, data: item.toJson());
    return Asignacion.fromJson(res.data as Map<String, dynamic>);
  }

  @override
  Future<Asignacion> actualizar(String id, Asignacion item) async {
    final res = await _dio.put('$_endpoint$id/', data: item.toJson());
    return Asignacion.fromJson(res.data as Map<String, dynamic>);
  }

  @override
  Future<void> eliminar(String id) async {
    await _dio.delete('$_endpoint$id/');
  }
}
