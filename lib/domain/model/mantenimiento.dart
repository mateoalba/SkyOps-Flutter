/// Modelo de dominio: Mantenimiento
/// Generado a partir del esquema real del backend (introspección de Django).
class Mantenimiento {
  final String? id;
  final String aeronave;
  final String? aeropuerto;
  final String tipo;
  final String estado;
  final String descripcion;
  final String tecnicoResponsable;
  final DateTime fechaInicio;
  final DateTime fechaFinEstimada;
  final DateTime? fechaFinReal;
  final double? costoEstimado;
  final double? costoReal;
  final int? horasFueraServicio;
  final String? observaciones;
  final DateTime? creadoEn;

  const Mantenimiento({
    this.id,
    required this.aeronave,
    this.aeropuerto,
    required this.tipo,
    required this.estado,
    required this.descripcion,
    required this.tecnicoResponsable,
    required this.fechaInicio,
    required this.fechaFinEstimada,
    this.fechaFinReal,
    this.costoEstimado,
    this.costoReal,
    this.horasFueraServicio,
    this.observaciones,
    this.creadoEn,
  });

  // El backend serializa los DecimalField (costo_estimado/costo_real) como
  // String (p.ej. "2500.00"), no como número JSON, así que hay que aceptar
  // ambas formas al parsear la respuesta.
  static double? _parseDouble(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v);
    return null;
  }

  factory Mantenimiento.fromJson(Map<String, dynamic> json) {
    return Mantenimiento(
      id: json['id'] as String?,
      aeronave: json['aeronave'] as String? ?? '',
      aeropuerto: json['aeropuerto'] as String?,
      tipo: json['tipo'] as String? ?? '',
      estado: json['estado'] as String? ?? '',
      descripcion: json['descripcion'] as String? ?? '',
      tecnicoResponsable: json['tecnico_responsable'] as String? ?? '',
      fechaInicio: DateTime.parse(json['fecha_inicio'] as String),
      fechaFinEstimada: DateTime.parse(json['fecha_fin_estimada'] as String),
      fechaFinReal: json['fecha_fin_real'] != null ? DateTime.parse(json['fecha_fin_real'] as String) : null,
      costoEstimado: _parseDouble(json['costo_estimado']),
      costoReal: _parseDouble(json['costo_real']),
      horasFueraServicio: (json['horas_fuera_servicio'] as num?)?.toInt(),
      observaciones: json['observaciones'] as String? ?? '',
      creadoEn: json['creado_en'] != null ? DateTime.parse(json['creado_en'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'aeronave': aeronave,
      'aeropuerto': aeropuerto,
      'tipo': tipo,
      'estado': estado,
      'descripcion': descripcion,
      'tecnico_responsable': tecnicoResponsable,
      'fecha_inicio': fechaInicio.toIso8601String(),
      'fecha_fin_estimada': fechaFinEstimada.toIso8601String(),
      if (fechaFinReal != null) 'fecha_fin_real': fechaFinReal!.toIso8601String(),
      'costo_estimado': costoEstimado,
      'costo_real': costoReal,
      'horas_fuera_servicio': horasFueraServicio,
      // El backend define observaciones como TextField(blank=True) SIN
      // null=True: acepta cadena vacía pero rechaza null ("this field may
      // not be null"). Si el usuario no escribe nada, se manda "" en vez
      // de dejar pasar el null que arma el formulario.
      'observaciones': observaciones ?? '',
      if (creadoEn != null) 'creado_en': creadoEn!.toIso8601String(),
    };
  }

  Mantenimiento copyWith({
    String? id,
    String? aeronave,
    String? aeropuerto,
    String? tipo,
    String? estado,
    String? descripcion,
    String? tecnicoResponsable,
    DateTime? fechaInicio,
    DateTime? fechaFinEstimada,
    DateTime? fechaFinReal,
    double? costoEstimado,
    double? costoReal,
    int? horasFueraServicio,
    String? observaciones,
    DateTime? creadoEn,
  }) {
    return Mantenimiento(
      id: id ?? this.id,
      aeronave: aeronave ?? this.aeronave,
      aeropuerto: aeropuerto ?? this.aeropuerto,
      tipo: tipo ?? this.tipo,
      estado: estado ?? this.estado,
      descripcion: descripcion ?? this.descripcion,
      tecnicoResponsable: tecnicoResponsable ?? this.tecnicoResponsable,
      fechaInicio: fechaInicio ?? this.fechaInicio,
      fechaFinEstimada: fechaFinEstimada ?? this.fechaFinEstimada,
      fechaFinReal: fechaFinReal ?? this.fechaFinReal,
      costoEstimado: costoEstimado ?? this.costoEstimado,
      costoReal: costoReal ?? this.costoReal,
      horasFueraServicio: horasFueraServicio ?? this.horasFueraServicio,
      observaciones: observaciones ?? this.observaciones,
      creadoEn: creadoEn ?? this.creadoEn,
    );
  }
}
