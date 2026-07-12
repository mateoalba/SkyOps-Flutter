import 'package:dio/dio.dart';
import '../../domain/model/pista.dart';
import '../../domain/repository/pista_repository.dart';

class PistaRepositoryImpl implements PistaRepository {
  final Dio _dio;
  PistaRepositoryImpl(this._dio);

  static const String _endpoint = '/pistas/';

  @override
  Future<List<Pista>> listar() async {
    final res = await _dio.get(_endpoint);
    final data = res.data;
    final List<dynamic> lista = data is Map<String, dynamic>
        ? (data['resultados'] ?? data['results'] ?? []) as List<dynamic>
        : data as List<dynamic>;
    return lista.map((j) => Pista.fromJson(j as Map<String, dynamic>)).toList();
  }

  @override
  Future<Pista> obtener(String id) async {
    final res = await _dio.get('$_endpoint$id/');
    return Pista.fromJson(res.data as Map<String, dynamic>);
  }

  @override
  Future<Pista> crear(Pista item) async {
    final res = await _dio.post(_endpoint, data: item.toJson());
    return Pista.fromJson(res.data as Map<String, dynamic>);
  }

  @override
  Future<Pista> actualizar(String id, Pista item) async {
    final res = await _dio.put('$_endpoint$id/', data: item.toJson());
    return Pista.fromJson(res.data as Map<String, dynamic>);
  }

  @override
  Future<void> eliminar(String id) async {
    await _dio.delete('$_endpoint$id/');
  }
}
