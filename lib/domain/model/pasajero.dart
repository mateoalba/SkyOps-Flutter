/// Modelo de dominio: Pasajero
/// Generado a partir del esquema real del backend (introspección de Django).
class Pasajero {
  final String? id;
  final String nombre;
  final String apellido;
  final String numPasaporte;
  final String nacionalidad;
  final DateTime fechaNacimiento;
  final String email;
  final String? telefono;

  const Pasajero({
    this.id,
    required this.nombre,
    required this.apellido,
    required this.numPasaporte,
    required this.nacionalidad,
    required this.fechaNacimiento,
    required this.email,
    this.telefono,
  });

  factory Pasajero.fromJson(Map<String, dynamic> json) {
    return Pasajero(
      id: json['id'] as String?,
      nombre: json['nombre'] as String? ?? '',
      apellido: json['apellido'] as String? ?? '',
      numPasaporte: json['num_pasaporte'] as String? ?? '',
      nacionalidad: json['nacionalidad'] as String? ?? '',
      fechaNacimiento: DateTime.parse(json['fecha_nacimiento'] as String),
      email: json['email'] as String? ?? '',
      telefono: json['telefono'] as String? ?? '',
    );
  }

  // El backend define fecha_nacimiento como DateField (solo fecha, sin
  // hora): espera "YYYY-MM-DD", no un datetime ISO completo.
  static String _soloFecha(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'apellido': apellido,
      'num_pasaporte': numPasaporte,
      'nacionalidad': nacionalidad,
      'fecha_nacimiento': _soloFecha(fechaNacimiento),
      'email': email,
      // telefono es blank=True SIN null=True en el backend: acepta cadena
      // vacía pero no null.
      'telefono': telefono ?? '',
    };
  }

  Pasajero copyWith({
    String? id,
    String? nombre,
    String? apellido,
    String? numPasaporte,
    String? nacionalidad,
    DateTime? fechaNacimiento,
    String? email,
    String? telefono,
  }) {
    return Pasajero(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      apellido: apellido ?? this.apellido,
      numPasaporte: numPasaporte ?? this.numPasaporte,
      nacionalidad: nacionalidad ?? this.nacionalidad,
      fechaNacimiento: fechaNacimiento ?? this.fechaNacimiento,
      email: email ?? this.email,
      telefono: telefono ?? this.telefono,
    );
  }
}
