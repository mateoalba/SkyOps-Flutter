import 'package:dio/dio.dart';
import '../../domain/model/categoria_pasajero.dart';
import '../../domain/repository/categoria_pasajero_repository.dart';

class CategoriaPasajeroRepositoryImpl implements CategoriaPasajeroRepository {
  final Dio _dio;
  CategoriaPasajeroRepositoryImpl(this._dio);

  static const String _endpoint = '/categorias-pasajero/';

  @override
  Future<List<CategoriaPasajero>> listar() async {
    final res = await _dio.get(_endpoint);
    final data = res.data;
    final List<dynamic> lista = data is Map<String, dynamic>
        ? (data['resultados'] ?? data['results'] ?? []) as List<dynamic>
        : data as List<dynamic>;
    return lista.map((j) => CategoriaPasajero.fromJson(j as Map<String, dynamic>)).toList();
  }

  @override
  Future<CategoriaPasajero> obtener(int id) async {
    final res = await _dio.get('$_endpoint$id/');
    return CategoriaPasajero.fromJson(res.data as Map<String, dynamic>);
  }

  @override
  Future<CategoriaPasajero> crear(CategoriaPasajero item) async {
    final res = await _dio.post(_endpoint, data: item.toJson());
    return CategoriaPasajero.fromJson(res.data as Map<String, dynamic>);
  }

  @override
  Future<CategoriaPasajero> actualizar(int id, CategoriaPasajero item) async {
    final res = await _dio.put('$_endpoint$id/', data: item.toJson());
    return CategoriaPasajero.fromJson(res.data as Map<String, dynamic>);
  }

  @override
  Future<void> eliminar(int id) async {
    await _dio.delete('$_endpoint$id/');
  }
}
