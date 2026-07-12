import '../../../domain/model/tarjeta_embarque.dart';

/// DTO de transporte para TarjetaEmbarque (misma forma que el modelo; punto
/// de extensión si el backend cambia de forma independiente del dominio).
class TarjetaEmbarqueDto {
  static TarjetaEmbarque fromJson(Map<String, dynamic> json) => TarjetaEmbarque.fromJson(json);
  static Map<String, dynamic> toJson(TarjetaEmbarque item) => item.toJson();
}
