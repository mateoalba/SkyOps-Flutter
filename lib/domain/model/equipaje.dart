/// Modelo de dominio: Equipaje
/// Generado a partir del esquema real del backend (introspección de Django).
class Equipaje {
  final int? id;
  final String reserva;
  final String tipo;
  final double pesoKg;
  final String? descripcion;
  final String codigoEtiqueta;
  final String estado;
  final double costoAdicional;
  final DateTime? fechaRegistro;

  const Equipaje({
    this.id,
    required this.reserva,
    required this.tipo,
    required this.pesoKg,
    this.descripcion,
    required this.codigoEtiqueta,
    required this.estado,
    required this.costoAdicional,
    this.fechaRegistro,
  });

  // El backend serializa los DecimalField (peso_kg/costo_adicional) como
  // String (p.ej. "23.50"), no como número JSON, así que hay que aceptar
  // ambas formas al parsear la respuesta.
  static double? _parseDouble(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v);
    return null;
  }

  factory Equipaje.fromJson(Map<String, dynamic> json) {
    return Equipaje(
      id: json['id'] as int?,
      reserva: json['reserva'] as String? ?? '',
      tipo: json['tipo'] as String? ?? '',
      pesoKg: _parseDouble(json['peso_kg']) ?? 0,
      descripcion: json['descripcion'] as String? ?? '',
      codigoEtiqueta: json['codigo_etiqueta'] as String? ?? '',
      estado: json['estado'] as String? ?? '',
      costoAdicional: _parseDouble(json['costo_adicional']) ?? 0,
      fechaRegistro: json['fecha_registro'] != null ? DateTime.parse(json['fecha_registro'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'reserva': reserva,
      'tipo': tipo,
      'peso_kg': pesoKg,
      // descripcion es blank=True SIN null=True en el backend: acepta
      // cadena vacía pero no null.
      'descripcion': descripcion ?? '',
      'codigo_etiqueta': codigoEtiqueta,
      'estado': estado,
      'costo_adicional': costoAdicional,
      if (fechaRegistro != null) 'fecha_registro': fechaRegistro!.toIso8601String(),
    };
  }

  Equipaje copyWith({
    int? id,
    String? reserva,
    String? tipo,
    double? pesoKg,
    String? descripcion,
    String? codigoEtiqueta,
    String? estado,
    double? costoAdicional,
    DateTime? fechaRegistro,
  }) {
    return Equipaje(
      id: id ?? this.id,
      reserva: reserva ?? this.reserva,
      tipo: tipo ?? this.tipo,
      pesoKg: pesoKg ?? this.pesoKg,
      descripcion: descripcion ?? this.descripcion,
      codigoEtiqueta: codigoEtiqueta ?? this.codigoEtiqueta,
      estado: estado ?? this.estado,
      costoAdicional: costoAdicional ?? this.costoAdicional,
      fechaRegistro: fechaRegistro ?? this.fechaRegistro,
    );
  }
}
