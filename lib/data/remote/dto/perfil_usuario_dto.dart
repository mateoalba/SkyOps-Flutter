import '../../../domain/model/perfil_usuario.dart';

/// DTO de transporte para PerfilUsuario (misma forma que el modelo; punto
/// de extensión si el backend cambia de forma independiente del dominio).
class PerfilUsuarioDto {
  static PerfilUsuario fromJson(Map<String, dynamic> json) => PerfilUsuario.fromJson(json);
  static Map<String, dynamic> toJson(PerfilUsuario item) => item.toJson();
}
