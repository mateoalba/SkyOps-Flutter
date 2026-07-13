import '../model/asignacion_pista.dart';

abstract class AsignacionPistaRepository {
  Future<List<AsignacionPista>> listar();
  Future<AsignacionPista> obtener(String id);
  Future<AsignacionPista> crear(AsignacionPista item);
  Future<AsignacionPista> actualizar(String id, AsignacionPista item);
  Future<void> eliminar(String id);
}
