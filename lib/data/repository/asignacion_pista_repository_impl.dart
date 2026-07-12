import 'package:dio/dio.dart';
import '../../domain/model/asignacion_pista.dart';
import '../../domain/repository/asignacion_pista_repository.dart';

class AsignacionPistaRepositoryImpl implements AsignacionPistaRepository {
  final Dio _dio;
  AsignacionPistaRepositoryImpl(this._dio);

  static const String _endpoint = '/asignaciones-pista/';

  @override
  Future<List<AsignacionPista>> listar() async {
    final res = await _dio.get(_endpoint);
    final data = res.data;
    final List<dynamic> lista = data is Map<String, dynamic>
        ? (data['resultados'] ?? data['results'] ?? []) as List<dynamic>
        : data as List<dynamic>;
    return lista.map((j) => AsignacionPista.fromJson(j as Map<String, dynamic>)).toList();
  }

  @override
  Future<AsignacionPista> obtener(String id) async {
    final res = await _dio.get('$_endpoint$id/');
    return AsignacionPista.fromJson(res.data as Map<String, dynamic>);
  }

  @override
  Future<AsignacionPista> crear(AsignacionPista item) async {
    final res = await _dio.post(_endpoint, data: item.toJson());
    return AsignacionPista.fromJson(res.data as Map<String, dynamic>);
  }

  @override
  Future<AsignacionPista> actualizar(String id, AsignacionPista item) async {
    final res = await _dio.put('$_endpoint$id/', data: item.toJson());
    return AsignacionPista.fromJson(res.data as Map<String, dynamic>);
  }

  @override
  Future<void> eliminar(String id) async {
    await _dio.delete('$_endpoint$id/');
  }
}
