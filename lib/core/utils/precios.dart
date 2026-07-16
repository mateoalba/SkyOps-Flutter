/// Multiplicador de precio por clase de cabina sobre el precio_base del
/// vuelo (que representa el precio de económica). Debe coincidir EXACTO
/// con MULTIPLICADOR_CLASE en airport/serializers/reserva.py del backend,
/// para que el precio estimado que se muestra aquí antes de guardar
/// coincida con el precio real que calcula y "congela" el servidor.
const Map<String, double> multiplicadorClase = {
  'economica': 1.0,
  'ejecutiva': 1.8,
  'primera': 2.5,
};

/// Calcula el precio de una clase específica a partir del precio_base
/// (económica) de un vuelo.
double precioPorClase(double precioBase, String clase) {
  final multiplicador = multiplicadorClase[clase] ?? 1.0;
  return precioBase * multiplicador;
}
