import 'package:flutter/foundation.dart';
import '../../domain/model/banner_promocional.dart';
import '../../domain/repository/banner_promocional_repository.dart';

enum EstadoCargaBanner { inicial, cargando, listo, error }

/// Mantiene en memoria las imágenes promocionales configuradas por un
/// admin (dashboard, vuelos, oferta_1, oferta_2, oferta_3) para que todas
/// las pantallas las lean sin tener que pedirlas una por una.
class BannerPromocionalProvider extends ChangeNotifier {
  final BannerPromocionalRepository _repo;
  BannerPromocionalProvider(this._repo);

  EstadoCargaBanner estado = EstadoCargaBanner.inicial;
  Map<String, BannerPromocional> _items = {};
  String? error;

  bool get cargando => estado == EstadoCargaBanner.cargando;

  /// Devuelve la URL de imagen para esa clave, o null si el admin todavía
  /// no ha puesto ninguna.
  String? urlPara(String clave) {
    final url = _items[clave]?.imagenUrl;
    return (url != null && url.trim().isNotEmpty) ? url : null;
  }

  /// Título configurado por el admin para esa clave (tarjetas del
  /// carrusel público), o null si no hay ninguno guardado todavía.
  String? tituloPara(String clave) {
    final t = _items[clave]?.titulo;
    return (t != null && t.trim().isNotEmpty) ? t : null;
  }

  /// Texto configurado por el admin para esa clave, o null si no hay
  /// ninguno guardado todavía.
  String? textoPara(String clave) {
    final t = _items[clave]?.texto;
    return (t != null && t.trim().isNotEmpty) ? t : null;
  }

  Future<void> cargar({bool forzar = false}) async {
    if (!forzar && estado == EstadoCargaBanner.listo) return;
    estado = EstadoCargaBanner.cargando;
    notifyListeners();
    try {
      final lista = await _repo.listar();
      _items = {for (final b in lista) b.clave: b};
      estado = EstadoCargaBanner.listo;
    } catch (e) {
      error = e.toString();
      estado = EstadoCargaBanner.error;
    }
    notifyListeners();
  }

  Future<bool> guardar(String clave, String imagenUrl) async {
    try {
      final actualizado = await _repo.guardar(clave, imagenUrl);
      _items = {..._items, actualizado.clave: actualizado};
      notifyListeners();
      return true;
    } catch (e) {
      error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Guarda título/texto/imagen para el contenido público (carrusel de
  /// bienvenida, encabezado del login). Solo manda los campos no nulos.
  Future<bool> guardarContenido(
    String clave, {
    String? titulo,
    String? texto,
    String? imagenUrl,
  }) async {
    try {
      final actualizado = await _repo.guardarContenido(
        clave,
        titulo: titulo,
        texto: texto,
        imagenUrl: imagenUrl,
      );
      _items = {..._items, actualizado.clave: actualizado};
      notifyListeners();
      return true;
    } catch (e) {
      error = e.toString();
      notifyListeners();
      return false;
    }
  }
}
