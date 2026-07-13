/// Modelo de dominio: Aerolinea
/// Generado a partir del esquema real del backend (introspección de Django).
class Aerolinea {
  final String? id;
  final String nombre;
  final String codigoIata;
  final String pais;
  final bool activa;
  final DateTime? creadoEn;

  const Aerolinea({
    this.id,
    required this.nombre,
    required this.codigoIata,
    required this.pais,
    required this.activa,
    this.creadoEn,
  });

  factory Aerolinea.fromJson(Map<String, dynamic> json) {
    return Aerolinea(
      id: json['id'] as String?,
      nombre: json['nombre'] as String? ?? '',
      codigoIata: json['codigo_iata'] as String? ?? '',
      pais: json['pais'] as String? ?? '',
      activa: json['activa'] as bool? ?? false,
      creadoEn: json['creado_en'] != null ? DateTime.parse(json['creado_en'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'codigo_iata': codigoIata,
      'pais': pais,
      'activa': activa,
      if (creadoEn != null) 'creado_en': creadoEn!.toIso8601String(),
    };
  }

  Aerolinea copyWith({
    String? id,
    String? nombre,
    String? codigoIata,
    String? pais,
    bool? activa,
    DateTime? creadoEn,
  }) {
    return Aerolinea(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      codigoIata: codigoIata ?? this.codigoIata,
      pais: pais ?? this.pais,
      activa: activa ?? this.activa,
      creadoEn: creadoEn ?? this.creadoEn,
    );
  }
}
