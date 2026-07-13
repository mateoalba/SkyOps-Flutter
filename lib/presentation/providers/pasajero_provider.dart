import 'package:flutter/foundation.dart';
import '../../domain/model/pasajero.dart';
import '../../domain/repository/pasajero_repository.dart';

enum EstadoCargaPasajero { inicial, cargando, listo, error }

class PasajeroProvider extends ChangeNotifier {
  final PasajeroRepository _repo;
  PasajeroProvider(this._repo);

  EstadoCargaPasajero estado = EstadoCargaPasajero.inicial;
  List<Pasajero> items = [];
  String? error;

  bool get cargando => estado == EstadoCargaPasajero.cargando;

  Future<void> cargar({bool forzar = false}) async {
    if (!forzar && estado == EstadoCargaPasajero.listo) return;
    estado = EstadoCargaPasajero.cargando;
    notifyListeners();
    try {
      items = await _repo.listar();
      estado = EstadoCargaPasajero.listo;
    } catch (e) {
      error = e.toString();
      estado = EstadoCargaPasajero.error;
    }
    notifyListeners();
  }

  Future<bool> crear(Pasajero item) async {
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

  Future<bool> actualizar(String id, Pasajero item) async {
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
