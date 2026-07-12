import 'dart:typed_data';
import 'package:dio/dio.dart';
import '../../core/config/app_config.dart';
import '../../core/error/api_exception.dart';
import '../../domain/model/auth_models.dart';
import '../../domain/model/user.dart';
import '../../domain/repository/auth_repository.dart';
import '../local/secure_storage.dart';
import '../remote/dto/auth_dto.dart';

class AuthRepositoryImpl implements AuthRepository {
  final Dio _dio;
  final SecureStorage _secureStorage;

  AuthRepositoryImpl(this._dio, this._secureStorage);

  @override
  Future<void> login(LoginRequest request) async {
    try {
      final response = await _dio.post(
        AppConfig.loginEndpoint,
        data: LoginRequestDto(request).toJson(),
      );
      final token = TokenDto.fromJson(response.data as Map<String, dynamic>);
      await _secureStorage.guardarTokens(access: token.access, refresh: token.refresh);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<void> registro(RegistroRequest request) async {
    try {
      await _dio.post(
        AppConfig.registroEndpoint,
        data: RegistroRequestDto(request).toJson(),
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<void> loginConGoogle(String idToken) async {
    try {
      final response = await _dio.post(
        AppConfig.googleLoginEndpoint,
        data: {'id_token': idToken},
      );
      final token = TokenDto.fromJson(response.data as Map<String, dynamic>);
      await _secureStorage.guardarTokens(access: token.access, refresh: token.refresh);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<void> logout() async {
    try {
      final refresh = await _secureStorage.obtenerRefreshToken();
      if (refresh != null) {
        await _dio.post(AppConfig.logoutEndpoint, data: {'refresh': refresh});
      }
    } on DioException catch (_) {
      // Si el backend falla igual limpiamos la sesión local.
    } finally {
      await _secureStorage.limpiar();
    }
  }

  @override
  Future<Usuario> obtenerPerfil() async {
    try {
      final response = await _dio.get(AppConfig.perfilEndpoint);
      return UsuarioDto.fromJson(response.data as Map<String, dynamic>).toEntity();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<Usuario> actualizarPerfil(
    Map<String, dynamic> cambios, {
    Uint8List? fotoBytes,
    String? fotoNombre,
  }) async {
    try {
      final data = fotoBytes == null
          ? cambios
          : FormData.fromMap({
              ...cambios,
              'foto_upload': MultipartFile.fromBytes(fotoBytes, filename: fotoNombre ?? 'foto.jpg'),
            });
      final response = await _dio.patch(AppConfig.perfilEndpoint, data: data);
      return UsuarioDto.fromJson(response.data as Map<String, dynamic>).toEntity();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<void> cambiarPassword(CambiarPasswordRequest request) async {
    try {
      await _dio.post(AppConfig.cambiarPasswordEndpoint, data: {
        'password_actual': request.passwordActual,
        'password_nuevo': request.passwordNueva,
        'password_nuevo2': request.passwordNuevaConfirmacion,
      });
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<bool> haySesionActiva() async {
    final token = await _secureStorage.obtenerAccessToken();
    return token != null && token.isNotEmpty;
  }
}
