import 'package:dio/dio.dart';
import '../../domain/model/equipaje.dart';
import '../../domain/repository/equipaje_repository.dart';

class EquipajeRepositoryImpl implements EquipajeRepository {
  final Dio _dio;
  EquipajeRepositoryImpl(this._dio);

  static const String _endpoint = '/equipajes/';

  @override
  Future<List<Equipaje>> listar() async {
    final res = await _dio.get(_endpoint);
    final data = res.data;
    final List<dynamic> lista = data is Map<String, dynamic>
        ? (data['resultados'] ?? data['results'] ?? []) as List<dynamic>
        : data as List<dynamic>;
    return lista.map((j) => Equipaje.fromJson(j as Map<String, dynamic>)).toList();
  }

  @override
  Future<Equipaje> obtener(int id) async {
    final res = await _dio.get('$_endpoint$id/');
    return Equipaje.fromJson(res.data as Map<String, dynamic>);
  }

  @override
  Future<Equipaje> crear(Equipaje item) async {
    final res = await _dio.post(_endpoint, data: item.toJson());
    return Equipaje.fromJson(res.data as Map<String, dynamic>);
  }

  @override
  Future<Equipaje> actualizar(int id, Equipaje item) async {
    final res = await _dio.put('$_endpoint$id/', data: item.toJson());
    return Equipaje.fromJson(res.data as Map<String, dynamic>);
  }

  @override
  Future<void> eliminar(int id) async {
    await _dio.delete('$_endpoint$id/');
  }
}
