import '../../../domain/model/asignacion.dart';

/// DTO de transporte para Asignacion (misma forma que el modelo; punto
/// de extensión si el backend cambia de forma independiente del dominio).
class AsignacionDto {
  static Asignacion fromJson(Map<String, dynamic> json) => Asignacion.fromJson(json);
  static Map<String, dynamic> toJson(Asignacion item) => item.toJson();
}
