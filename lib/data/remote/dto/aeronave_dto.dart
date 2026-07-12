import '../../../domain/model/aeronave.dart';

/// DTO de transporte para Aeronave (misma forma que el modelo; punto
/// de extensión si el backend cambia de forma independiente del dominio).
class AeronaveDto {
  static Aeronave fromJson(Map<String, dynamic> json) => Aeronave.fromJson(json);
  static Map<String, dynamic> toJson(Aeronave item) => item.toJson();
}
