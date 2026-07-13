/// Modelo de dominio: Aeropuerto
/// Generado a partir del esquema real del backend (introspección de Django).
class Aeropuerto {
  final String? id;
  final String nombre;
  final String codigoIata;
  final String ciudad;
  final String pais;
  final double latitud;
  final double longitud;
  final String zonaHoraria;
  final String? fotoUrl;
  // Campo de solo lectura calculado por el backend (obj.puertas.count()).
  final int? totalPuertas;

  const Aeropuerto({
    this.id,
    required this.nombre,
    required this.codigoIata,
    required this.ciudad,
    required this.pais,
    required this.latitud,
    required this.longitud,
    required this.zonaHoraria,
    this.fotoUrl,
    this.totalPuertas,
  });

  factory Aeropuerto.fromJson(Map<String, dynamic> json) {
    return Aeropuerto(
      id: json['id'] as String?,
      nombre: json['nombre'] as String? ?? '',
      codigoIata: json['codigo_iata'] as String? ?? '',
      ciudad: json['ciudad'] as String? ?? '',
      pais: json['pais'] as String? ?? '',
      latitud: (json['latitud'] as num?)?.toDouble() ?? 0,
      longitud: (json['longitud'] as num?)?.toDouble() ?? 0,
      zonaHoraria: json['zona_horaria'] as String? ?? '',
      fotoUrl: json['foto_url'] as String?,
      totalPuertas: (json['total_puertas'] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'codigo_iata': codigoIata,
      'ciudad': ciudad,
      'pais': pais,
      'latitud': latitud,
      'longitud': longitud,
      'zona_horaria': zonaHoraria,
      // blank=True sin null=True en el backend: acepta cadena vacía, no null.
      'foto_url': fotoUrl ?? '',
    };
  }

  Aeropuerto copyWith({
    String? id,
    String? nombre,
    String? codigoIata,
    String? ciudad,
    String? pais,
    double? latitud,
    double? longitud,
    String? zonaHoraria,
    String? fotoUrl,
    int? totalPuertas,
  }) {
    return Aeropuerto(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      codigoIata: codigoIata ?? this.codigoIata,
      ciudad: ciudad ?? this.ciudad,
      pais: pais ?? this.pais,
      latitud: latitud ?? this.latitud,
      longitud: longitud ?? this.longitud,
      zonaHoraria: zonaHoraria ?? this.zonaHoraria,
      fotoUrl: fotoUrl ?? this.fotoUrl,
      totalPuertas: totalPuertas ?? this.totalPuertas,
    );
  }
}
