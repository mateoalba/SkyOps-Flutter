import '../../../domain/model/reserva.dart';

/// DTO de transporte para Reserva (misma forma que el modelo; punto
/// de extensión si el backend cambia de forma independiente del dominio).
class ReservaDto {
  static Reserva fromJson(Map<String, dynamic> json) => Reserva.fromJson(json);
  static Map<String, dynamic> toJson(Reserva item) => item.toJson();
}
