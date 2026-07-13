import '../model/aerolinea.dart';

abstract class AerolineaRepository {
  Future<List<Aerolinea>> listar();
  Future<Aerolinea> obtener(String id);
  Future<Aerolinea> crear(Aerolinea item);
  Future<Aerolinea> actualizar(String id, Aerolinea item);
  Future<void> eliminar(String id);
}
