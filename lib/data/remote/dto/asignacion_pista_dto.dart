import '../../../domain/model/asignacion_pista.dart';

/// DTO de transporte para AsignacionPista (misma forma que el modelo; punto
/// de extensión si el backend cambia de forma independiente del dominio).
class AsignacionPistaDto {
  static AsignacionPista fromJson(Map<String, dynamic> json) => AsignacionPista.fromJson(json);
  static Map<String, dynamic> toJson(AsignacionPista item) => item.toJson();
}
