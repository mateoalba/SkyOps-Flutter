import 'package:flutter/foundation.dart';
import '../../domain/model/reserva.dart';
import '../../domain/repository/reserva_repository.dart';

enum EstadoCargaReserva { inicial, cargando, listo, error }

class ReservaProvider extends ChangeNotifier {
  final ReservaRepository _repo;
  ReservaProvider(this._repo);

  EstadoCargaReserva estado = EstadoCargaReserva.inicial;
  List<Reserva> items = [];
  String? error;

  bool get cargando => estado == EstadoCargaReserva.cargando;

  Future<void> cargar({bool forzar = false}) async {
    if (!forzar && estado == EstadoCargaReserva.listo) return;
    estado = EstadoCargaReserva.cargando;
    notifyListeners();
    try {
      items = await _repo.listar();
      estado = EstadoCargaReserva.listo;
    } catch (e) {
      error = e.toString();
      estado = EstadoCargaReserva.error;
    }
    notifyListeners();
  }

  Future<bool> crear(Reserva item) async {
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

  Future<bool> actualizar(String id, Reserva item) async {
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
