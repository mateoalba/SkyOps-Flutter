import 'package:flutter/foundation.dart';
import '../../domain/model/escala.dart';
import '../../domain/repository/escala_repository.dart';

enum EstadoCargaEscala { inicial, cargando, listo, error }

class EscalaProvider extends ChangeNotifier {
  final EscalaRepository _repo;
  EscalaProvider(this._repo);

  EstadoCargaEscala estado = EstadoCargaEscala.inicial;
  List<Escala> items = [];
  String? error;

  bool get cargando => estado == EstadoCargaEscala.cargando;

  Future<void> cargar({bool forzar = false}) async {
    if (!forzar && estado == EstadoCargaEscala.listo) return;
    estado = EstadoCargaEscala.cargando;
    notifyListeners();
    try {
      items = await _repo.listar();
      estado = EstadoCargaEscala.listo;
    } catch (e) {
      error = e.toString();
      estado = EstadoCargaEscala.error;
    }
    notifyListeners();
  }

  Future<bool> crear(Escala item) async {
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

  Future<bool> actualizar(String id, Escala item) async {
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
