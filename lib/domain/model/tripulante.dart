/// Modelo de dominio: Tripulante
/// Generado a partir del esquema real del backend (introspección de Django).
class Tripulante {
  final String? id;
  final String aerolinea;
  final String nombre;
  final String apellido;
  final String rol;
  final String numLicencia;
  final bool disponible;

  const Tripulante({
    this.id,
    required this.aerolinea,
    required this.nombre,
    required this.apellido,
    required this.rol,
    required this.numLicencia,
    required this.disponible,
  });

  factory Tripulante.fromJson(Map<String, dynamic> json) {
    return Tripulante(
      id: json['id'] as String?,
      aerolinea: json['aerolinea'] as String? ?? '',
      nombre: json['nombre'] as String? ?? '',
      apellido: json['apellido'] as String? ?? '',
      rol: json['rol'] as String? ?? '',
      numLicencia: json['num_licencia'] as String? ?? '',
      disponible: json['disponible'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'aerolinea': aerolinea,
      'nombre': nombre,
      'apellido': apellido,
      'rol': rol,
      'num_licencia': numLicencia,
      'disponible': disponible,
    };
  }

  Tripulante copyWith({
    String? id,
    String? aerolinea,
    String? nombre,
    String? apellido,
    String? rol,
    String? numLicencia,
    bool? disponible,
  }) {
    return Tripulante(
      id: id ?? this.id,
      aerolinea: aerolinea ?? this.aerolinea,
      nombre: nombre ?? this.nombre,
      apellido: apellido ?? this.apellido,
      rol: rol ?? this.rol,
      numLicencia: numLicencia ?? this.numLicencia,
      disponible: disponible ?? this.disponible,
    );
  }
}
