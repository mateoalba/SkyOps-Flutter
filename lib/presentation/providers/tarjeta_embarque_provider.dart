import 'package:flutter/foundation.dart';
import '../../domain/model/tarjeta_embarque.dart';
import '../../domain/repository/tarjeta_embarque_repository.dart';

enum EstadoCargaTarjetaEmbarque { inicial, cargando, listo, error }

class TarjetaEmbarqueProvider extends ChangeNotifier {
  final TarjetaEmbarqueRepository _repo;
  TarjetaEmbarqueProvider(this._repo);

  EstadoCargaTarjetaEmbarque estado = EstadoCargaTarjetaEmbarque.inicial;
  List<TarjetaEmbarque> items = [];
  String? error;

  bool get cargando => estado == EstadoCargaTarjetaEmbarque.cargando;

  Future<void> cargar({bool forzar = false}) async {
    if (!forzar && estado == EstadoCargaTarjetaEmbarque.listo) return;
    estado = EstadoCargaTarjetaEmbarque.cargando;
    notifyListeners();
    try {
      items = await _repo.listar();
      estado = EstadoCargaTarjetaEmbarque.listo;
    } catch (e) {
      error = e.toString();
      estado = EstadoCargaTarjetaEmbarque.error;
    }
    notifyListeners();
  }

  Future<bool> crear(TarjetaEmbarque item) async {
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

  Future<bool> actualizar(int id, TarjetaEmbarque item) async {
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
