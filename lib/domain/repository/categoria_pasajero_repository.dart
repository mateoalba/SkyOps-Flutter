import '../model/categoria_pasajero.dart';

abstract class CategoriaPasajeroRepository {
  Future<List<CategoriaPasajero>> listar();
  Future<CategoriaPasajero> obtener(int id);
  Future<CategoriaPasajero> crear(CategoriaPasajero item);
  Future<CategoriaPasajero> actualizar(int id, CategoriaPasajero item);
  Future<void> eliminar(int id);
}
