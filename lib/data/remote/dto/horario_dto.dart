import '../../../domain/model/horario.dart';

/// DTO de transporte para Horario (misma forma que el modelo; punto
/// de extensión si el backend cambia de forma independiente del dominio).
class HorarioDto {
  static Horario fromJson(Map<String, dynamic> json) => Horario.fromJson(json);
  static Map<String, dynamic> toJson(Horario item) => item.toJson();
}
