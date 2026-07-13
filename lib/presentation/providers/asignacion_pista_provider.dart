import 'package:flutter/foundation.dart';
import '../../domain/model/asignacion_pista.dart';
import '../../domain/repository/asignacion_pista_repository.dart';

enum EstadoCargaAsignacionPista { inicial, cargando, listo, error }

class AsignacionPistaProvider extends ChangeNotifier {
  final AsignacionPistaRepository _repo;
  AsignacionPistaProvider(this._repo);

  EstadoCargaAsignacionPista estado = EstadoCargaAsignacionPista.inicial;
  List<AsignacionPista> items = [];
  String? error;

  bool get cargando => estado == EstadoCargaAsignacionPista.cargando;

  Future<void> cargar({bool forzar = false}) async {
    if (!forzar && estado == EstadoCargaAsignacionPista.listo) return;
    estado = EstadoCargaAsignacionPista.cargando;
    notifyListeners();
    try {
      items = await _repo.listar();
      estado = EstadoCargaAsignacionPista.listo;
    } catch (e) {
      error = e.toString();
      estado = EstadoCargaAsignacionPista.error;
    }
    notifyListeners();
  }

  Future<bool> crear(AsignacionPista item) async {
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

  Future<bool> actualizar(String id, AsignacionPista item) async {
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
