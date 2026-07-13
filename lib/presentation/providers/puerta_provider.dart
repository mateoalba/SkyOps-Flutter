import 'package:flutter/foundation.dart';
import '../../domain/model/puerta.dart';
import '../../domain/repository/puerta_repository.dart';

enum EstadoCargaPuerta { inicial, cargando, listo, error }

class PuertaProvider extends ChangeNotifier {
  final PuertaRepository _repo;
  PuertaProvider(this._repo);

  EstadoCargaPuerta estado = EstadoCargaPuerta.inicial;
  List<Puerta> items = [];
  String? error;

  bool get cargando => estado == EstadoCargaPuerta.cargando;

  Future<void> cargar({bool forzar = false}) async {
    if (!forzar && estado == EstadoCargaPuerta.listo) return;
    estado = EstadoCargaPuerta.cargando;
    notifyListeners();
    try {
      items = await _repo.listar();
      estado = EstadoCargaPuerta.listo;
    } catch (e) {
      error = e.toString();
      estado = EstadoCargaPuerta.error;
    }
    notifyListeners();
  }

  Future<bool> crear(Puerta item) async {
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

  Future<bool> actualizar(String id, Puerta item) async {
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
