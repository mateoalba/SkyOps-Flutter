import 'package:flutter/foundation.dart';
import '../../domain/model/sesion_usuario.dart';
import '../../domain/repository/sesion_usuario_repository.dart';

enum EstadoCargaSesionUsuario { inicial, cargando, listo, error }

class SesionUsuarioProvider extends ChangeNotifier {
  final SesionUsuarioRepository _repo;
  SesionUsuarioProvider(this._repo);

  EstadoCargaSesionUsuario estado = EstadoCargaSesionUsuario.inicial;
  List<SesionUsuario> items = [];
  String? error;

  bool get cargando => estado == EstadoCargaSesionUsuario.cargando;

  Future<void> cargar({bool forzar = false}) async {
    if (!forzar && estado == EstadoCargaSesionUsuario.listo) return;
    estado = EstadoCargaSesionUsuario.cargando;
    notifyListeners();
    try {
      items = await _repo.listar();
      estado = EstadoCargaSesionUsuario.listo;
    } catch (e) {
      error = e.toString();
      estado = EstadoCargaSesionUsuario.error;
    }
    notifyListeners();
  }

  Future<bool> crear(SesionUsuario item) async {
    try {
      final creado = await _repo.crear(item);
      items = [...items, creado];
      notifyListeners();
      return true;
    } catch (e) {
      error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> actualizar(String id, SesionUsuario item) async {
    try {
      final actualizado = await _repo.actualizar(id, item);
      items = items.map((it) => it.id == id ? actualizado : it).toList();
      notifyListeners();
      return true;
    } catch (e) {
      error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> eliminar(String id) async {
    try {
      await _repo.eliminar(id);
      items = items.where((it) => it.id != id).toList();
      notifyListeners();
      return true;
    } catch (e) {
      error = e.toString();
      notifyListeners();
      return false;
    }
  }
}
