/// Modelo de dominio: Notificacion
/// Generado a partir del esquema real del backend (introspección de Django).
class Notificacion {
  final int? id;
  final String pasajero;
  final String? vuelo;
  final String tipo;
  final String canal;
  final String asunto;
  final String mensaje;
  final String estado;
  final DateTime? fechaEnvio;
  final DateTime? fechaLectura;
  final DateTime? creadaEn;

  const Notificacion({
    this.id,
    required this.pasajero,
    this.vuelo,
    required this.tipo,
    required this.canal,
    required this.asunto,
    required this.mensaje,
    required this.estado,
    this.fechaEnvio,
    this.fechaLectura,
    this.creadaEn,
  });

  factory Notificacion.fromJson(Map<String, dynamic> json) {
    return Notificacion(
      id: json['id'] as int?,
      pasajero: json['pasajero'] as String? ?? '',
      vuelo: json['vuelo'] as String?,
      tipo: json['tipo'] as String? ?? '',
      canal: json['canal'] as String? ?? '',
      asunto: json['asunto'] as String? ?? '',
      mensaje: json['mensaje'] as String? ?? '',
      estado: json['estado'] as String? ?? '',
      fechaEnvio: json['fecha_envio'] != null ? DateTime.parse(json['fecha_envio'] as String) : null,
      fechaLectura: json['fecha_lectura'] != null ? DateTime.parse(json['fecha_lectura'] as String) : null,
      creadaEn: json['creada_en'] != null ? DateTime.parse(json['creada_en'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pasajero': pasajero,
      'vuelo': vuelo,
      'tipo': tipo,
      'canal': canal,
      'asunto': asunto,
      'mensaje': mensaje,
      'estado': estado,
      if (fechaEnvio != null) 'fecha_envio': fechaEnvio!.toIso8601String(),
      if (fechaLectura != null) 'fecha_lectura': fechaLectura!.toIso8601String(),
      if (creadaEn != null) 'creada_en': creadaEn!.toIso8601String(),
    };
  }

  Notificacion copyWith({
    int? id,
    String? pasajero,
    String? vuelo,
    String? tipo,
    String? canal,
    String? asunto,
    String? mensaje,
    String? estado,
    DateTime? fechaEnvio,
    DateTime? fechaLectura,
    DateTime? creadaEn,
  }) {
    return Notificacion(
      id: id ?? this.id,
      pasajero: pasajero ?? this.pasajero,
      vuelo: vuelo ?? this.vuelo,
      tipo: tipo ?? this.tipo,
      canal: canal ?? this.canal,
      asunto: asunto ?? this.asunto,
      mensaje: mensaje ?? this.mensaje,
      estado: estado ?? this.estado,
      fechaEnvio: fechaEnvio ?? this.fechaEnvio,
      fechaLectura: fechaLectura ?? this.fechaLectura,
      creadaEn: creadaEn ?? this.creadaEn,
    );
  }
}
