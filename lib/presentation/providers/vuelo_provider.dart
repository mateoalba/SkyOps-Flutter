import 'package:flutter/foundation.dart';
import '../../domain/model/vuelo.dart';
import '../../domain/repository/vuelo_repository.dart';

enum EstadoCargaVuelo { inicial, cargando, listo, error }

class VueloProvider extends ChangeNotifier {
  final VueloRepository _repo;
  VueloProvider(this._repo);

  EstadoCargaVuelo estado = EstadoCargaVuelo.inicial;
  List<Vuelo> items = [];
  String? error;

  bool get cargando => estado == EstadoCargaVuelo.cargando;

  // --- Búsqueda de vuelos disponibles (flujo de pasajero) ---
  bool buscando = false;
  List<Vuelo> resultadosBusqueda = [];
  String? errorBusqueda;
  bool _buscoAlMenosUnaVez = false;
  bool get buscoAlMenosUnaVez => _buscoAlMenosUnaVez;

  Future<void> buscarVuelos({
    String? origenCodigo,
    String? destinoCodigo,
    DateTime? fecha,
  }) async {
    buscando = true;
    errorBusqueda = null;
    _buscoAlMenosUnaVez = true;
    notifyListeners();
    try {
      resultadosBusqueda = await _repo.buscar(
        origenCodigo: origenCodigo,
        destinoCodigo: destinoCodigo,
        fecha: fecha,
      );
    } catch (e) {
      errorBusqueda = e.toString();
      resultadosBusqueda = [];
    }
    buscando = false;
    notifyListeners();
  }

  Future<void> cargar({bool forzar = false}) async {
    if (!forzar && estado == EstadoCargaVuelo.listo) return;
    estado = EstadoCargaVuelo.cargando;
    notifyListeners();
    try {
      items = await _repo.listar();
      estado = EstadoCargaVuelo.listo;
    } catch (e) {
      error = e.toString();
      estado = EstadoCargaVuelo.error;
    }
    notifyListeners();
  }

  Future<bool> crear(Vuelo item) async {
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

  Future<bool> actualizar(String id, Vuelo item) async {
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

  final Map<String, List<String>> _cacheAsientosOcupados = {};

  /// Devuelve los números de asiento ya reservados (no cancelados) de un
  /// vuelo, para pintar el mapa de asientos. Se cachea por vuelo dentro de
  /// la sesión; usa [forzar] para recargar tras hacer una reserva.
  Future<List<String>> asientosOcupados(String vueloId, {bool forzar = false}) async {
    if (!forzar && _cacheAsientosOcupados.containsKey(vueloId)) {
      return _cacheAsientosOcupados[vueloId]!;
    }
    try {
      final lista = await _repo.asientosOcupados(vueloId);
      _cacheAsientosOcupados[vueloId] = lista;
      return lista;
    } catch (e) {
      return _cacheAsientosOcupados[vueloId] ?? [];
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
