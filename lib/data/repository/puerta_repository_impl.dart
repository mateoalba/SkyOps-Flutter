import 'package:dio/dio.dart';
import '../../domain/model/puerta.dart';
import '../../domain/repository/puerta_repository.dart';

class PuertaRepositoryImpl implements PuertaRepository {
  final Dio _dio;
  PuertaRepositoryImpl(this._dio);

  static const String _endpoint = '/puertas/';

  @override
  Future<List<Puerta>> listar() async {
    final res = await _dio.get(_endpoint);
    final data = res.data;
    final List<dynamic> lista = data is Map<String, dynamic>
        ? (data['resultados'] ?? data['results'] ?? []) as List<dynamic>
        : data as List<dynamic>;
    return lista.map((j) => Puerta.fromJson(j as Map<String, dynamic>)).toList();
  }

  @override
  Future<Puerta> obtener(String id) async {
    final res = await _dio.get('$_endpoint$id/');
    return Puerta.fromJson(res.data as Map<String, dynamic>);
  }

  @override
  Future<Puerta> crear(Puerta item) async {
    final res = await _dio.post(_endpoint, data: item.toJson());
    return Puerta.fromJson(res.data as Map<String, dynamic>);
  }

  @override
  Future<Puerta> actualizar(String id, Puerta item) async {
    final res = await _dio.put('$_endpoint$id/', data: item.toJson());
    return Puerta.fromJson(res.data as Map<String, dynamic>);
  }

  @override
  Future<void> eliminar(String id) async {
    await _dio.delete('$_endpoint$id/');
  }
}
