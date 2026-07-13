import '../model/perfil_usuario.dart';

abstract class PerfilUsuarioRepository {
  Future<List<PerfilUsuario>> listar();
  Future<PerfilUsuario> obtener(String id);
  Future<PerfilUsuario> crear(PerfilUsuario item);
  Future<PerfilUsuario> actualizar(String id, PerfilUsuario item);
  Future<void> eliminar(String id);
}
