import '../../../domain/model/aeropuerto.dart';

/// DTO de transporte para Aeropuerto (misma forma que el modelo; punto
/// de extensión si el backend cambia de forma independiente del dominio).
class AeropuertoDto {
  static Aeropuerto fromJson(Map<String, dynamic> json) => Aeropuerto.fromJson(json);
  static Map<String, dynamic> toJson(Aeropuerto item) => item.toJson();
}
