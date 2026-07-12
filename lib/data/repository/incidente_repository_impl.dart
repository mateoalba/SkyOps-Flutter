import 'package:dio/dio.dart';
import '../../domain/model/incidente.dart';
import '../../domain/repository/incidente_repository.dart';

class IncidenteRepositoryImpl implements IncidenteRepository {
  final Dio _dio;
  IncidenteRepositoryImpl(this._dio);

  static const String _endpoint = '/incidentes/';

  @override
  Future<List<Incidente>> listar() async {
    final res = await _dio.get(_endpoint);
    final data = res.data;
    final List<dynamic> lista = data is Map<String, dynamic>
        ? (data['resultados'] ?? data['results'] ?? []) as List<dynamic>
        : data as List<dynamic>;
    return lista.map((j) => Incidente.fromJson(j as Map<String, dynamic>)).toList();
  }

  @override
  Future<Incidente> obtener(String id) async {
    final res = await _dio.get('$_endpoint$id/');
    return Incidente.fromJson(res.data as Map<String, dynamic>);
  }

  @override
  Future<Incidente> crear(Incidente item) async {
    final res = await _dio.post(_endpoint, data: item.toJson());
    return Incidente.fromJson(res.data as Map<String, dynamic>);
  }

  @override
  Future<Incidente> actualizar(String id, Incidente item) async {
    final res = await _dio.put('$_endpoint$id/', data: item.toJson());
    return Incidente.fromJson(res.data as Map<String, dynamic>);
  }

  @override
  Future<void> eliminar(String id) async {
    await _dio.delete('$_endpoint$id/');
  }
}
