import 'package:flutter/foundation.dart';
import '../../domain/model/mantenimiento.dart';
import '../../domain/repository/mantenimiento_repository.dart';

enum EstadoCargaMantenimiento { inicial, cargando, listo, error }

class MantenimientoProvider extends ChangeNotifier {
  final MantenimientoRepository _repo;
  MantenimientoProvider(this._repo);

  EstadoCargaMantenimiento estado = EstadoCargaMantenimiento.inicial;
  List<Mantenimiento> items = [];
  String? error;

  bool get cargando => estado == EstadoCargaMantenimiento.cargando;

  Future<void> cargar({bool forzar = false}) async {
    if (!forzar && estado == EstadoCargaMantenimiento.listo) return;
    estado = EstadoCargaMantenimiento.cargando;
    notifyListeners();
    try {
      items = await _repo.listar();
      estado = EstadoCargaMantenimiento.listo;
    } catch (e) {
      error = e.toString();
      estado = EstadoCargaMantenimiento.error;
    }
    notifyListeners();
  }

  Future<bool> crear(Mantenimiento item) async {
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

  Future<bool> actualizar(String id, Mantenimiento item) async {
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
