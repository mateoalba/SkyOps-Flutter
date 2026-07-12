import '../../../domain/model/mantenimiento.dart';

/// DTO de transporte para Mantenimiento (misma forma que el modelo; punto
/// de extensión si el backend cambia de forma independiente del dominio).
class MantenimientoDto {
  static Mantenimiento fromJson(Map<String, dynamic> json) => Mantenimiento.fromJson(json);
  static Map<String, dynamic> toJson(Mantenimiento item) => item.toJson();
}
