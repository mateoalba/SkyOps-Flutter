import '../model/notificacion.dart';

abstract class NotificacionRepository {
  Future<List<Notificacion>> listar();
  Future<Notificacion> obtener(int id);
  Future<Notificacion> crear(Notificacion item);
  Future<Notificacion> actualizar(int id, Notificacion item);
  Future<void> eliminar(int id);
  Future<void> marcarLeida(int id);
}
