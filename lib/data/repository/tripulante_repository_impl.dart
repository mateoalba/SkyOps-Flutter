import 'package:dio/dio.dart';
import '../../domain/model/tripulante.dart';
import '../../domain/repository/tripulante_repository.dart';

class TripulanteRepositoryImpl implements TripulanteRepository {
  final Dio _dio;
  TripulanteRepositoryImpl(this._dio);

  static const String _endpoint = '/tripulantes/';

  @override
  Future<List<Tripulante>> listar() async {
    final res = await _dio.get(_endpoint);
    final data = res.data;
    final List<dynamic> lista = data is Map<String, dynamic>
        ? (data['resultados'] ?? data['results'] ?? []) as List<dynamic>
        : data as List<dynamic>;
    return lista.map((j) => Tripulante.fromJson(j as Map<String, dynamic>)).toList();
  }

  @override
  Future<Tripulante> obtener(String id) async {
    final res = await _dio.get('$_endpoint$id/');
    return Tripulante.fromJson(res.data as Map<String, dynamic>);
  }

  @override
  Future<Tripulante> crear(Tripulante item) async {
    final res = await _dio.post(_endpoint, data: item.toJson());
    return Tripulante.fromJson(res.data as Map<String, dynamic>);
  }

  @override
  Future<Tripulante> actualizar(String id, Tripulante item) async {
    final res = await _dio.put('$_endpoint$id/', data: item.toJson());
    return Tripulante.fromJson(res.data as Map<String, dynamic>);
  }

  @override
  Future<void> eliminar(String id) async {
    await _dio.delete('$_endpoint$id/');
  }
}
