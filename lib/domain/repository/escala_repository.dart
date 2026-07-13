import '../model/escala.dart';

abstract class EscalaRepository {
  Future<List<Escala>> listar();
  Future<Escala> obtener(String id);
  Future<Escala> crear(Escala item);
  Future<Escala> actualizar(String id, Escala item);
  Future<void> eliminar(String id);
}
