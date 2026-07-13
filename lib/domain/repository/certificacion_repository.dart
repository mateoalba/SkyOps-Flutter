import '../model/certificacion.dart';

abstract class CertificacionRepository {
  Future<List<Certificacion>> listar();
  Future<Certificacion> obtener(String id);
  Future<Certificacion> crear(Certificacion item);
  Future<Certificacion> actualizar(String id, Certificacion item);
  Future<void> eliminar(String id);
}
