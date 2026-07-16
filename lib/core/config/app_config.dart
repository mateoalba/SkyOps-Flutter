/// Configuración global de la app: URLs y constantes de la API de SkyOps.
class AppConfig {
  AppConfig._();

  /// URL base del backend Django (SkyOps).
  ///
  /// - Probando en Windows/Chrome (misma PC que corre `runserver`): 'http://127.0.0.1:8000/api'
  /// - Probando en EMULADOR Android: 'http://10.0.2.2:8000/api' (alias especial al localhost del host)
  /// - Probando en celular físico: 'http://<IP-de-tu-PC-en-la-red>:8000/api' (ej. 192.168.1.x)
  /// - Volviendo al servidor remoto: 'http://147.182.179.6/api'
  static const String baseUrl = 'https://skyops-api.uaeftt-ute.site/api';

  // ---- Autenticación ----
  static const String loginEndpoint = '/auth/login/';
  static const String registroEndpoint = '/auth/registro/';
  static const String logoutEndpoint = '/auth/logout/';
  static const String perfilEndpoint = '/auth/perfil/';
  static const String refreshEndpoint = '/auth/refresh/';
  static const String cambiarPasswordEndpoint = '/auth/cambiar-password/';
  static const String googleLoginEndpoint = '/auth/google/';

  // ---- Google Sign-In ----
  // Client ID de tipo "Web application" creado en Google Cloud Console
  // (APIs & Services > Credentials). El mismo valor debe estar en la
  // variable de entorno GOOGLE_OAUTH_CLIENT_ID del backend Django.
  // Ver README, sección "Configurar Google Sign-In".
  static const String googleServerClientId = '';

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);

  // Claves de almacenamiento seguro
  static const String accessTokenKey = 'skyops_access_token';
  static const String refreshTokenKey = 'skyops_refresh_token';
}
