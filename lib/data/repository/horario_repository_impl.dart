import 'package:dio/dio.dart';
import '../../domain/model/horario.dart';
import '../../domain/repository/horario_repository.dart';

class HorarioRepositoryImpl implements HorarioRepository {
  final Dio _dio;
  HorarioRepositoryImpl(this._dio);

  static const String _endpoint = '/horarios/';

  @override
  Future<List<Horario>> listar() async {
    final res = await _dio.get(_endpoint);
    final data = res.data;
    final List<dynamic> lista = data is Map<String, dynamic>
        ? (data['resultados'] ?? data['results'] ?? []) as List<dynamic>
        : data as List<dynamic>;
    return lista.map((j) => Horario.fromJson(j as Map<String, dynamic>)).toList();
  }

  @override
  Future<Horario> obtener(String id) async {
    final res = await _dio.get('$_endpoint$id/');
    return Horario.fromJson(res.data as Map<String, dynamic>);
  }

  @override
  Future<Horario> crear(Horario item) async {
    final res = await _dio.post(_endpoint, data: item.toJson());
    return Horario.fromJson(res.data as Map<String, dynamic>);
  }

  @override
  Future<Horario> actualizar(String id, Horario item) async {
    final res = await _dio.put('$_endpoint$id/', data: item.toJson());
    return Horario.fromJson(res.data as Map<String, dynamic>);
  }

  @override
  Future<void> eliminar(String id) async {
    await _dio.delete('$_endpoint$id/');
  }
}
