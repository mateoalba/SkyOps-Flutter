import 'package:google_sign_in/google_sign_in.dart';
import '../../../core/config/app_config.dart';

/// Wrapper delgado sobre el SDK de Google Sign-In: solo se encarga de
/// mostrar el selector de cuenta de Google y devolver el idToken, que luego
/// se manda al backend (POST /auth/google/) para crear la sesión.
///
/// Requiere que AppConfig.googleServerClientId tenga el Client ID de tipo
/// "Web application" creado en Google Cloud Console (ver README, sección
/// "Configurar Google Sign-In"). Sin eso configurado, signIn() devuelve null.
class GoogleAuthService {
  GoogleAuthService._();
  static final GoogleAuthService instancia = GoogleAuthService._();

  GoogleSignIn? _googleSignIn;

  GoogleSignIn get _cliente {
    return _googleSignIn ??= GoogleSignIn(
      scopes: const ['email', 'profile'],
      serverClientId:
          AppConfig.googleServerClientId.isEmpty ? null : AppConfig.googleServerClientId,
    );
  }

  bool get configurado => AppConfig.googleServerClientId.isNotEmpty;

  /// Muestra el selector de cuenta de Google y devuelve el idToken, o null
  /// si el usuario canceló o el Client ID no está configurado.
  Future<String?> obtenerIdToken() async {
    if (!configurado) return null;
    try {
      final cuenta = await _cliente.signIn();
      if (cuenta == null) return null; // el usuario canceló el selector
      final auth = await cuenta.authentication;
      return auth.idToken;
    } catch (_) {
      return null;
    }
  }

  Future<void> cerrarSesion() async {
    try {
      await _googleSignIn?.signOut();
    } catch (_) {
      // Ignorar: no hay sesión de Google activa que cerrar.
    }
  }
}
