/// Modelo de dominio: BannerPromocional
/// Contenido configurable por un administrador para un espacio fijo del
/// diseño (dashboard, vuelos, oferta_1/2/3, tarjetas del carrusel público,
/// encabezado del login). 'titulo'/'texto' son opcionales porque varios
/// espacios (dashboard, vuelos, ofertas) solo usan la imagen.
class BannerPromocional {
  final String clave;
  final String titulo;
  final String texto;
  final String imagenUrl;
  final DateTime? actualizadoEn;

  const BannerPromocional({
    required this.clave,
    this.titulo = '',
    this.texto = '',
    required this.imagenUrl,
    this.actualizadoEn,
  });

  bool get tieneImagen => imagenUrl.trim().isNotEmpty;

  factory BannerPromocional.fromJson(Map<String, dynamic> json) {
    return BannerPromocional(
      clave: json['clave'] as String? ?? '',
      titulo: json['titulo'] as String? ?? '',
      texto: json['texto'] as String? ?? '',
      imagenUrl: json['imagen_url'] as String? ?? '',
      actualizadoEn: json['actualizado_en'] != null ? DateTime.tryParse(json['actualizado_en'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'titulo': titulo,
      'texto': texto,
      'imagen_url': imagenUrl,
    };
  }
}
