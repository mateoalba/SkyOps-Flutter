import '../model/pista.dart';

abstract class PistaRepository {
  Future<List<Pista>> listar();
  Future<Pista> obtener(String id);
  Future<Pista> crear(Pista item);
  Future<Pista> actualizar(String id, Pista item);
  Future<void> eliminar(String id);
}
