/// Modelo de dominio: CategoriaPasajero
/// Generado a partir del esquema real del backend (introspección de Django).
class CategoriaPasajero {
  final int? id;
  final String nombre;
  final String tipo;
  final String? descripcion;
  final bool requiereAsistencia;
  final String? beneficios;
  final bool activa;

  const CategoriaPasajero({
    this.id,
    required this.nombre,
    required this.tipo,
    this.descripcion,
    required this.requiereAsistencia,
    this.beneficios,
    required this.activa,
  });

  factory CategoriaPasajero.fromJson(Map<String, dynamic> json) {
    return CategoriaPasajero(
      id: json['id'] as int?,
      nombre: json['nombre'] as String? ?? '',
      tipo: json['tipo'] as String? ?? '',
      descripcion: json['descripcion'] as String? ?? '',
      requiereAsistencia: json['requiere_asistencia'] as bool? ?? false,
      beneficios: json['beneficios'] as String? ?? '',
      activa: json['activa'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'tipo': tipo,
      // descripcion y beneficios son blank=True SIN null=True en el
      // backend: aceptan cadena vacía pero no null.
      'descripcion': descripcion ?? '',
      'requiere_asistencia': requiereAsistencia,
      'beneficios': beneficios ?? '',
      'activa': activa,
    };
  }

  CategoriaPasajero copyWith({
    int? id,
    String? nombre,
    String? tipo,
    String? descripcion,
    bool? requiereAsistencia,
    String? beneficios,
    bool? activa,
  }) {
    return CategoriaPasajero(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      tipo: tipo ?? this.tipo,
      descripcion: descripcion ?? this.descripcion,
      requiereAsistencia: requiereAsistencia ?? this.requiereAsistencia,
      beneficios: beneficios ?? this.beneficios,
      activa: activa ?? this.activa,
    );
  }
}
