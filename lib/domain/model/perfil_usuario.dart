/// Modelo de dominio: PerfilUsuario
/// Generado a partir del esquema real del backend (introspección de Django).
class PerfilUsuario {
  final String? id;
  final int usuario;
  final String? aeropuertoAsignado;
  final String? pais;
  final String? tipoDocumento;
  final String? numeroDocumento;
  final DateTime? fechaNacimiento;
  final String? genero;
  final String? telefono;
  final String cargo;
  final String? fotoUrl;
  final bool activo;
  final DateTime? creadoEn;
  final DateTime? actualizadoEn;

  // Campos de solo lectura que el backend agrega para no tener que cruzar
  // con el provider de Usuario/Aeropuerto solo para pintar la lista.
  final String? username;
  final String? email;
  final String? nombreCompleto;
  final String? aeropuertoCodigo;
  final String? tipoDocumentoDisplay;
  final String? generoDisplay;
  final String? cargoDisplay;

  const PerfilUsuario({
    this.id,
    required this.usuario,
    this.aeropuertoAsignado,
    this.pais,
    this.tipoDocumento,
    this.numeroDocumento,
    this.fechaNacimiento,
    this.genero,
    this.telefono,
    required this.cargo,
    this.fotoUrl,
    required this.activo,
    this.creadoEn,
    this.actualizadoEn,
    this.username,
    this.email,
    this.nombreCompleto,
    this.aeropuertoCodigo,
    this.tipoDocumentoDisplay,
    this.generoDisplay,
    this.cargoDisplay,
  });

  factory PerfilUsuario.fromJson(Map<String, dynamic> json) {
    return PerfilUsuario(
      id: json['id'] as String?,
      usuario: (json['usuario'] as num?)?.toInt() ?? 0,
      aeropuertoAsignado: json['aeropuerto_asignado'] as String?,
      pais: json['pais'] as String? ?? '',
      tipoDocumento: json['tipo_documento'] as String? ?? '',
      numeroDocumento: json['numero_documento'] as String?,
      fechaNacimiento: json['fecha_nacimiento'] != null ? DateTime.parse(json['fecha_nacimiento'] as String) : null,
      genero: json['genero'] as String? ?? '',
      telefono: json['telefono'] as String? ?? '',
      cargo: json['cargo'] as String? ?? '',
      fotoUrl: json['foto_url'] as String? ?? '',
      activo: json['activo'] as bool? ?? false,
      creadoEn: json['creado_en'] != null ? DateTime.parse(json['creado_en'] as String) : null,
      actualizadoEn: json['actualizado_en'] != null ? DateTime.parse(json['actualizado_en'] as String) : null,
      username: json['username'] as String?,
      email: json['email'] as String?,
      nombreCompleto: json['nombre_completo'] as String?,
      aeropuertoCodigo: json['aeropuerto_codigo'] as String?,
      tipoDocumentoDisplay: json['tipo_documento_display'] as String?,
      generoDisplay: json['genero_display'] as String?,
      cargoDisplay: json['cargo_display'] as String?,
    );
  }

  // El backend define fecha_nacimiento como DateField (solo fecha, sin
  // hora): espera "YYYY-MM-DD", no un datetime ISO completo.
  static String _soloFecha(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Map<String, dynamic> toJson() {
    return {
      'usuario': usuario,
      'aeropuerto_asignado': aeropuertoAsignado,
      // pais, genero y telefono son blank=True SIN null=True en el
      // backend: aceptan cadena vacía pero no null.
      'pais': pais ?? '',
      'tipo_documento': tipoDocumento,
      'numero_documento': numeroDocumento,
      if (fechaNacimiento != null) 'fecha_nacimiento': _soloFecha(fechaNacimiento!),
      'genero': genero ?? '',
      'telefono': telefono ?? '',
      'cargo': cargo,
      'foto_url': fotoUrl,
      'activo': activo,
      if (creadoEn != null) 'creado_en': creadoEn!.toIso8601String(),
      if (actualizadoEn != null) 'actualizado_en': actualizadoEn!.toIso8601String(),
    };
  }

  PerfilUsuario copyWith({
    String? id,
    int? usuario,
    String? aeropuertoAsignado,
    String? pais,
    String? tipoDocumento,
    String? numeroDocumento,
    DateTime? fechaNacimiento,
    String? genero,
    String? telefono,
    String? cargo,
    String? fotoUrl,
    bool? activo,
    DateTime? creadoEn,
    DateTime? actualizadoEn,
  }) {
    return PerfilUsuario(
      id: id ?? this.id,
      usuario: usuario ?? this.usuario,
      aeropuertoAsignado: aeropuertoAsignado ?? this.aeropuertoAsignado,
      pais: pais ?? this.pais,
      tipoDocumento: tipoDocumento ?? this.tipoDocumento,
      numeroDocumento: numeroDocumento ?? this.numeroDocumento,
      fechaNacimiento: fechaNacimiento ?? this.fechaNacimiento,
      genero: genero ?? this.genero,
      telefono: telefono ?? this.telefono,
      cargo: cargo ?? this.cargo,
      fotoUrl: fotoUrl ?? this.fotoUrl,
      activo: activo ?? this.activo,
      creadoEn: creadoEn ?? this.creadoEn,
      actualizadoEn: actualizadoEn ?? this.actualizadoEn,
    );
  }
}
