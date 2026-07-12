import '../../../domain/model/terminal.dart';

/// DTO de transporte para Terminal (misma forma que el modelo; punto
/// de extensión si el backend cambia de forma independiente del dominio).
class TerminalDto {
  static Terminal fromJson(Map<String, dynamic> json) => Terminal.fromJson(json);
  static Map<String, dynamic> toJson(Terminal item) => item.toJson();
}
