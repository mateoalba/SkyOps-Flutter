import 'package:flutter/foundation.dart';
import '../../domain/model/pista.dart';
import '../../domain/repository/pista_repository.dart';

enum EstadoCargaPista { inicial, cargando, listo, error }

class PistaProvider extends ChangeNotifier {
  final PistaRepository _repo;
  PistaProvider(this._repo);

  EstadoCargaPista estado = EstadoCargaPista.inicial;
  List<Pista> items = [];
  String? error;

  bool get cargando => estado == EstadoCargaPista.cargando;

  Future<void> cargar({bool forzar = false}) async {
    if (!forzar && estado == EstadoCargaPista.listo) return;
    estado = EstadoCargaPista.cargando;
    notifyListeners();
    try {
      items = await _repo.listar();
      estado = EstadoCargaPista.listo;
    } catch (e) {
      error = e.toString();
      estado = EstadoCargaPista.error;
    }
    notifyListeners();
  }

  Future<bool> crear(Pista item) async {
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

  Future<bool> actualizar(String id, Pista item) async {
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
