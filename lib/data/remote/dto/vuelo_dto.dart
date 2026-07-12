import '../../../domain/model/vuelo.dart';

/// DTO de transporte para Vuelo (misma forma que el modelo; punto
/// de extensión si el backend cambia de forma independiente del dominio).
class VueloDto {
  static Vuelo fromJson(Map<String, dynamic> json) => Vuelo.fromJson(json);
  static Map<String, dynamic> toJson(Vuelo item) => item.toJson();
}
