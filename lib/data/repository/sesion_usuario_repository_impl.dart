import 'package:dio/dio.dart';
import '../../domain/model/sesion_usuario.dart';
import '../../domain/repository/sesion_usuario_repository.dart';

class SesionUsuarioRepositoryImpl implements SesionUsuarioRepository {
  final Dio _dio;
  SesionUsuarioRepositoryImpl(this._dio);

  static const String _endpoint = '/sesiones-usuario/';

  @override
  Future<List<SesionUsuario>> listar() async {
    final res = await _dio.get(_endpoint);
    final data = res.data;
    final List<dynamic> lista = data is Map<String, dynamic>
        ? (data['resultados'] ?? data['results'] ?? []) as List<dynamic>
        : data as List<dynamic>;
    return lista.map((j) => SesionUsuario.fromJson(j as Map<String, dynamic>)).toList();
  }

  @override
  Future<SesionUsuario> obtener(String id) async {
    final res = await _dio.get('$_endpoint$id/');
    return SesionUsuario.fromJson(res.data as Map<String, dynamic>);
  }

  @override
  Future<SesionUsuario> crear(SesionUsuario item) async {
    final res = await _dio.post(_endpoint, data: item.toJson());
    return SesionUsuario.fromJson(res.data as Map<String, dynamic>);
  }

  @override
  Future<SesionUsuario> actualizar(String id, SesionUsuario item) async {
    final res = await _dio.put('$_endpoint$id/', data: item.toJson());
    return SesionUsuario.fromJson(res.data as Map<String, dynamic>);
  }

  @override
  Future<void> eliminar(String id) async {
    await _dio.delete('$_endpoint$id/');
  }
}
