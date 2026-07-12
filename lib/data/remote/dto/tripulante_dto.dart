import '../../../domain/model/tripulante.dart';

/// DTO de transporte para Tripulante (misma forma que el modelo; punto
/// de extensión si el backend cambia de forma independiente del dominio).
class TripulanteDto {
  static Tripulante fromJson(Map<String, dynamic> json) => Tripulante.fromJson(json);
  static Map<String, dynamic> toJson(Tripulante item) => item.toJson();
}
