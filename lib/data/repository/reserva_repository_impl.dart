import 'package:dio/dio.dart';
import '../../domain/model/reserva.dart';
import '../../domain/repository/reserva_repository.dart';

class ReservaRepositoryImpl implements ReservaRepository {
  final Dio _dio;
  ReservaRepositoryImpl(this._dio);

  static const String _endpoint = '/reservas/';

  @override
  Future<List<Reserva>> listar() async {
    final res = await _dio.get(_endpoint);
    final data = res.data;
    final List<dynamic> lista = data is Map<String, dynamic>
        ? (data['resultados'] ?? data['results'] ?? []) as List<dynamic>
        : data as List<dynamic>;
    return lista.map((j) => Reserva.fromJson(j as Map<String, dynamic>)).toList();
  }

  @override
  Future<Reserva> obtener(String id) async {
    final res = await _dio.get('$_endpoint$id/');
    return Reserva.fromJson(res.data as Map<String, dynamic>);
  }

  @override
  Future<Reserva> crear(Reserva item) async {
    final res = await _dio.post(_endpoint, data: item.toJson());
    return Reserva.fromJson(res.data as Map<String, dynamic>);
  }

  @override
  Future<Reserva> actualizar(String id, Reserva item) async {
    final res = await _dio.put('$_endpoint$id/', data: item.toJson());
    return Reserva.fromJson(res.data as Map<String, dynamic>);
  }

  @override
  Future<void> eliminar(String id) async {
    await _dio.delete('$_endpoint$id/');
  }
}
