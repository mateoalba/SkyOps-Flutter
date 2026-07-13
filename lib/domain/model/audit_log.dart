/// Modelo de dominio: AuditLog
/// Generado a partir del esquema real del backend (introspección de Django).
class AuditLog {
  final String? id;
  final int? usuario;
  final String accion;
  final int? contentType;
  final String? objectId;
  final String? descripcion;
  final dynamic datosAnteriores;
  final dynamic datosNuevos;
  final String? ipAddress;
  final DateTime? fechaHora;

  const AuditLog({
    this.id,
    this.usuario,
    required this.accion,
    this.contentType,
    this.objectId,
    this.descripcion,
    this.datosAnteriores,
    this.datosNuevos,
    this.ipAddress,
    this.fechaHora,
  });

  factory AuditLog.fromJson(Map<String, dynamic> json) {
    return AuditLog(
      id: json['id'] as String?,
      usuario: (json['usuario'] as num?)?.toInt(),
      accion: json['accion'] as String? ?? '',
      contentType: (json['content_type'] as num?)?.toInt(),
      objectId: json['object_id'] as String? ?? '',
      descripcion: json['descripcion'] as String? ?? '',
      datosAnteriores: json['datos_anteriores'],
      datosNuevos: json['datos_nuevos'],
      ipAddress: json['ip_address'] as String?,
      fechaHora: json['fecha_hora'] != null ? DateTime.parse(json['fecha_hora'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'usuario': usuario,
      'accion': accion,
      'content_type': contentType,
      // object_id y descripcion son blank=True SIN null=True en el
      // backend: aceptan cadena vacía pero no null.
      'object_id': objectId ?? '',
      'descripcion': descripcion ?? '',
      'ip_address': ipAddress,
      if (fechaHora != null) 'fecha_hora': fechaHora!.toIso8601String(),
    };
  }

  AuditLog copyWith({
    String? id,
    int? usuario,
    String? accion,
    int? contentType,
    String? objectId,
    String? descripcion,
    dynamic datosAnteriores,
    dynamic datosNuevos,
    String? ipAddress,
    DateTime? fechaHora,
  }) {
    return AuditLog(
      id: id ?? this.id,
      usuario: usuario ?? this.usuario,
      accion: accion ?? this.accion,
      contentType: contentType ?? this.contentType,
      objectId: objectId ?? this.objectId,
      descripcion: descripcion ?? this.descripcion,
      datosAnteriores: datosAnteriores ?? this.datosAnteriores,
      datosNuevos: datosNuevos ?? this.datosNuevos,
      ipAddress: ipAddress ?? this.ipAddress,
      fechaHora: fechaHora ?? this.fechaHora,
    );
  }
}
