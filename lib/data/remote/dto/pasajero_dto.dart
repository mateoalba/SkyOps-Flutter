import '../../../domain/model/pasajero.dart';

/// DTO de transporte para Pasajero (misma forma que el modelo; punto
/// de extensión si el backend cambia de forma independiente del dominio).
class PasajeroDto {
  static Pasajero fromJson(Map<String, dynamic> json) => Pasajero.fromJson(json);
  static Map<String, dynamic> toJson(Pasajero item) => item.toJson();
}
