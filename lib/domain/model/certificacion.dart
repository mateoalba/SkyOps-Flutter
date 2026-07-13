/// Modelo de dominio: Certificacion
/// Generado a partir del esquema real del backend (introspección de Django).
class Certificacion {
  final String? id;
  final String tripulante;
  final String? tipoAeronaveHabilitado;
  final String tipo;
  final String estado;
  final String numeroCertificado;
  final String entidadEmisora;
  final DateTime fechaEmision;
  final DateTime fechaVencimiento;
  final String? observaciones;
  final DateTime? creadoEn;

  const Certificacion({
    this.id,
    required this.tripulante,
    this.tipoAeronaveHabilitado,
    required this.tipo,
    required this.estado,
    required this.numeroCertificado,
    required this.entidadEmisora,
    required this.fechaEmision,
    required this.fechaVencimiento,
    this.observaciones,
    this.creadoEn,
  });

  factory Certificacion.fromJson(Map<String, dynamic> json) {
    return Certificacion(
      id: json['id'] as String?,
      tripulante: json['tripulante'] as String? ?? '',
      tipoAeronaveHabilitado: json['tipo_aeronave_habilitado'] as String? ?? '',
      tipo: json['tipo'] as String? ?? '',
      estado: json['estado'] as String? ?? '',
      numeroCertificado: json['numero_certificado'] as String? ?? '',
      entidadEmisora: json['entidad_emisora'] as String? ?? '',
      fechaEmision: DateTime.parse(json['fecha_emision'] as String),
      fechaVencimiento: DateTime.parse(json['fecha_vencimiento'] as String),
      observaciones: json['observaciones'] as String? ?? '',
      creadoEn: json['creado_en'] != null ? DateTime.parse(json['creado_en'] as String) : null,
    );
  }

  // El backend define fecha_emision/fecha_vencimiento como DateField (solo
  // fecha, sin hora): espera "YYYY-MM-DD", no un datetime ISO completo.
  static String _soloFecha(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Map<String, dynamic> toJson() {
    return {
      'tripulante': tripulante,
      'tipo_aeronave_habilitado': tipoAeronaveHabilitado ?? '',
      'tipo': tipo,
      'estado': estado,
      'numero_certificado': numeroCertificado,
      'entidad_emisora': entidadEmisora,
      'fecha_emision': _soloFecha(fechaEmision),
      'fecha_vencimiento': _soloFecha(fechaVencimiento),
      // tipo_aeronave_habilitado y observaciones son blank=True SIN
      // null=True en el backend: aceptan cadena vacía pero no null.
      'observaciones': observaciones ?? '',
      if (creadoEn != null) 'creado_en': creadoEn!.toIso8601String(),
    };
  }

  Certificacion copyWith({
    String? id,
    String? tripulante,
    String? tipoAeronaveHabilitado,
    String? tipo,
    String? estado,
    String? numeroCertificado,
    String? entidadEmisora,
    DateTime? fechaEmision,
    DateTime? fechaVencimiento,
    String? observaciones,
    DateTime? creadoEn,
  }) {
    return Certificacion(
      id: id ?? this.id,
      tripulante: tripulante ?? this.tripulante,
      tipoAeronaveHabilitado: tipoAeronaveHabilitado ?? this.tipoAeronaveHabilitado,
      tipo: tipo ?? this.tipo,
      estado: estado ?? this.estado,
      numeroCertificado: numeroCertificado ?? this.numeroCertificado,
      entidadEmisora: entidadEmisora ?? this.entidadEmisora,
      fechaEmision: fechaEmision ?? this.fechaEmision,
      fechaVencimiento: fechaVencimiento ?? this.fechaVencimiento,
      observaciones: observaciones ?? this.observaciones,
      creadoEn: creadoEn ?? this.creadoEn,
    );
  }
}
