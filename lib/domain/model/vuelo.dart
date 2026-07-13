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
  });

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
    );
  }
}
