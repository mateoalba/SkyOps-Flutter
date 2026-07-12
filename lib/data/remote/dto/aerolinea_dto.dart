import '../../../domain/model/aerolinea.dart';

/// DTO de transporte para Aerolinea (misma forma que el modelo; punto
/// de extensión si el backend cambia de forma independiente del dominio).
class AerolineaDto {
  static Aerolinea fromJson(Map<String, dynamic> json) => Aerolinea.fromJson(json);
  static Map<String, dynamic> toJson(Aerolinea item) => item.toJson();
}
