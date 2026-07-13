import '../model/aeropuerto.dart';

abstract class AeropuertoRepository {
  Future<List<Aeropuerto>> listar();
  Future<Aeropuerto> obtener(String id);
  Future<Aeropuerto> crear(Aeropuerto item);
  Future<Aeropuerto> actualizar(String id, Aeropuerto item);
  Future<void> eliminar(String id);
}
