/// Modelo de dominio: Reserva
/// Generado a partir del esquema real del backend (introspección de Django).
class Reserva {
  final String? id;
  final String vuelo;
  final String pasajero;
  final String numeroAsiento;
  final String clase;
  final String estado;
  final String codigoReserva;
  final DateTime? reservadoEn;

  // Campos de solo lectura que el backend agrega para no tener que cruzar
  // con los providers de Vuelo/Pasajero solo para pintar la lista.
  final String? vueloNumero;
  final String? vueloOrigen;
  final String? vueloDestino;
  final String? pasajeroNombre;
  final String? pasajeroApellido;
  final String? claseDisplay;
  final String? estadoDisplay;

  const Reserva({
    this.id,
    required this.vuelo,
    required this.pasajero,
    required this.numeroAsiento,
    required this.clase,
    required this.estado,
    required this.codigoReserva,
    this.reservadoEn,
    this.vueloNumero,
    this.vueloOrigen,
    this.vueloDestino,
    this.pasajeroNombre,
    this.pasajeroApellido,
    this.claseDisplay,
    this.estadoDisplay,
  });

  factory Reserva.fromJson(Map<String, dynamic> json) {
    return Reserva(
      id: json['id'] as String?,
      vuelo: json['vuelo'] as String? ?? '',
      pasajero: json['pasajero'] as String? ?? '',
      numeroAsiento: json['numero_asiento'] as String? ?? '',
      clase: json['clase'] as String? ?? '',
      estado: json['estado'] as String? ?? '',
      codigoReserva: json['codigo_reserva'] as String? ?? '',
      reservadoEn: json['reservado_en'] != null ? DateTime.parse(json['reservado_en'] as String) : null,
      vueloNumero: json['vuelo_numero'] as String?,
      vueloOrigen: json['vuelo_origen'] as String?,
      vueloDestino: json['vuelo_destino'] as String?,
      pasajeroNombre: json['pasajero_nombre'] as String?,
      pasajeroApellido: json['pasajero_apellido'] as String?,
      claseDisplay: json['clase_display'] as String?,
      estadoDisplay: json['estado_display'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'vuelo': vuelo,
      'pasajero': pasajero,
      'numero_asiento': numeroAsiento,
      'clase': clase,
      'estado': estado,
      'codigo_reserva': codigoReserva,
      if (reservadoEn != null) 'reservado_en': reservadoEn!.toIso8601String(),
    };
  }

  Reserva copyWith({
    String? id,
    String? vuelo,
    String? pasajero,
    String? numeroAsiento,
    String? clase,
    String? estado,
    String? codigoReserva,
    DateTime? reservadoEn,
  }) {
    return Reserva(
      id: id ?? this.id,
      vuelo: vuelo ?? this.vuelo,
      pasajero: pasajero ?? this.pasajero,
      numeroAsiento: numeroAsiento ?? this.numeroAsiento,
      clase: clase ?? this.clase,
      estado: estado ?? this.estado,
      codigoReserva: codigoReserva ?? this.codigoReserva,
      reservadoEn: reservadoEn ?? this.reservadoEn,
    );
  }
}
