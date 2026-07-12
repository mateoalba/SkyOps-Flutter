import '../../../domain/model/pista.dart';

/// DTO de transporte para Pista (misma forma que el modelo; punto
/// de extensión si el backend cambia de forma independiente del dominio).
class PistaDto {
  static Pista fromJson(Map<String, dynamic> json) => Pista.fromJson(json);
  static Map<String, dynamic> toJson(Pista item) => item.toJson();
}
