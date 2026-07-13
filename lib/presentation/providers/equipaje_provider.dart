import 'package:flutter/foundation.dart';
import '../../domain/model/equipaje.dart';
import '../../domain/repository/equipaje_repository.dart';

enum EstadoCargaEquipaje { inicial, cargando, listo, error }

class EquipajeProvider extends ChangeNotifier {
  final EquipajeRepository _repo;
  EquipajeProvider(this._repo);

  EstadoCargaEquipaje estado = EstadoCargaEquipaje.inicial;
  List<Equipaje> items = [];
  String? error;

  bool get cargando => estado == EstadoCargaEquipaje.cargando;

  Future<void> cargar({bool forzar = false}) async {
    if (!forzar && estado == EstadoCargaEquipaje.listo) return;
    estado = EstadoCargaEquipaje.cargando;
    notifyListeners();
    try {
      items = await _repo.listar();
      estado = EstadoCargaEquipaje.listo;
    } catch (e) {
      error = e.toString();
      estado = EstadoCargaEquipaje.error;
    }
    notifyListeners();
  }

  Future<bool> crear(Equipaje item) async {
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

  Future<bool> actualizar(int id, Equipaje item) async {
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

  Future<bool> eliminar(int id) async {
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
