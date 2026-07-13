/// Modelo de dominio: TipoAeronave
/// Generado a partir del esquema real del backend (introspección de Django).
class TipoAeronave {
  final int? id;
  final String fabricante;
  final String modelo;
  final String? codigoIata;
  final String categoria;
  final int capacidadPasajerosMin;
  final int capacidadPasajerosMax;
  final int autonomiaKm;
  final int velocidadCruceroKmh;
  final String? descripcion;
  final bool enProduccion;

  const TipoAeronave({
    this.id,
    required this.fabricante,
    required this.modelo,
    this.codigoIata,
    required this.categoria,
    required this.capacidadPasajerosMin,
    required this.capacidadPasajerosMax,
    required this.autonomiaKm,
    required this.velocidadCruceroKmh,
    this.descripcion,
    required this.enProduccion,
  });

  factory TipoAeronave.fromJson(Map<String, dynamic> json) {
    return TipoAeronave(
      id: json['id'] as int?,
      fabricante: json['fabricante'] as String? ?? '',
      modelo: json['modelo'] as String? ?? '',
      codigoIata: json['codigo_iata'] as String? ?? '',
      categoria: json['categoria'] as String? ?? '',
      capacidadPasajerosMin: (json['capacidad_pasajeros_min'] as num?)?.toInt() ?? 0,
      capacidadPasajerosMax: (json['capacidad_pasajeros_max'] as num?)?.toInt() ?? 0,
      autonomiaKm: (json['autonomia_km'] as num?)?.toInt() ?? 0,
      velocidadCruceroKmh: (json['velocidad_crucero_kmh'] as num?)?.toInt() ?? 0,
      descripcion: json['descripcion'] as String? ?? '',
      enProduccion: json['en_produccion'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fabricante': fabricante,
      'modelo': modelo,
      // codigo_iata y descripcion son blank=True SIN null=True en el
      // backend: aceptan cadena vacía pero no null.
      'codigo_iata': codigoIata ?? '',
      'categoria': categoria,
      'capacidad_pasajeros_min': capacidadPasajerosMin,
      'capacidad_pasajeros_max': capacidadPasajerosMax,
      'autonomia_km': autonomiaKm,
      'velocidad_crucero_kmh': velocidadCruceroKmh,
      'descripcion': descripcion ?? '',
      'en_produccion': enProduccion,
    };
  }

  TipoAeronave copyWith({
    int? id,
    String? fabricante,
    String? modelo,
    String? codigoIata,
    String? categoria,
    int? capacidadPasajerosMin,
    int? capacidadPasajerosMax,
    int? autonomiaKm,
    int? velocidadCruceroKmh,
    String? descripcion,
    bool? enProduccion,
  }) {
    return TipoAeronave(
      id: id ?? this.id,
      fabricante: fabricante ?? this.fabricante,
      modelo: modelo ?? this.modelo,
      codigoIata: codigoIata ?? this.codigoIata,
      categoria: categoria ?? this.categoria,
      capacidadPasajerosMin: capacidadPasajerosMin ?? this.capacidadPasajerosMin,
      capacidadPasajerosMax: capacidadPasajerosMax ?? this.capacidadPasajerosMax,
      autonomiaKm: autonomiaKm ?? this.autonomiaKm,
      velocidadCruceroKmh: velocidadCruceroKmh ?? this.velocidadCruceroKmh,
      descripcion: descripcion ?? this.descripcion,
      enProduccion: enProduccion ?? this.enProduccion,
    );
  }
}
