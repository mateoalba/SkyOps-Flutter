import 'package:flutter/foundation.dart';
import '../../domain/model/aeronave.dart';
import '../../domain/repository/aeronave_repository.dart';

enum EstadoCargaAeronave { inicial, cargando, listo, error }

class AeronaveProvider extends ChangeNotifier {
  final AeronaveRepository _repo;
  AeronaveProvider(this._repo);

  EstadoCargaAeronave estado = EstadoCargaAeronave.inicial;
  List<Aeronave> items = [];
  String? error;

  bool get cargando => estado == EstadoCargaAeronave.cargando;

  Future<void> cargar({bool forzar = false}) async {
    if (!forzar && estado == EstadoCargaAeronave.listo) return;
    estado = EstadoCargaAeronave.cargando;
    notifyListeners();
    try {
      items = await _repo.listar();
      estado = EstadoCargaAeronave.listo;
    } catch (e) {
      error = e.toString();
      estado = EstadoCargaAeronave.error;
    }
    notifyListeners();
  }

  Future<bool> crear(Aeronave item) async {
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

  Future<bool> actualizar(String id, Aeronave item) async {
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
