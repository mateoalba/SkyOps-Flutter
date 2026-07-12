import 'package:dio/dio.dart';
import '../../domain/model/terminal.dart';
import '../../domain/repository/terminal_repository.dart';

class TerminalRepositoryImpl implements TerminalRepository {
  final Dio _dio;
  TerminalRepositoryImpl(this._dio);

  static const String _endpoint = '/terminales/';

  @override
  Future<List<Terminal>> listar() async {
    final res = await _dio.get(_endpoint);
    final data = res.data;
    final List<dynamic> lista = data is Map<String, dynamic>
        ? (data['resultados'] ?? data['results'] ?? []) as List<dynamic>
        : data as List<dynamic>;
    return lista.map((j) => Terminal.fromJson(j as Map<String, dynamic>)).toList();
  }

  @override
  Future<Terminal> obtener(String id) async {
    final res = await _dio.get('$_endpoint$id/');
    return Terminal.fromJson(res.data as Map<String, dynamic>);
  }

  @override
  Future<Terminal> crear(Terminal item) async {
    final res = await _dio.post(_endpoint, data: item.toJson());
    return Terminal.fromJson(res.data as Map<String, dynamic>);
  }

  @override
  Future<Terminal> actualizar(String id, Terminal item) async {
    final res = await _dio.put('$_endpoint$id/', data: item.toJson());
    return Terminal.fromJson(res.data as Map<String, dynamic>);
  }

  @override
  Future<void> eliminar(String id) async {
    await _dio.delete('$_endpoint$id/');
  }
}
