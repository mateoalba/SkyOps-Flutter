/// Usuario autenticado de SkyOps (coincide con /api/auth/perfil/).
///
/// El backend (Django) NO expone un campo de texto "rol": el control de acceso
/// real se basa en `is_staff` (administrador) y en el grupo "Operadores" al que
/// pertenezca el usuario (esto último no viaja en la respuesta del perfil, así
/// que del lado de Flutter solo podemos distinguir con certeza Administrador
/// vs. No-administrador — ver README, sección "Roles y reglas de negocio").
class Usuario {
  final int? id;
  final String username;
  final String email;
  final String? firstName;
  final String? lastName;
  final bool isStaff;

  // Datos de PerfilUsuario (uno-a-uno con el User de Django).
  final String? foto;
  final String? pais;
  final String? tipoDocumento;
  final String? numeroDocumento;
  final DateTime? fechaNacimiento;
  final String? genero;
  final String? telefono;
  final String? cargo;
  // Viene de es_operador en /api/auth/perfil/: refleja si el usuario está
  // en el grupo Django "Operadores" (o es admin). A diferencia de 'cargo'
  // (solo informativo), esto sí coincide exactamente con lo que exigen los
  // permission_classes del backend (EsOperador y similares).
  final bool esOperador;

  const Usuario({
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

  String get nombreCompleto {
    final nombre = [firstName, lastName].where((e) => e != null && e.isNotEmpty).join(' ');
    return nombre.isNotEmpty ? nombre : username;
  }

  /// Rol efectivo para la UI. Es la única distinción que el backend permite
  /// verificar de forma confiable desde el cliente.
  bool get esAdmin => isStaff;

  /// Admin u Operador: acceso a los módulos operativos (tripulación,
  /// incidentes, mantenimientos, certificaciones, perfiles de usuario).
  bool get puedeOperar => isStaff || esOperador;

  String get rolDisplay => isStaff ? 'Administrador' : 'Operador / Usuario';

  String get cargoDisplay {
    switch (cargo) {
      case 'administrador':
        return 'Administrador';
      case 'operador':
        return 'Operador';
      case 'supervisor':
        return 'Supervisor';
      case 'analista':
        return 'Analista';
      case 'tecnico':
        return 'Técnico';
      case 'usuario':
        return 'Usuario';
      default:
        return (cargo?.isNotEmpty ?? false) ? cargo! : rolDisplay;
    }
  }

  String get generoDisplay {
    switch (genero) {
      case 'femenino':
        return 'Femenino';
      case 'masculino':
        return 'Masculino';
      case 'prefiero_no_decirlo':
        return 'Prefiero no decirlo';
      default:
        return '';
    }
  }

  String get tipoDocumentoDisplay {
    switch (tipoDocumento) {
      case 'cedula':
        return 'Cédula';
      case 'pasaporte':
        return 'Pasaporte';
      case 'ruc':
        return 'RUC';
      case 'dni':
        return 'DNI';
      default:
        return '';
    }
  }
}
