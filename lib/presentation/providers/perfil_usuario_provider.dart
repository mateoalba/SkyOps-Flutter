import 'package:flutter/foundation.dart';
import '../../domain/model/perfil_usuario.dart';
import '../../domain/repository/perfil_usuario_repository.dart';

enum EstadoCargaPerfilUsuario { inicial, cargando, listo, error }

class PerfilUsuarioProvider extends ChangeNotifier {
  final PerfilUsuarioRepository _repo;
  PerfilUsuarioProvider(this._repo);

  EstadoCargaPerfilUsuario estado = EstadoCargaPerfilUsuario.inicial;
  List<PerfilUsuario> items = [];
  String? error;

  bool get cargando => estado == EstadoCargaPerfilUsuario.cargando;

  Future<void> cargar({bool forzar = false}) async {
    if (!forzar && estado == EstadoCargaPerfilUsuario.listo) return;
    estado = EstadoCargaPerfilUsuario.cargando;
    notifyListeners();
    try {
      items = await _repo.listar();
      estado = EstadoCargaPerfilUsuario.listo;
    } catch (e) {
      error = e.toString();
      estado = EstadoCargaPerfilUsuario.error;
    }
    notifyListeners();
  }

  Future<bool> crear(PerfilUsuario item) async {
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

  Future<bool> actualizar(String id, PerfilUsuario item) async {
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
