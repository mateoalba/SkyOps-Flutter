import 'package:dio/dio.dart';
import '../../domain/model/aerolinea.dart';
import '../../domain/repository/aerolinea_repository.dart';

class AerolineaRepositoryImpl implements AerolineaRepository {
  final Dio _dio;
  AerolineaRepositoryImpl(this._dio);

  static const String _endpoint = '/aerolineas/';

  @override
  Future<List<Aerolinea>> listar() async {
    final res = await _dio.get(_endpoint);
    final data = res.data;
    final List<dynamic> lista = data is Map<String, dynamic>
        ? (data['resultados'] ?? data['results'] ?? []) as List<dynamic>
        : data as List<dynamic>;
    return lista.map((j) => Aerolinea.fromJson(j as Map<String, dynamic>)).toList();
  }

  @override
  Future<Aerolinea> obtener(String id) async {
    final res = await _dio.get('$_endpoint$id/');
    return Aerolinea.fromJson(res.data as Map<String, dynamic>);
  }

  @override
  Future<Aerolinea> crear(Aerolinea item) async {
    final res = await _dio.post(_endpoint, data: item.toJson());
    return Aerolinea.fromJson(res.data as Map<String, dynamic>);
  }

  @override
  Future<Aerolinea> actualizar(String id, Aerolinea item) async {
    final res = await _dio.put('$_endpoint$id/', data: item.toJson());
    return Aerolinea.fromJson(res.data as Map<String, dynamic>);
  }

  @override
  Future<void> eliminar(String id) async {
    await _dio.delete('$_endpoint$id/');
  }
}
