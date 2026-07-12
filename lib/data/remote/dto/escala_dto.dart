import '../../../domain/model/escala.dart';

/// DTO de transporte para Escala (misma forma que el modelo; punto
/// de extensión si el backend cambia de forma independiente del dominio).
class EscalaDto {
  static Escala fromJson(Map<String, dynamic> json) => Escala.fromJson(json);
  static Map<String, dynamic> toJson(Escala item) => item.toJson();
}
