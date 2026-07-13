import 'package:flutter/foundation.dart';
import '../../domain/model/terminal.dart';
import '../../domain/repository/terminal_repository.dart';

enum EstadoCargaTerminal { inicial, cargando, listo, error }

class TerminalProvider extends ChangeNotifier {
  final TerminalRepository _repo;
  TerminalProvider(this._repo);

  EstadoCargaTerminal estado = EstadoCargaTerminal.inicial;
  List<Terminal> items = [];
  String? error;

  bool get cargando => estado == EstadoCargaTerminal.cargando;

  Future<void> cargar({bool forzar = false}) async {
    if (!forzar && estado == EstadoCargaTerminal.listo) return;
    estado = EstadoCargaTerminal.cargando;
    notifyListeners();
    try {
      items = await _repo.listar();
      estado = EstadoCargaTerminal.listo;
    } catch (e) {
      error = e.toString();
      estado = EstadoCargaTerminal.error;
    }
    notifyListeners();
  }

  Future<bool> crear(Terminal item) async {
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

  Future<bool> actualizar(String id, Terminal item) async {
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
