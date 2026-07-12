import '../../../domain/model/incidente.dart';

/// DTO de transporte para Incidente (misma forma que el modelo; punto
/// de extensión si el backend cambia de forma independiente del dominio).
class IncidenteDto {
  static Incidente fromJson(Map<String, dynamic> json) => Incidente.fromJson(json);
  static Map<String, dynamic> toJson(Incidente item) => item.toJson();
}
