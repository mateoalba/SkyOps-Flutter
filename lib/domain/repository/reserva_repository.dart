import '../model/reserva.dart';

abstract class ReservaRepository {
  Future<List<Reserva>> listar();
  Future<Reserva> obtener(String id);
  Future<Reserva> crear(Reserva item);
  Future<Reserva> actualizar(String id, Reserva item);
  Future<void> eliminar(String id);
}
