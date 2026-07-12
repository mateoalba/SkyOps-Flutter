import '../../../domain/model/equipaje.dart';

/// DTO de transporte para Equipaje (misma forma que el modelo; punto
/// de extensión si el backend cambia de forma independiente del dominio).
class EquipajeDto {
  static Equipaje fromJson(Map<String, dynamic> json) => Equipaje.fromJson(json);
  static Map<String, dynamic> toJson(Equipaje item) => item.toJson();
}
