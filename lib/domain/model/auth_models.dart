/// Datos necesarios para iniciar sesión.
/// El backend autentica por correo electrónico, no por username.
class LoginRequest {
  final String email;
  final String password;

  const LoginRequest({required this.email, required this.password});
}

/// Datos necesarios para registrar una cuenta nueva.
/// El backend (RegistroUsuarioSerializer) exige password y password2 (confirmación).
/// El username ya no lo pide el formulario: el backend lo genera internamente
/// a partir del correo. Los campos de perfil (país, documento, nacimiento,
/// género, teléfono) son opcionales para el backend, pero el formulario los pide todos.
class RegistroRequest {
  final String email;
  final String password;
  final String password2;
  final String? firstName;
  final String? lastName;
  final String? pais;
  final String? tipoDocumento;
  final String? numeroDocumento;
  final DateTime? fechaNacimiento;
  final String? genero;
  final String? telefono;

  const RegistroRequest({
    required this.email,
    required this.password,
    required this.password2,
    this.firstName,
    this.lastName,
    this.pais,
    this.tipoDocumento,
    this.numeroDocumento,
    this.fechaNacimiento,
    this.genero,
    this.telefono,
  });
}

/// Petición de cambio de contraseña.
/// El backend (CambiarPasswordSerializer) espera password_actual, password_nuevo
/// y password_nuevo2 (confirmación).
class CambiarPasswordRequest {
  final String passwordActual;
  final String passwordNueva;
  final String passwordNuevaConfirmacion;

  const CambiarPasswordRequest({
    required this.passwordActual,
    required this.passwordNueva,
    required this.passwordNuevaConfirmacion,
  });
}
