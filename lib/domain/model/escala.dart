/// Modelo de dominio: Escala
/// Generado a partir del esquema real del backend (introspección de Django).
class Escala {
  final String? id;
  final String vuelo;
  final String aeropuertoEscala;
  final int numeroSecuencia;
  final DateTime horaLlegada;
  final DateTime horaSalida;
  final DateTime? creadoEn;

  const Escala({
    this.id,
    required this.vuelo,
    required this.aeropuertoEscala,
    required this.numeroSecuencia,
    required this.horaLlegada,
    required this.horaSalida,
    this.creadoEn,
  });

  factory Escala.fromJson(Map<String, dynamic> json) {
    return Escala(
      id: json['id'] as String?,
      vuelo: json['vuelo'] as String? ?? '',
      aeropuertoEscala: json['aeropuerto_escala'] as String? ?? '',
      numeroSecuencia: (json['numero_secuencia'] as num?)?.toInt() ?? 0,
      horaLlegada: DateTime.parse(json['hora_llegada'] as String),
      horaSalida: DateTime.parse(json['hora_salida'] as String),
      creadoEn: json['creado_en'] != null ? DateTime.parse(json['creado_en'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'vuelo': vuelo,
      'aeropuerto_escala': aeropuertoEscala,
      'numero_secuencia': numeroSecuencia,
      'hora_llegada': horaLlegada.toIso8601String(),
      'hora_salida': horaSalida.toIso8601String(),
      if (creadoEn != null) 'creado_en': creadoEn!.toIso8601String(),
    };
  }

  Escala copyWith({
    String? id,
    String? vuelo,
    String? aeropuertoEscala,
    int? numeroSecuencia,
    DateTime? horaLlegada,
    DateTime? horaSalida,
    DateTime? creadoEn,
  }) {
    return Escala(
      id: id ?? this.id,
      vuelo: vuelo ?? this.vuelo,
      aeropuertoEscala: aeropuertoEscala ?? this.aeropuertoEscala,
      numeroSecuencia: numeroSecuencia ?? this.numeroSecuencia,
      horaLlegada: horaLlegada ?? this.horaLlegada,
      horaSalida: horaSalida ?? this.horaSalida,
      creadoEn: creadoEn ?? this.creadoEn,
    );
  }
}
