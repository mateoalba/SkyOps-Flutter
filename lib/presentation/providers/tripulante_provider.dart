import 'package:flutter/foundation.dart';
import '../../domain/model/tripulante.dart';
import '../../domain/repository/tripulante_repository.dart';

enum EstadoCargaTripulante { inicial, cargando, listo, error }

class TripulanteProvider extends ChangeNotifier {
  final TripulanteRepository _repo;
  TripulanteProvider(this._repo);

  EstadoCargaTripulante estado = EstadoCargaTripulante.inicial;
  List<Tripulante> items = [];
  String? error;

  bool get cargando => estado == EstadoCargaTripulante.cargando;

  Future<void> cargar({bool forzar = false}) async {
    if (!forzar && estado == EstadoCargaTripulante.listo) return;
    estado = EstadoCargaTripulante.cargando;
    notifyListeners();
    try {
      items = await _repo.listar();
      estado = EstadoCargaTripulante.listo;
    } catch (e) {
      error = e.toString();
      estado = EstadoCargaTripulante.error;
    }
    notifyListeners();
  }

  Future<bool> crear(Tripulante item) async {
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

  Future<bool> actualizar(String id, Tripulante item) async {
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
