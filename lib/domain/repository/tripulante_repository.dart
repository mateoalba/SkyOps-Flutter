import '../model/tripulante.dart';

abstract class TripulanteRepository {
  Future<List<Tripulante>> listar();
  Future<Tripulante> obtener(String id);
  Future<Tripulante> crear(Tripulante item);
  Future<Tripulante> actualizar(String id, Tripulante item);
  Future<void> eliminar(String id);
}
