/// Modelo de dominio: Asignacion
/// Generado a partir del esquema real del backend (introspección de Django).
class Asignacion {
  final String? id;
  final String vuelo;
  final String tripulante;
  final String rolAsignado;

  const Asignacion({
    this.id,
    required this.vuelo,
    required this.tripulante,
    required this.rolAsignado,
  });

  factory Asignacion.fromJson(Map<String, dynamic> json) {
    return Asignacion(
      id: json['id'] as String?,
      vuelo: json['vuelo'] as String? ?? '',
      tripulante: json['tripulante'] as String? ?? '',
      rolAsignado: json['rol_asignado'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'vuelo': vuelo,
      'tripulante': tripulante,
      'rol_asignado': rolAsignado,
    };
  }

  Asignacion copyWith({
    String? id,
    String? vuelo,
    String? tripulante,
    String? rolAsignado,
  }) {
    return Asignacion(
      id: id ?? this.id,
      vuelo: vuelo ?? this.vuelo,
      tripulante: tripulante ?? this.tripulante,
      rolAsignado: rolAsignado ?? this.rolAsignado,
    );
  }
}
