/// Modelo de dominio: Puerta
/// Generado a partir del esquema real del backend (introspección de Django).
class Puerta {
  final String? id;
  final String aeropuerto;
  final String codigo;
  final String terminal;
  final String estado;

  const Puerta({
    this.id,
    required this.aeropuerto,
    required this.codigo,
    required this.terminal,
    required this.estado,
  });

  factory Puerta.fromJson(Map<String, dynamic> json) {
    return Puerta(
      id: json['id'] as String?,
      aeropuerto: json['aeropuerto'] as String? ?? '',
      codigo: json['codigo'] as String? ?? '',
      terminal: json['terminal'] as String? ?? '',
      estado: json['estado'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'aeropuerto': aeropuerto,
      'codigo': codigo,
      'terminal': terminal,
      'estado': estado,
    };
  }

  Puerta copyWith({
    String? id,
    String? aeropuerto,
    String? codigo,
    String? terminal,
    String? estado,
  }) {
    return Puerta(
      id: id ?? this.id,
      aeropuerto: aeropuerto ?? this.aeropuerto,
      codigo: codigo ?? this.codigo,
      terminal: terminal ?? this.terminal,
      estado: estado ?? this.estado,
    );
  }
}
