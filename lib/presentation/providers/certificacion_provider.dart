import 'package:flutter/foundation.dart';
import '../../domain/model/certificacion.dart';
import '../../domain/repository/certificacion_repository.dart';

enum EstadoCargaCertificacion { inicial, cargando, listo, error }

class CertificacionProvider extends ChangeNotifier {
  final CertificacionRepository _repo;
  CertificacionProvider(this._repo);

  EstadoCargaCertificacion estado = EstadoCargaCertificacion.inicial;
  List<Certificacion> items = [];
  String? error;

  bool get cargando => estado == EstadoCargaCertificacion.cargando;

  Future<void> cargar({bool forzar = false}) async {
    if (!forzar && estado == EstadoCargaCertificacion.listo) return;
    estado = EstadoCargaCertificacion.cargando;
    notifyListeners();
    try {
      items = await _repo.listar();
      estado = EstadoCargaCertificacion.listo;
    } catch (e) {
      error = e.toString();
      estado = EstadoCargaCertificacion.error;
    }
    notifyListeners();
  }

  Future<bool> crear(Certificacion item) async {
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

  Future<bool> actualizar(String id, Certificacion item) async {
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
