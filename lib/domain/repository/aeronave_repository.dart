import '../model/aeronave.dart';

abstract class AeronaveRepository {
  Future<List<Aeronave>> listar();
  Future<Aeronave> obtener(String id);
  Future<Aeronave> crear(Aeronave item);
  Future<Aeronave> actualizar(String id, Aeronave item);
  Future<void> eliminar(String id);
}
