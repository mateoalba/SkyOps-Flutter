import 'package:flutter/foundation.dart';
import '../../domain/model/asignacion.dart';
import '../../domain/repository/asignacion_repository.dart';

enum EstadoCargaAsignacion { inicial, cargando, listo, error }

class AsignacionProvider extends ChangeNotifier {
  final AsignacionRepository _repo;
  AsignacionProvider(this._repo);

  EstadoCargaAsignacion estado = EstadoCargaAsignacion.inicial;
  List<Asignacion> items = [];
  String? error;

  bool get cargando => estado == EstadoCargaAsignacion.cargando;

  Future<void> cargar({bool forzar = false}) async {
    if (!forzar && estado == EstadoCargaAsignacion.listo) return;
    estado = EstadoCargaAsignacion.cargando;
    notifyListeners();
    try {
      items = await _repo.listar();
      estado = EstadoCargaAsignacion.listo;
    } catch (e) {
      error = e.toString();
      estado = EstadoCargaAsignacion.error;
    }
    notifyListeners();
  }

  Future<bool> crear(Asignacion item) async {
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

  Future<bool> actualizar(String id, Asignacion item) async {
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
