import '../model/incidente.dart';

abstract class IncidenteRepository {
  Future<List<Incidente>> listar();
  Future<Incidente> obtener(String id);
  Future<Incidente> crear(Incidente item);
  Future<Incidente> actualizar(String id, Incidente item);
  Future<void> eliminar(String id);
}
