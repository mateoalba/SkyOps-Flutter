import '../../../domain/model/certificacion.dart';

/// DTO de transporte para Certificacion (misma forma que el modelo; punto
/// de extensión si el backend cambia de forma independiente del dominio).
class CertificacionDto {
  static Certificacion fromJson(Map<String, dynamic> json) => Certificacion.fromJson(json);
  static Map<String, dynamic> toJson(Certificacion item) => item.toJson();
}
