import '../model/mantenimiento.dart';

abstract class MantenimientoRepository {
  Future<List<Mantenimiento>> listar();
  Future<Mantenimiento> obtener(String id);
  Future<Mantenimiento> crear(Mantenimiento item);
  Future<Mantenimiento> actualizar(String id, Mantenimiento item);
  Future<void> eliminar(String id);
}
