import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/config/app_config.dart';

/// Wrapper de FlutterSecureStorage para guardar los tokens JWT.
class SecureStorage {
  final FlutterSecureStorage _storage;

  SecureStorage({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  Future<void> guardarTokens({required String access, required String refresh}) async {
    await _storage.write(key: AppConfig.accessTokenKey, value: access);
    await _storage.write(key: AppConfig.refreshTokenKey, value: refresh);
  }

  Future<void> guardarAccessToken(String access) async {
    await _storage.write(key: AppConfig.accessTokenKey, value: access);
  }

  Future<String?> obtenerAccessToken() => _storage.read(key: AppConfig.accessTokenKey);

  Future<String?> obtenerRefreshToken() => _storage.read(key: AppConfig.refreshTokenKey);

  Future<void> limpiar() async {
    await _storage.delete(key: AppConfig.accessTokenKey);
    await _storage.delete(key: AppConfig.refreshTokenKey);
  }
}
