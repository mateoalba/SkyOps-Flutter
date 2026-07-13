/// Modelo de dominio: Horario
/// Generado a partir del esquema real del backend (introspección de Django).
class Horario {
  final String? id;
  final String aerolinea;
  final String origen;
  final String destino;
  final String numeroVueloBase;
  final String horaSalida;
  final dynamic diasOperacion;
  final bool activo;
  final DateTime? creadoEn;

  const Horario({
    this.id,
    required this.aerolinea,
    required this.origen,
    required this.destino,
    required this.numeroVueloBase,
    required this.horaSalida,
    this.diasOperacion,
    required this.activo,
    this.creadoEn,
  });

  factory Horario.fromJson(Map<String, dynamic> json) {
    return Horario(
      id: json['id'] as String?,
      aerolinea: json['aerolinea'] as String? ?? '',
      origen: json['origen'] as String? ?? '',
      destino: json['destino'] as String? ?? '',
      numeroVueloBase: json['numero_vuelo_base'] as String? ?? '',
      horaSalida: json['hora_salida'] as String? ?? '',
      diasOperacion: json['dias_operacion'],
      activo: json['activo'] as bool? ?? false,
      creadoEn: json['creado_en'] != null ? DateTime.parse(json['creado_en'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'aerolinea': aerolinea,
      'origen': origen,
      'destino': destino,
      'numero_vuelo_base': numeroVueloBase,
      'hora_salida': horaSalida,
      'activo': activo,
      if (creadoEn != null) 'creado_en': creadoEn!.toIso8601String(),
    };
  }

  Horario copyWith({
    String? id,
    String? aerolinea,
    String? origen,
    String? destino,
    String? numeroVueloBase,
    String? horaSalida,
    dynamic diasOperacion,
    bool? activo,
    DateTime? creadoEn,
  }) {
    return Horario(
      id: id ?? this.id,
      aerolinea: aerolinea ?? this.aerolinea,
      origen: origen ?? this.origen,
      destino: destino ?? this.destino,
      numeroVueloBase: numeroVueloBase ?? this.numeroVueloBase,
      horaSalida: horaSalida ?? this.horaSalida,
      diasOperacion: diasOperacion ?? this.diasOperacion,
      activo: activo ?? this.activo,
      creadoEn: creadoEn ?? this.creadoEn,
    );
  }
}
