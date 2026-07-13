import 'package:flutter/foundation.dart';
import '../../domain/model/tipo_aeronave.dart';
import '../../domain/repository/tipo_aeronave_repository.dart';

enum EstadoCargaTipoAeronave { inicial, cargando, listo, error }

class TipoAeronaveProvider extends ChangeNotifier {
  final TipoAeronaveRepository _repo;
  TipoAeronaveProvider(this._repo);

  EstadoCargaTipoAeronave estado = EstadoCargaTipoAeronave.inicial;
  List<TipoAeronave> items = [];
  String? error;

  bool get cargando => estado == EstadoCargaTipoAeronave.cargando;

  Future<void> cargar({bool forzar = false}) async {
    if (!forzar && estado == EstadoCargaTipoAeronave.listo) return;
    estado = EstadoCargaTipoAeronave.cargando;
    notifyListeners();
    try {
      items = await _repo.listar();
      estado = EstadoCargaTipoAeronave.listo;
    } catch (e) {
      error = e.toString();
      estado = EstadoCargaTipoAeronave.error;
    }
    notifyListeners();
  }

  Future<bool> crear(TipoAeronave item) async {
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

  Future<bool> actualizar(int id, TipoAeronave item) async {
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
