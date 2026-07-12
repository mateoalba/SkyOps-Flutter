import 'package:dio/dio.dart';
import '../../domain/model/aeronave.dart';
import '../../domain/repository/aeronave_repository.dart';

class AeronaveRepositoryImpl implements AeronaveRepository {
  final Dio _dio;
  AeronaveRepositoryImpl(this._dio);

  static const String _endpoint = '/aeronaves/';

  @override
  Future<List<Aeronave>> listar() async {
    final res = await _dio.get(_endpoint);
    final data = res.data;
    final List<dynamic> lista = data is Map<String, dynamic>
        ? (data['resultados'] ?? data['results'] ?? []) as List<dynamic>
        : data as List<dynamic>;
    return lista.map((j) => Aeronave.fromJson(j as Map<String, dynamic>)).toList();
  }

  @override
  Future<Aeronave> obtener(String id) async {
    final res = await _dio.get('$_endpoint$id/');
    return Aeronave.fromJson(res.data as Map<String, dynamic>);
  }

  @override
  Future<Aeronave> crear(Aeronave item) async {
    final res = await _dio.post(_endpoint, data: item.toJson());
    return Aeronave.fromJson(res.data as Map<String, dynamic>);
  }

  @override
  Future<Aeronave> actualizar(String id, Aeronave item) async {
    final res = await _dio.put('$_endpoint$id/', data: item.toJson());
    return Aeronave.fromJson(res.data as Map<String, dynamic>);
  }

  @override
  Future<void> eliminar(String id) async {
    await _dio.delete('$_endpoint$id/');
  }
}
