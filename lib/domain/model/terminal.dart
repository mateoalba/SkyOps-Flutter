/// Modelo de dominio: Terminal
/// Generado a partir del esquema real del backend (introspección de Django).
class Terminal {
  final String? id;
  final String aeropuerto;
  final String nombre;
  final String codigo;
  final int capacidadPuertas;
  final String estado;
  final DateTime? creadoEn;

  const Terminal({
    this.id,
    required this.aeropuerto,
    required this.nombre,
    required this.codigo,
    required this.capacidadPuertas,
    required this.estado,
    this.creadoEn,
  });

  factory Terminal.fromJson(Map<String, dynamic> json) {
    return Terminal(
      id: json['id'] as String?,
      aeropuerto: json['aeropuerto'] as String? ?? '',
      nombre: json['nombre'] as String? ?? '',
      codigo: json['codigo'] as String? ?? '',
      capacidadPuertas: (json['capacidad_puertas'] as num?)?.toInt() ?? 0,
      estado: json['estado'] as String? ?? '',
      creadoEn: json['creado_en'] != null ? DateTime.parse(json['creado_en'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'aeropuerto': aeropuerto,
      'nombre': nombre,
      'codigo': codigo,
      'capacidad_puertas': capacidadPuertas,
      'estado': estado,
      if (creadoEn != null) 'creado_en': creadoEn!.toIso8601String(),
    };
  }

  Terminal copyWith({
    String? id,
    String? aeropuerto,
    String? nombre,
    String? codigo,
    int? capacidadPuertas,
    String? estado,
    DateTime? creadoEn,
  }) {
    return Terminal(
      id: id ?? this.id,
      aeropuerto: aeropuerto ?? this.aeropuerto,
      nombre: nombre ?? this.nombre,
      codigo: codigo ?? this.codigo,
      capacidadPuertas: capacidadPuertas ?? this.capacidadPuertas,
      estado: estado ?? this.estado,
      creadoEn: creadoEn ?? this.creadoEn,
    );
  }
}
