/// Modelo de dominio: Pista
/// Generado a partir del esquema real del backend (introspección de Django).
class Pista {
  final String? id;
  final String aeropuerto;
  final String identificador;
  final int longitudMetros;
  final String superficie;
  final String estado;
  final DateTime? creadoEn;

  const Pista({
    this.id,
    required this.aeropuerto,
    required this.identificador,
    required this.longitudMetros,
    required this.superficie,
    required this.estado,
    this.creadoEn,
  });

  factory Pista.fromJson(Map<String, dynamic> json) {
    return Pista(
      id: json['id'] as String?,
      aeropuerto: json['aeropuerto'] as String? ?? '',
      identificador: json['identificador'] as String? ?? '',
      longitudMetros: (json['longitud_metros'] as num?)?.toInt() ?? 0,
      superficie: json['superficie'] as String? ?? '',
      estado: json['estado'] as String? ?? '',
      creadoEn: json['creado_en'] != null ? DateTime.parse(json['creado_en'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'aeropuerto': aeropuerto,
      'identificador': identificador,
      'longitud_metros': longitudMetros,
      'superficie': superficie,
      'estado': estado,
      if (creadoEn != null) 'creado_en': creadoEn!.toIso8601String(),
    };
  }

  Pista copyWith({
    String? id,
    String? aeropuerto,
    String? identificador,
    int? longitudMetros,
    String? superficie,
    String? estado,
    DateTime? creadoEn,
  }) {
    return Pista(
      id: id ?? this.id,
      aeropuerto: aeropuerto ?? this.aeropuerto,
      identificador: identificador ?? this.identificador,
      longitudMetros: longitudMetros ?? this.longitudMetros,
      superficie: superficie ?? this.superficie,
      estado: estado ?? this.estado,
      creadoEn: creadoEn ?? this.creadoEn,
    );
  }
}
