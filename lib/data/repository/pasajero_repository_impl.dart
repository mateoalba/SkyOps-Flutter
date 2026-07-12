import 'package:dio/dio.dart';
import '../../domain/model/pasajero.dart';
import '../../domain/repository/pasajero_repository.dart';

class PasajeroRepositoryImpl implements PasajeroRepository {
  final Dio _dio;
  PasajeroRepositoryImpl(this._dio);

  static const String _endpoint = '/pasajeros/';

  @override
  Future<List<Pasajero>> listar() async {
    final res = await _dio.get(_endpoint);
    final data = res.data;
    final List<dynamic> lista = data is Map<String, dynamic>
        ? (data['resultados'] ?? data['results'] ?? []) as List<dynamic>
        : data as List<dynamic>;
    return lista.map((j) => Pasajero.fromJson(j as Map<String, dynamic>)).toList();
  }

  @override
  Future<Pasajero> obtener(String id) async {
    final res = await _dio.get('$_endpoint$id/');
    return Pasajero.fromJson(res.data as Map<String, dynamic>);
  }

  @override
  Future<Pasajero> crear(Pasajero item) async {
    final res = await _dio.post(_endpoint, data: item.toJson());
    return Pasajero.fromJson(res.data as Map<String, dynamic>);
  }

  @override
  Future<Pasajero> actualizar(String id, Pasajero item) async {
    final res = await _dio.put('$_endpoint$id/', data: item.toJson());
    return Pasajero.fromJson(res.data as Map<String, dynamic>);
  }

  @override
  Future<void> eliminar(String id) async {
    await _dio.delete('$_endpoint$id/');
  }
}
