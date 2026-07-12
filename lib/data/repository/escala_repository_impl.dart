import 'package:dio/dio.dart';
import '../../domain/model/escala.dart';
import '../../domain/repository/escala_repository.dart';

class EscalaRepositoryImpl implements EscalaRepository {
  final Dio _dio;
  EscalaRepositoryImpl(this._dio);

  static const String _endpoint = '/escalas/';

  @override
  Future<List<Escala>> listar() async {
    final res = await _dio.get(_endpoint);
    final data = res.data;
    final List<dynamic> lista = data is Map<String, dynamic>
        ? (data['resultados'] ?? data['results'] ?? []) as List<dynamic>
        : data as List<dynamic>;
    return lista.map((j) => Escala.fromJson(j as Map<String, dynamic>)).toList();
  }

  @override
  Future<Escala> obtener(String id) async {
    final res = await _dio.get('$_endpoint$id/');
    return Escala.fromJson(res.data as Map<String, dynamic>);
  }

  @override
  Future<Escala> crear(Escala item) async {
    final res = await _dio.post(_endpoint, data: item.toJson());
    return Escala.fromJson(res.data as Map<String, dynamic>);
  }

  @override
  Future<Escala> actualizar(String id, Escala item) async {
    final res = await _dio.put('$_endpoint$id/', data: item.toJson());
    return Escala.fromJson(res.data as Map<String, dynamic>);
  }

  @override
  Future<void> eliminar(String id) async {
    await _dio.delete('$_endpoint$id/');
  }
}
