import 'package:flutter/foundation.dart';
import '../../domain/model/notificacion.dart';
import '../../domain/repository/notificacion_repository.dart';

enum EstadoCargaNotificacion { inicial, cargando, listo, error }

class NotificacionProvider extends ChangeNotifier {
  final NotificacionRepository _repo;
  NotificacionProvider(this._repo);

  EstadoCargaNotificacion estado = EstadoCargaNotificacion.inicial;
  List<Notificacion> items = [];
  String? error;

  bool get cargando => estado == EstadoCargaNotificacion.cargando;

  /// Cantidad de notificaciones que todavía no se marcaron como leídas
  /// (cualquier estado distinto de 'leida': pendiente, enviada, fallida).
  /// Se usa para el numerito rojo sobre el ícono de la campana.
  int get noLeidas => items.where((n) => n.estado != 'leida').length;

  Future<void> cargar({bool forzar = false}) async {
    if (!forzar && estado == EstadoCargaNotificacion.listo) return;
    estado = EstadoCargaNotificacion.cargando;
    notifyListeners();
    try {
      items = await _repo.listar();
      estado = EstadoCargaNotificacion.listo;
    } catch (e) {
      error = e.toString();
      estado = EstadoCargaNotificacion.error;
    }
    notifyListeners();
  }

  Future<bool> crear(Notificacion item) async {
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

  Future<bool> actualizar(int id, Notificacion item) async {
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

  /// Marca una notificación como leída (avisa al backend y actualiza el
  /// estado local al toque, sin esperar un recargar() completo) para que
  /// el numerito de [noLeidas] baje de inmediato al abrir el detalle.
  Future<void> marcarLeida(int id) async {
    final indice = items.indexWhere((n) => n.id == id);
    if (indice == -1 || items[indice].estado == 'leida') return;
    try {
      await _repo.marcarLeida(id);
      final actualizado = items[indice].copyWith(estado: 'leida', fechaLectura: DateTime.now());
      items = [...items]..[indice] = actualizado;
      notifyListeners();
    } catch (_) {
      // Silencioso: no vale la pena bloquear la vista de detalle por esto.
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
