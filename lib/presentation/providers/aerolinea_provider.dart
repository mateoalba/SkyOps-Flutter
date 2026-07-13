import 'package:flutter/foundation.dart';
import '../../domain/model/aerolinea.dart';
import '../../domain/repository/aerolinea_repository.dart';

enum EstadoCargaAerolinea { inicial, cargando, listo, error }

class AerolineaProvider extends ChangeNotifier {
  final AerolineaRepository _repo;
  AerolineaProvider(this._repo);

  EstadoCargaAerolinea estado = EstadoCargaAerolinea.inicial;
  List<Aerolinea> items = [];
  String? error;

  bool get cargando => estado == EstadoCargaAerolinea.cargando;

  Future<void> cargar({bool forzar = false}) async {
    if (!forzar && estado == EstadoCargaAerolinea.listo) return;
    estado = EstadoCargaAerolinea.cargando;
    notifyListeners();
    try {
      items = await _repo.listar();
      estado = EstadoCargaAerolinea.listo;
    } catch (e) {
      error = e.toString();
      estado = EstadoCargaAerolinea.error;
    }
    notifyListeners();
  }

  Future<bool> crear(Aerolinea item) async {
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

  Future<bool> actualizar(String id, Aerolinea item) async {
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
