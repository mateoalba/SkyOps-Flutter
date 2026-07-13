/// Modelo de dominio: Incidente
/// Generado a partir del esquema real del backend (introspección de Django).
class Incidente {
  final String? id;
  final String vuelo;
  final String tipo;
  final String descripcion;
  final String severidad;
  final DateTime? reportadoEn;
  final String estadoResolucion;

  const Incidente({
    this.id,
    required this.vuelo,
    required this.tipo,
    required this.descripcion,
    required this.severidad,
    this.reportadoEn,
    required this.estadoResolucion,
  });

  factory Incidente.fromJson(Map<String, dynamic> json) {
    return Incidente(
      id: json['id'] as String?,
      vuelo: json['vuelo'] as String? ?? '',
      tipo: json['tipo'] as String? ?? '',
      descripcion: json['descripcion'] as String? ?? '',
      severidad: json['severidad'] as String? ?? '',
      reportadoEn: json['reportado_en'] != null ? DateTime.parse(json['reportado_en'] as String) : null,
      estadoResolucion: json['estado_resolucion'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'vuelo': vuelo,
      'tipo': tipo,
      'descripcion': descripcion,
      'severidad': severidad,
      if (reportadoEn != null) 'reportado_en': reportadoEn!.toIso8601String(),
      'estado_resolucion': estadoResolucion,
    };
  }

  Incidente copyWith({
    String? id,
    String? vuelo,
    String? tipo,
    String? descripcion,
    String? severidad,
    DateTime? reportadoEn,
    String? estadoResolucion,
  }) {
    return Incidente(
      id: id ?? this.id,
      vuelo: vuelo ?? this.vuelo,
      tipo: tipo ?? this.tipo,
      descripcion: descripcion ?? this.descripcion,
      severidad: severidad ?? this.severidad,
      reportadoEn: reportadoEn ?? this.reportadoEn,
      estadoResolucion: estadoResolucion ?? this.estadoResolucion,
    );
  }
}
