import '../model/equipaje.dart';

abstract class EquipajeRepository {
  Future<List<Equipaje>> listar();
  Future<Equipaje> obtener(int id);
  Future<Equipaje> crear(Equipaje item);
  Future<Equipaje> actualizar(int id, Equipaje item);
  Future<void> eliminar(int id);
}
