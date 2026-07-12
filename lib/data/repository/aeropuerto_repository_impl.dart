import 'package:dio/dio.dart';
import '../../domain/model/aeropuerto.dart';
import '../../domain/repository/aeropuerto_repository.dart';

class AeropuertoRepositoryImpl implements AeropuertoRepository {
  final Dio _dio;
  AeropuertoRepositoryImpl(this._dio);

  static const String _endpoint = '/aeropuertos/';

  @override
  Future<List<Aeropuerto>> listar() async {
    final res = await _dio.get(_endpoint);
    final data = res.data;
    final List<dynamic> lista = data is Map<String, dynamic>
        ? (data['resultados'] ?? data['results'] ?? []) as List<dynamic>
        : data as List<dynamic>;
    return lista.map((j) => Aeropuerto.fromJson(j as Map<String, dynamic>)).toList();
  }

  @override
  Future<Aeropuerto> obtener(String id) async {
    final res = await _dio.get('$_endpoint$id/');
    return Aeropuerto.fromJson(res.data as Map<String, dynamic>);
  }

  @override
  Future<Aeropuerto> crear(Aeropuerto item) async {
    final res = await _dio.post(_endpoint, data: item.toJson());
    return Aeropuerto.fromJson(res.data as Map<String, dynamic>);
  }

  @override
  Future<Aeropuerto> actualizar(String id, Aeropuerto item) async {
    final res = await _dio.put('$_endpoint$id/', data: item.toJson());
    return Aeropuerto.fromJson(res.data as Map<String, dynamic>);
  }

  @override
  Future<void> eliminar(String id) async {
    await _dio.delete('$_endpoint$id/');
  }
}
