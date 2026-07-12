import '../../../domain/model/sesion_usuario.dart';

/// DTO de transporte para SesionUsuario (misma forma que el modelo; punto
/// de extensión si el backend cambia de forma independiente del dominio).
class SesionUsuarioDto {
  static SesionUsuario fromJson(Map<String, dynamic> json) => SesionUsuario.fromJson(json);
  static Map<String, dynamic> toJson(SesionUsuario item) => item.toJson();
}
