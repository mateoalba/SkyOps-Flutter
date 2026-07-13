/// Modelo de dominio: TarjetaEmbarque
/// Generado a partir del esquema real del backend (introspección de Django).
class TarjetaEmbarque {
  final int? id;
  final String reserva;
  final String codigoBarras;
  final String asiento;
  final String puertaEmbarque;
  final String? grupoEmbarque;
  final DateTime horaLimiteEmbarque;
  final String estado;
  final DateTime? fechaEmision;
  final bool checkInOnline;
  final String? observaciones;

  const TarjetaEmbarque({
    this.id,
    required this.reserva,
    required this.codigoBarras,
    required this.asiento,
    required this.puertaEmbarque,
    this.grupoEmbarque,
    required this.horaLimiteEmbarque,
    required this.estado,
    this.fechaEmision,
    required this.checkInOnline,
    this.observaciones,
  });

  factory TarjetaEmbarque.fromJson(Map<String, dynamic> json) {
    return TarjetaEmbarque(
      id: json['id'] as int?,
      reserva: json['reserva'] as String? ?? '',
      codigoBarras: json['codigo_barras'] as String? ?? '',
      asiento: json['asiento'] as String? ?? '',
      puertaEmbarque: json['puerta_embarque'] as String? ?? '',
      grupoEmbarque: json['grupo_embarque'] as String? ?? '',
      horaLimiteEmbarque: DateTime.parse(json['hora_limite_embarque'] as String),
      estado: json['estado'] as String? ?? '',
      fechaEmision: json['fecha_emision'] != null ? DateTime.parse(json['fecha_emision'] as String) : null,
      checkInOnline: json['check_in_online'] as bool? ?? false,
      observaciones: json['observaciones'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'reserva': reserva,
      'codigo_barras': codigoBarras,
      'asiento': asiento,
      'puerta_embarque': puertaEmbarque,
      // grupo_embarque y observaciones son blank=True SIN null=True en el
      // backend: aceptan cadena vacía pero no null.
      'grupo_embarque': grupoEmbarque ?? '',
      'hora_limite_embarque': horaLimiteEmbarque.toIso8601String(),
      'estado': estado,
      if (fechaEmision != null) 'fecha_emision': fechaEmision!.toIso8601String(),
      'check_in_online': checkInOnline,
      'observaciones': observaciones ?? '',
    };
  }

  TarjetaEmbarque copyWith({
    int? id,
    String? reserva,
    String? codigoBarras,
    String? asiento,
    String? puertaEmbarque,
    String? grupoEmbarque,
    DateTime? horaLimiteEmbarque,
    String? estado,
    DateTime? fechaEmision,
    bool? checkInOnline,
    String? observaciones,
  }) {
    return TarjetaEmbarque(
      id: id ?? this.id,
      reserva: reserva ?? this.reserva,
      codigoBarras: codigoBarras ?? this.codigoBarras,
      asiento: asiento ?? this.asiento,
      puertaEmbarque: puertaEmbarque ?? this.puertaEmbarque,
      grupoEmbarque: grupoEmbarque ?? this.grupoEmbarque,
      horaLimiteEmbarque: horaLimiteEmbarque ?? this.horaLimiteEmbarque,
      estado: estado ?? this.estado,
      fechaEmision: fechaEmision ?? this.fechaEmision,
      checkInOnline: checkInOnline ?? this.checkInOnline,
      observaciones: observaciones ?? this.observaciones,
    );
  }
}
