import '../../../domain/model/puerta.dart';

/// DTO de transporte para Puerta (misma forma que el modelo; punto
/// de extensión si el backend cambia de forma independiente del dominio).
class PuertaDto {
  static Puerta fromJson(Map<String, dynamic> json) => Puerta.fromJson(json);
  static Map<String, dynamic> toJson(Puerta item) => item.toJson();
}
