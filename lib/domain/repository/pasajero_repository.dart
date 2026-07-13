import '../model/pasajero.dart';

abstract class PasajeroRepository {
  Future<List<Pasajero>> listar();
  Future<Pasajero> obtener(String id);
  Future<Pasajero> crear(Pasajero item);
  Future<Pasajero> actualizar(String id, Pasajero item);
  Future<void> eliminar(String id);
}
