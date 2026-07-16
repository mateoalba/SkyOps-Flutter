/// Modelo de dominio: Vuelo
/// Generado a partir del esquema real del backend (introspección de Django).
class Vuelo {
  final String? id;
  final String aerolinea;
  final String? aeronave;
  final String origen;
  final String destino;
  final String? puerta;
  final String numeroVuelo;
  final DateTime salidaProgramada;
  final DateTime llegadaProgramada;
  final DateTime? salidaReal;
  final DateTime? llegadaReal;
  final String estado;
  final int? duracionMin;
  final double precioBase;
  // Asientos exactos (código "12A") asignados a cada clase — elegidos por
  // el admin en el mapa de asientos al crear/editar el vuelo. Vacíos ambos
  // (vuelos creados antes de esta función) = sin restricción de clase.
  final Set<String> asientosPrimera;
  final Set<String> asientosEjecutiva;
  final int? capacidadAeronave;

  const Vuelo({
    this.id,
    required this.aerolinea,
    this.aeronave,
    required this.origen,
    required this.destino,
    this.puerta,
    required this.numeroVuelo,
    required this.salidaProgramada,
    required this.llegadaProgramada,
    this.salidaReal,
    this.llegadaReal,
    required this.estado,
    this.duracionMin,
    this.precioBase = 0,
    this.asientosPrimera = const {},
    this.asientosEjecutiva = const {},
    this.capacidadAeronave,
  });

  static Set<String> _csvASet(dynamic valor) {
    final texto = valor?.toString() ?? '';
    if (texto.trim().isEmpty) return {};
    return texto.split(',').map((s) => s.trim().toUpperCase()).where((s) => s.isNotEmpty).toSet();
  }

  static String _setACsv(Set<String> valores) => valores.join(',');

  factory Vuelo.fromJson(Map<String, dynamic> json) {
    return Vuelo(
      id: json['id'] as String?,
      aerolinea: json['aerolinea'] as String? ?? '',
      aeronave: json['aeronave'] as String?,
      origen: json['origen'] as String? ?? '',
      destino: json['destino'] as String? ?? '',
      puerta: json['puerta'] as String?,
      numeroVuelo: json['numero_vuelo'] as String? ?? '',
      salidaProgramada: DateTime.parse(json['salida_programada'] as String),
      llegadaProgramada: DateTime.parse(json['llegada_programada'] as String),
      salidaReal: json['salida_real'] != null ? DateTime.parse(json['salida_real'] as String) : null,
      llegadaReal: json['llegada_real'] != null ? DateTime.parse(json['llegada_real'] as String) : null,
      estado: json['estado'] as String? ?? '',
      duracionMin: (json['duracion_min'] as num?)?.toInt(),
      // DRF serializa DecimalField como texto ("0.00") para no perder
      // precisión, así que se parsea siempre desde String por seguridad.
      precioBase: double.tryParse(json['precio_base']?.toString() ?? '') ?? 0,
      asientosPrimera: _csvASet(json['asientos_primera']),
      asientosEjecutiva: _csvASet(json['asientos_ejecutiva']),
      capacidadAeronave: (json['aeronave_capacidad'] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'aerolinea': aerolinea,
      'aeronave': aeronave,
      'origen': origen,
      'destino': destino,
      'puerta': puerta,
      'numero_vuelo': numeroVuelo,
      'salida_programada': salidaProgramada.toIso8601String(),
      'llegada_programada': llegadaProgramada.toIso8601String(),
      if (salidaReal != null) 'salida_real': salidaReal!.toIso8601String(),
      if (llegadaReal != null) 'llegada_real': llegadaReal!.toIso8601String(),
      'estado': estado,
      'duracion_min': duracionMin,
      'precio_base': precioBase,
      'asientos_primera': _setACsv(asientosPrimera),
      'asientos_ejecutiva': _setACsv(asientosEjecutiva),
    };
  }

  Vuelo copyWith({
    String? id,
    String? aerolinea,
    String? aeronave,
    String? origen,
    String? destino,
    String? puerta,
    String? numeroVuelo,
    DateTime? salidaProgramada,
    DateTime? llegadaProgramada,
    DateTime? salidaReal,
    DateTime? llegadaReal,
    String? estado,
    int? duracionMin,
    double? precioBase,
    Set<String>? asientosPrimera,
    Set<String>? asientosEjecutiva,
    int? capacidadAeronave,
  }) {
    return Vuelo(
      id: id ?? this.id,
      aerolinea: aerolinea ?? this.aerolinea,
      aeronave: aeronave ?? this.aeronave,
      origen: origen ?? this.origen,
      destino: destino ?? this.destino,
      puerta: puerta ?? this.puerta,
      numeroVuelo: numeroVuelo ?? this.numeroVuelo,
      salidaProgramada: salidaProgramada ?? this.salidaProgramada,
      llegadaProgramada: llegadaProgramada ?? this.llegadaProgramada,
      salidaReal: salidaReal ?? this.salidaReal,
      llegadaReal: llegadaReal ?? this.llegadaReal,
      estado: estado ?? this.estado,
      duracionMin: duracionMin ?? this.duracionMin,
      precioBase: precioBase ?? this.precioBase,
      asientosPrimera: asientosPrimera ?? this.asientosPrimera,
      asientosEjecutiva: asientosEjecutiva ?? this.asientosEjecutiva,
      capacidadAeronave: capacidadAeronave ?? this.capacidadAeronave,
    );
  }
}
