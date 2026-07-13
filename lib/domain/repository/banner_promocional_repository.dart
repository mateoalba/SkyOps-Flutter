import '../model/banner_promocional.dart';

abstract class BannerPromocionalRepository {
  Future<List<BannerPromocional>> listar();
  Future<BannerPromocional> guardar(String clave, String imagenUrl);

  /// Igual que [guardar] pero también permite mandar titulo/texto (para
  /// las tarjetas del carrusel público y el encabezado del login). Solo
  /// se envían los campos no nulos.
  Future<BannerPromocional> guardarContenido(
    String clave, {
    String? titulo,
    String? texto,
    String? imagenUrl,
  });
}
