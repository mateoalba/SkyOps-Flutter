import '../../../domain/model/auth_models.dart';
import '../../../domain/model/user.dart';

/// DTOs de autenticación: mapean el JSON del backend Django a los modelos de dominio.

class LoginRequestDto {
  final String email;
  final String password;

  LoginRequestDto(LoginRequest req) : email = req.email, password = req.password;

  Map<String, dynamic> toJson() => {'email': email, 'password': password};
}

class RegistroRequestDto {
  final RegistroRequest req;
  RegistroRequestDto(this.req);

  Map<String, dynamic> toJson() => {
        'email': req.email,
        'password': req.password,
        'password2': req.password2,
        if (req.firstName != null) 'first_name': req.firstName,
        if (req.lastName != null) 'last_name': req.lastName,
        if (req.pais != null) 'pais': req.pais,
        if (req.tipoDocumento != null) 'tipo_documento': req.tipoDocumento,
        if (req.numeroDocumento != null) 'numero_documento': req.numeroDocumento,
        if (req.fechaNacimiento != null)
          'fecha_nacimiento':
              '${req.fechaNacimiento!.year.toString().padLeft(4, '0')}-${req.fechaNacimiento!.month.toString().padLeft(2, '0')}-${req.fechaNacimiento!.day.toString().padLeft(2, '0')}',
        if (req.genero != null) 'genero': req.genero,
        if (req.telefono != null) 'telefono': req.telefono,
      };
}

class TokenDto {
  final String access;
  final String refresh;

  TokenDto({required this.access, required this.refresh});

  factory TokenDto.fromJson(Map<String, dynamic> json) => TokenDto(
        access: json['access'] as String,
        refresh: json['refresh'] as String? ?? '',
      );
}

class UsuarioDto {
  final int? id;
  final String username;
  final String email;
  final String? firstName;
  final String? lastName;
  final bool isStaff;
  final String? foto;
  final String? pais;
  final String? tipoDocumento;
  final String? numeroDocumento;
  final DateTime? fechaNacimiento;
  final String? genero;
  final String? telefono;
  final String? cargo;
  final bool esOperador;

  UsuarioDto({
    this.id,
    required this.username,
    required this.email,
    this.firstName,
    this.lastName,
    this.isStaff = false,
    this.foto,
    this.pais,
    this.tipoDocumento,
    this.numeroDocumento,
    this.fechaNacimiento,
    this.genero,
    this.telefono,
    this.cargo,
    this.esOperador = false,
  });

  // El backend usa 'is_staff' en /auth/perfil/ y 'es_staff' en la respuesta
  // anidada del login; se aceptan ambas claves por robustez.
  factory UsuarioDto.fromJson(Map<String, dynamic> json) => UsuarioDto(
        id: (json['id'] as num?)?.toInt(),
        username: json['username'] as String? ?? '',
        email: json['email'] as String? ?? '',
        firstName: json['first_name'] as String?,
        lastName: json['last_name'] as String?,
        isStaff: (json['is_staff'] as bool?) ?? (json['es_staff'] as bool?) ?? false,
        foto: json['foto'] as String?,
        pais: json['pais'] as String?,
        tipoDocumento: json['tipo_documento'] as String?,
        numeroDocumento: json['numero_documento'] as String?,
        fechaNacimiento: json['fecha_nacimiento'] != null ? DateTime.tryParse(json['fecha_nacimiento'] as String) : null,
        genero: json['genero'] as String?,
        telefono: json['telefono'] as String?,
        cargo: json['cargo'] as String?,
        esOperador: (json['es_operador'] as bool?) ?? false,
      );

  Usuario toEntity() => Usuario(
        id: id,
        username: username,
        email: email,
        firstName: firstName,
        lastName: lastName,
        isStaff: isStaff,
        foto: foto,
        pais: pais,
        tipoDocumento: tipoDocumento,
        numeroDocumento: numeroDocumento,
        fechaNacimiento: fechaNacimiento,
        genero: genero,
        telefono: telefono,
        cargo: cargo,
        esOperador: esOperador,
      );
}
