import 'package:dio/dio.dart';
import '../../domain/model/perfil_usuario.dart';
import '../../domain/repository/perfil_usuario_repository.dart';

class PerfilUsuarioRepositoryImpl implements PerfilUsuarioRepository {
  final Dio _dio;
  PerfilUsuarioRepositoryImpl(this._dio);

  static const String _endpoint = '/perfiles-usuario/';

  @override
  Future<List<PerfilUsuario>> listar() async {
    final res = await _dio.get(_endpoint);
    final data = res.data;
    final List<dynamic> lista = data is Map<String, dynamic>
        ? (data['resultados'] ?? data['results'] ?? []) as List<dynamic>
        : data as List<dynamic>;
    return lista.map((j) => PerfilUsuario.fromJson(j as Map<String, dynamic>)).toList();
  }

  @override
  Future<PerfilUsuario> obtener(String id) async {
    final res = await _dio.get('$_endpoint$id/');
    return PerfilUsuario.fromJson(res.data as Map<String, dynamic>);
  }

  @override
  Future<PerfilUsuario> crear(PerfilUsuario item) async {
    final res = await _dio.post(_endpoint, data: item.toJson());
    return PerfilUsuario.fromJson(res.data as Map<String, dynamic>);
  }

  @override
  Future<PerfilUsuario> actualizar(String id, PerfilUsuario item) async {
    final res = await _dio.put('$_endpoint$id/', data: item.toJson());
    return PerfilUsuario.fromJson(res.data as Map<String, dynamic>);
  }

  @override
  Future<void> eliminar(String id) async {
    await _dio.delete('$_endpoint$id/');
  }
}
