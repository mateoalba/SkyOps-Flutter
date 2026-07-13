import '../model/asignacion.dart';

abstract class AsignacionRepository {
  Future<List<Asignacion>> listar();
  Future<Asignacion> obtener(String id);
  Future<Asignacion> crear(Asignacion item);
  Future<Asignacion> actualizar(String id, Asignacion item);
  Future<void> eliminar(String id);
}
