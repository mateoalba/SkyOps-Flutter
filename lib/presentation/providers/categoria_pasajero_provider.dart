import 'package:flutter/foundation.dart';
import '../../domain/model/categoria_pasajero.dart';
import '../../domain/repository/categoria_pasajero_repository.dart';

enum EstadoCargaCategoriaPasajero { inicial, cargando, listo, error }

class CategoriaPasajeroProvider extends ChangeNotifier {
  final CategoriaPasajeroRepository _repo;
  CategoriaPasajeroProvider(this._repo);

  EstadoCargaCategoriaPasajero estado = EstadoCargaCategoriaPasajero.inicial;
  List<CategoriaPasajero> items = [];
  String? error;

  bool get cargando => estado == EstadoCargaCategoriaPasajero.cargando;

  Future<void> cargar({bool forzar = false}) async {
    if (!forzar && estado == EstadoCargaCategoriaPasajero.listo) return;
    estado = EstadoCargaCategoriaPasajero.cargando;
    notifyListeners();
    try {
      items = await _repo.listar();
      estado = EstadoCargaCategoriaPasajero.listo;
    } catch (e) {
      error = e.toString();
      estado = EstadoCargaCategoriaPasajero.error;
    }
    notifyListeners();
  }

  Future<bool> crear(CategoriaPasajero item) async {
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

  Future<bool> actualizar(int id, CategoriaPasajero item) async {
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
