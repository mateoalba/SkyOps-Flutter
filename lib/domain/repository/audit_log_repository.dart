import '../model/audit_log.dart';

abstract class AuditLogRepository {
  Future<List<AuditLog>> listar();
  Future<AuditLog> obtener(String id);
  Future<AuditLog> crear(AuditLog item);
  Future<AuditLog> actualizar(String id, AuditLog item);
  Future<void> eliminar(String id);
}
