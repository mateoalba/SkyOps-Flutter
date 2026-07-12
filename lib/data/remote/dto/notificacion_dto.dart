import '../../../domain/model/notificacion.dart';

/// DTO de transporte para Notificacion (misma forma que el modelo; punto
/// de extensión si el backend cambia de forma independiente del dominio).
class NotificacionDto {
  static Notificacion fromJson(Map<String, dynamic> json) => Notificacion.fromJson(json);
  static Map<String, dynamic> toJson(Notificacion item) => item.toJson();
}
