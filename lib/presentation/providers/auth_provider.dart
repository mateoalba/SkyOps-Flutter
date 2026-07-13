import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import '../../core/error/api_exception.dart';
import '../../domain/model/auth_models.dart';
import '../../domain/model/user.dart';
import '../../domain/repository/auth_repository.dart';

enum EstadoAuth { desconocido, autenticado, noAutenticado }

/// Provider (ChangeNotifier) que mantiene el estado de sesión del usuario.
class AuthProvider extends ChangeNotifier {
  final AuthRepository _repository;

  AuthProvider(this._repository);

  EstadoAuth _estado = EstadoAuth.desconocido;
  Usuario? _usuario;
  bool _cargando = false;
  String? _mensajeError;

  EstadoAuth get estado => _estado;
  Usuario? get usuario => _usuario;
  bool get cargando => _cargando;
  String? get mensajeError => _mensajeError;
  bool get estaAutenticado => _estado == EstadoAuth.autenticado;

  Future<void> verificarSesion() async {
    final activa = await _repository.haySesionActiva();
    if (activa) {
      try {
        _usuario = await _repository.obtenerPerfil();
        _estado = EstadoAuth.autenticado;
      } catch (_) {
        _estado = EstadoAuth.noAutenticado;
      }
    } else {
      _estado = EstadoAuth.noAutenticado;
    }
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _iniciarCarga();
    try {
      await _repository.login(LoginRequest(email: email, password: password));
      _usuario = await _repository.obtenerPerfil();
      _estado = EstadoAuth.autenticado;
      _finalizarCarga();
      return true;
    } catch (e) {
      _finalizarCarga(error: e is ApiException ? e.mensaje : 'No se pudo iniciar sesión');
      return false;
    }
  }

  Future<bool> loginConGoogle(String idToken) async {
    _iniciarCarga();
    try {
      await _repository.loginConGoogle(idToken);
      _usuario = await _repository.obtenerPerfil();
      _estado = EstadoAuth.autenticado;
      _finalizarCarga();
      return true;
    } catch (e) {
      _finalizarCarga(error: e is ApiException ? e.mensaje : 'No se pudo iniciar sesión con Google');
      return false;
    }
  }

  Future<bool> registro(RegistroRequest request) async {
    _iniciarCarga();
    try {
      await _repository.registro(request);
      _finalizarCarga();
      return true;
    } catch (e) {
      _finalizarCarga(error: e is ApiException ? e.mensaje : 'No se pudo crear la cuenta');
      return false;
    }
  }

  Future<void> logout() async {
    _iniciarCarga();
    await _repository.logout();
    _usuario = null;
    _estado = EstadoAuth.noAutenticado;
    _finalizarCarga();
  }

  Future<bool> actualizarPerfil(
    Map<String, dynamic> cambios, {
    Uint8List? fotoBytes,
    String? fotoNombre,
  }) async {
    _iniciarCarga();
    try {
      _usuario = await _repository.actualizarPerfil(cambios, fotoBytes: fotoBytes, fotoNombre: fotoNombre);
      _finalizarCarga();
      return true;
    } catch (e) {
      _finalizarCarga(error: e is ApiException ? e.mensaje : 'No se pudo actualizar el perfil');
      return false;
    }
  }

  Future<bool> cambiarPassword(CambiarPasswordRequest request) async {
    _iniciarCarga();
    try {
      await _repository.cambiarPassword(request);
      _finalizarCarga();
      return true;
    } catch (e) {
      _finalizarCarga(error: e is ApiException ? e.mensaje : 'No se pudo cambiar la contraseña');
      return false;
    }
  }

  void _iniciarCarga() {
    _cargando = true;
    _mensajeError = null;
    notifyListeners();
  }

  void _finalizarCarga({String? error}) {
    _cargando = false;
    _mensajeError = error;
    notifyListeners();
  }
}
