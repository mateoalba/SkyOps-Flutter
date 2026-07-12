import '../../../domain/model/audit_log.dart';

/// DTO de transporte para AuditLog (misma forma que el modelo; punto
/// de extensión si el backend cambia de forma independiente del dominio).
class AuditLogDto {
  static AuditLog fromJson(Map<String, dynamic> json) => AuditLog.fromJson(json);
  static Map<String, dynamic> toJson(AuditLog item) => item.toJson();
}
