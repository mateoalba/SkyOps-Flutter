import '../model/horario.dart';

abstract class HorarioRepository {
  Future<List<Horario>> listar();
  Future<Horario> obtener(String id);
  Future<Horario> crear(Horario item);
  Future<Horario> actualizar(String id, Horario item);
  Future<void> eliminar(String id);
}
