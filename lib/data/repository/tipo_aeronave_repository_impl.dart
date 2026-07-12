import 'package:dio/dio.dart';
import '../../domain/model/tipo_aeronave.dart';
import '../../domain/repository/tipo_aeronave_repository.dart';

class TipoAeronaveRepositoryImpl implements TipoAeronaveRepository {
  final Dio _dio;
  TipoAeronaveRepositoryImpl(this._dio);

  static const String _endpoint = '/tipos-aeronave/';

  @override
  Future<List<TipoAeronave>> listar() async {
    final res = await _dio.get(_endpoint);
    final data = res.data;
    final List<dynamic> lista = data is Map<String, dynamic>
        ? (data['resultados'] ?? data['results'] ?? []) as List<dynamic>
        : data as List<dynamic>;
    return lista.map((j) => TipoAeronave.fromJson(j as Map<String, dynamic>)).toList();
  }

  @override
  Future<TipoAeronave> obtener(int id) async {
    final res = await _dio.get('$_endpoint$id/');
    return TipoAeronave.fromJson(res.data as Map<String, dynamic>);
  }

  @override
  Future<TipoAeronave> crear(TipoAeronave item) async {
    final res = await _dio.post(_endpoint, data: item.toJson());
    return TipoAeronave.fromJson(res.data as Map<String, dynamic>);
  }

  @override
  Future<TipoAeronave> actualizar(int id, TipoAeronave item) async {
    final res = await _dio.put('$_endpoint$id/', data: item.toJson());
    return TipoAeronave.fromJson(res.data as Map<String, dynamic>);
  }

  @override
  Future<void> eliminar(int id) async {
    await _dio.delete('$_endpoint$id/');
  }
}
