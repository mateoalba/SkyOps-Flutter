import 'package:dio/dio.dart';
import '../../domain/model/mantenimiento.dart';
import '../../domain/repository/mantenimiento_repository.dart';

class MantenimientoRepositoryImpl implements MantenimientoRepository {
  final Dio _dio;
  MantenimientoRepositoryImpl(this._dio);

  static const String _endpoint = '/mantenimientos/';

  @override
  Future<List<Mantenimiento>> listar() async {
    final res = await _dio.get(_endpoint);
    final data = res.data;
    final List<dynamic> lista = data is Map<String, dynamic>
        ? (data['resultados'] ?? data['results'] ?? []) as List<dynamic>
        : data as List<dynamic>;
    return lista.map((j) => Mantenimiento.fromJson(j as Map<String, dynamic>)).toList();
  }

  @override
  Future<Mantenimiento> obtener(String id) async {
    final res = await _dio.get('$_endpoint$id/');
    return Mantenimiento.fromJson(res.data as Map<String, dynamic>);
  }

  @override
  Future<Mantenimiento> crear(Mantenimiento item) async {
    final res = await _dio.post(_endpoint, data: item.toJson());
    return Mantenimiento.fromJson(res.data as Map<String, dynamic>);
  }

  @override
  Future<Mantenimiento> actualizar(String id, Mantenimiento item) async {
    final res = await _dio.put('$_endpoint$id/', data: item.toJson());
    return Mantenimiento.fromJson(res.data as Map<String, dynamic>);
  }

  @override
  Future<void> eliminar(String id) async {
    await _dio.delete('$_endpoint$id/');
  }
}
