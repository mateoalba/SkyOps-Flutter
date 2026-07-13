import '../model/sesion_usuario.dart';

abstract class SesionUsuarioRepository {
  Future<List<SesionUsuario>> listar();
  Future<SesionUsuario> obtener(String id);
  Future<SesionUsuario> crear(SesionUsuario item);
  Future<SesionUsuario> actualizar(String id, SesionUsuario item);
  Future<void> eliminar(String id);
}
