/// Modelo de dominio: SesionUsuario
/// Generado a partir del esquema real del backend (introspección de Django).
class SesionUsuario {
  final String? id;
  final int? usuario;
  final String ipAddress;
  final String? userAgent;
  final String resultado;
  final String? tokenJti;
  final DateTime? fechaHora;
  final DateTime? fechaCierre;

  // Campos de solo lectura que agrega el serializer del backend, para no
  // tener que cruzar con el provider de PerfilUsuario solo para pintar la
  // lista.
  final String? username;
  final String? resultadoDisplay;
  final int? duracionMinutos;

  const SesionUsuario({
    this.id,
    this.usuario,
    required this.ipAddress,
    this.userAgent,
    required this.resultado,
    this.tokenJti,
    this.fechaHora,
    this.fechaCierre,
    this.username,
    this.resultadoDisplay,
    this.duracionMinutos,
  });

  factory SesionUsuario.fromJson(Map<String, dynamic> json) {
    return SesionUsuario(
      id: json['id'] as String?,
      usuario: (json['usuario'] as num?)?.toInt(),
      ipAddress: json['ip_address'] as String? ?? '',
      userAgent: json['user_agent'] as String? ?? '',
      resultado: json['resultado'] as String? ?? '',
      tokenJti: json['token_jti'] as String? ?? '',
      fechaHora: json['fecha_hora'] != null ? DateTime.parse(json['fecha_hora'] as String) : null,
      fechaCierre: json['fecha_cierre'] != null ? DateTime.parse(json['fecha_cierre'] as String) : null,
      username: json['username'] as String?,
      resultadoDisplay: json['resultado_display'] as String?,
      duracionMinutos: (json['duracion_minutos'] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'usuario': usuario,
      'ip_address': ipAddress,
      // user_agent y token_jti son blank=True SIN null=True en el
      // backend: aceptan cadena vacía pero no null.
      'user_agent': userAgent ?? '',
      'resultado': resultado,
      'token_jti': tokenJti ?? '',
      if (fechaHora != null) 'fecha_hora': fechaHora!.toIso8601String(),
      if (fechaCierre != null) 'fecha_cierre': fechaCierre!.toIso8601String(),
    };
  }

  SesionUsuario copyWith({
    String? id,
    int? usuario,
    String? ipAddress,
    String? userAgent,
    String? resultado,
    String? tokenJti,
    DateTime? fechaHora,
    DateTime? fechaCierre,
  }) {
    return SesionUsuario(
      id: id ?? this.id,
      usuario: usuario ?? this.usuario,
      ipAddress: ipAddress ?? this.ipAddress,
      userAgent: userAgent ?? this.userAgent,
      resultado: resultado ?? this.resultado,
      tokenJti: tokenJti ?? this.tokenJti,
      fechaHora: fechaHora ?? this.fechaHora,
      fechaCierre: fechaCierre ?? this.fechaCierre,
    );
  }
}
