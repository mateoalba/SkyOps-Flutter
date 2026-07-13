/// Modelo de dominio: Aeronave
/// Generado a partir del esquema real del backend (introspección de Django).
class Aeronave {
  final String? id;
  final String aerolinea;
  final String matricula;
  final String modelo;
  final String fabricante;
  final int capacidad;
  final String estado;

  const Aeronave({
    this.id,
    required this.aerolinea,
    required this.matricula,
    required this.modelo,
    required this.fabricante,
    required this.capacidad,
    required this.estado,
  });

  factory Aeronave.fromJson(Map<String, dynamic> json) {
    return Aeronave(
      id: json['id'] as String?,
      aerolinea: json['aerolinea'] as String? ?? '',
      matricula: json['matricula'] as String? ?? '',
      modelo: json['modelo'] as String? ?? '',
      fabricante: json['fabricante'] as String? ?? '',
      capacidad: (json['capacidad'] as num?)?.toInt() ?? 0,
      estado: json['estado'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'aerolinea': aerolinea,
      'matricula': matricula,
      'modelo': modelo,
      'fabricante': fabricante,
      'capacidad': capacidad,
      'estado': estado,
    };
  }

  Aeronave copyWith({
    String? id,
    String? aerolinea,
    String? matricula,
    String? modelo,
    String? fabricante,
    int? capacidad,
    String? estado,
  }) {
    return Aeronave(
      id: id ?? this.id,
      aerolinea: aerolinea ?? this.aerolinea,
      matricula: matricula ?? this.matricula,
      modelo: modelo ?? this.modelo,
      fabricante: fabricante ?? this.fabricante,
      capacidad: capacidad ?? this.capacidad,
      estado: estado ?? this.estado,
    );
  }
}
