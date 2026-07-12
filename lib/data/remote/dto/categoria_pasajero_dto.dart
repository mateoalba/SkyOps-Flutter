import '../../../domain/model/categoria_pasajero.dart';

/// DTO de transporte para CategoriaPasajero (misma forma que el modelo; punto
/// de extensión si el backend cambia de forma independiente del dominio).
class CategoriaPasajeroDto {
  static CategoriaPasajero fromJson(Map<String, dynamic> json) => CategoriaPasajero.fromJson(json);
  static Map<String, dynamic> toJson(CategoriaPasajero item) => item.toJson();
}
