import 'package:flutter/foundation.dart';
import '../../domain/model/audit_log.dart';
import '../../domain/repository/audit_log_repository.dart';

enum EstadoCargaAuditLog { inicial, cargando, listo, error }

class AuditLogProvider extends ChangeNotifier {
  final AuditLogRepository _repo;
  AuditLogProvider(this._repo);

  EstadoCargaAuditLog estado = EstadoCargaAuditLog.inicial;
  List<AuditLog> items = [];
  String? error;

  bool get cargando => estado == EstadoCargaAuditLog.cargando;

  Future<void> cargar({bool forzar = false}) async {
    if (!forzar && estado == EstadoCargaAuditLog.listo) return;
    estado = EstadoCargaAuditLog.cargando;
    notifyListeners();
    try {
      items = await _repo.listar();
      estado = EstadoCargaAuditLog.listo;
    } catch (e) {
      error = e.toString();
      estado = EstadoCargaAuditLog.error;
    }
    notifyListeners();
  }

  Future<bool> crear(AuditLog item) async {
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

  Future<bool> actualizar(String id, AuditLog item) async {
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
