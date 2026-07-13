/// Modelo de dominio: AsignacionPista
/// Generado a partir del esquema real del backend (introspección de Django).
class AsignacionPista {
  final String? id;
  final String vuelo;
  final String pista;
  final String tipoOperacion;
  final DateTime horaInicio;
  final DateTime horaFin;
  final DateTime? creadoEn;

  const AsignacionPista({
    this.id,
    required this.vuelo,
    required this.pista,
    required this.tipoOperacion,
    required this.horaInicio,
    required this.horaFin,
    this.creadoEn,
  });

  factory AsignacionPista.fromJson(Map<String, dynamic> json) {
    return AsignacionPista(
      id: json['id'] as String?,
      vuelo: json['vuelo'] as String? ?? '',
      pista: json['pista'] as String? ?? '',
      tipoOperacion: json['tipo_operacion'] as String? ?? '',
      horaInicio: DateTime.parse(json['hora_inicio'] as String),
      horaFin: DateTime.parse(json['hora_fin'] as String),
      creadoEn: json['creado_en'] != null ? DateTime.parse(json['creado_en'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'vuelo': vuelo,
      'pista': pista,
      'tipo_operacion': tipoOperacion,
      'hora_inicio': horaInicio.toIso8601String(),
      'hora_fin': horaFin.toIso8601String(),
      if (creadoEn != null) 'creado_en': creadoEn!.toIso8601String(),
    };
  }

  AsignacionPista copyWith({
    String? id,
    String? vuelo,
    String? pista,
    String? tipoOperacion,
    DateTime? horaInicio,
    DateTime? horaFin,
    DateTime? creadoEn,
  }) {
    return AsignacionPista(
      id: id ?? this.id,
      vuelo: vuelo ?? this.vuelo,
      pista: pista ?? this.pista,
      tipoOperacion: tipoOperacion ?? this.tipoOperacion,
      horaInicio: horaInicio ?? this.horaInicio,
      horaFin: horaFin ?? this.horaFin,
      creadoEn: creadoEn ?? this.creadoEn,
    );
  }
}
