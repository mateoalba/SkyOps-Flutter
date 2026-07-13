import 'dart:typed_data';
import '../model/auth_models.dart';
import '../model/user.dart';

abstract class AuthRepository {
  Future<void> login(LoginRequest request);
  Future<void> registro(RegistroRequest request);

  /// Inicia sesión con un idToken de Google (obtenido con google_sign_in) contra
  /// POST /auth/google/. El backend crea la cuenta automáticamente si no existe.
  Future<void> loginConGoogle(String idToken);
  Future<void> logout();
  Future<Usuario> obtenerPerfil();

  /// Actualiza el perfil. Si [fotoBytes] no es null, se envía como
  /// multipart/form-data junto con los demás [cambios] (todos como texto).
  Future<Usuario> actualizarPerfil(
    Map<String, dynamic> cambios, {
    Uint8List? fotoBytes,
    String? fotoNombre,
  });
  Future<void> cambiarPassword(CambiarPasswordRequest request);
  Future<bool> haySesionActiva();
}
