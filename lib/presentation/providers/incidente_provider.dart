import 'package:flutter/foundation.dart';
import '../../domain/model/incidente.dart';
import '../../domain/repository/incidente_repository.dart';

enum EstadoCargaIncidente { inicial, cargando, listo, error }

class IncidenteProvider extends ChangeNotifier {
  final IncidenteRepository _repo;
  IncidenteProvider(this._repo);

  EstadoCargaIncidente estado = EstadoCargaIncidente.inicial;
  List<Incidente> items = [];
  String? error;

  bool get cargando => estado == EstadoCargaIncidente.cargando;

  Future<void> cargar({bool forzar = false}) async {
    if (!forzar && estado == EstadoCargaIncidente.listo) return;
    estado = EstadoCargaIncidente.cargando;
    notifyListeners();
    try {
      items = await _repo.listar();
      estado = EstadoCargaIncidente.listo;
    } catch (e) {
      error = e.toString();
      estado = EstadoCargaIncidente.error;
    }
    notifyListeners();
  }

  Future<bool> crear(Incidente item) async {
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

  Future<bool> actualizar(String id, Incidente item) async {
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
