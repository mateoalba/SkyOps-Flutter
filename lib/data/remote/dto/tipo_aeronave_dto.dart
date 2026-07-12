import '../../../domain/model/tipo_aeronave.dart';

/// DTO de transporte para TipoAeronave (misma forma que el modelo; punto
/// de extensión si el backend cambia de forma independiente del dominio).
class TipoAeronaveDto {
  static TipoAeronave fromJson(Map<String, dynamic> json) => TipoAeronave.fromJson(json);
  static Map<String, dynamic> toJson(TipoAeronave item) => item.toJson();
}
