import '../model/puerta.dart';

abstract class PuertaRepository {
  Future<List<Puerta>> listar();
  Future<Puerta> obtener(String id);
  Future<Puerta> crear(Puerta item);
  Future<Puerta> actualizar(String id, Puerta item);
  Future<void> eliminar(String id);
}
