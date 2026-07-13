import 'package:flutter/foundation.dart';
import '../../domain/model/aeropuerto.dart';
import '../../domain/repository/aeropuerto_repository.dart';

enum EstadoCargaAeropuerto { inicial, cargando, listo, error }

class AeropuertoProvider extends ChangeNotifier {
  final AeropuertoRepository _repo;
  AeropuertoProvider(this._repo);

  EstadoCargaAeropuerto estado = EstadoCargaAeropuerto.inicial;
  List<Aeropuerto> items = [];
  String? error;

  bool get cargando => estado == EstadoCargaAeropuerto.cargando;

  Future<void> cargar({bool forzar = false}) async {
    if (!forzar && estado == EstadoCargaAeropuerto.listo) return;
    estado = EstadoCargaAeropuerto.cargando;
    notifyListeners();
    try {
      items = await _repo.listar();
      estado = EstadoCargaAeropuerto.listo;
    } catch (e) {
      error = e.toString();
      estado = EstadoCargaAeropuerto.error;
    }
    notifyListeners();
  }

  Future<bool> crear(Aeropuerto item) async {
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

  Future<bool> actualizar(String id, Aeropuerto item) async {
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
