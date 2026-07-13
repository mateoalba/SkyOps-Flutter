import 'package:flutter/foundation.dart';
import '../../domain/model/horario.dart';
import '../../domain/repository/horario_repository.dart';

enum EstadoCargaHorario { inicial, cargando, listo, error }

class HorarioProvider extends ChangeNotifier {
  final HorarioRepository _repo;
  HorarioProvider(this._repo);

  EstadoCargaHorario estado = EstadoCargaHorario.inicial;
  List<Horario> items = [];
  String? error;

  bool get cargando => estado == EstadoCargaHorario.cargando;

  Future<void> cargar({bool forzar = false}) async {
    if (!forzar && estado == EstadoCargaHorario.listo) return;
    estado = EstadoCargaHorario.cargando;
    notifyListeners();
    try {
      items = await _repo.listar();
      estado = EstadoCargaHorario.listo;
    } catch (e) {
      error = e.toString();
      estado = EstadoCargaHorario.error;
    }
    notifyListeners();
  }

  Future<bool> crear(Horario item) async {
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

  Future<bool> actualizar(String id, Horario item) async {
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
