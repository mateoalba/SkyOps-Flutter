/// Validadores reutilizables para formularios de la app.
class Validators {
  Validators._();

  static String? requerido(String? valor, {String campo = 'Este campo'}) {
    if (valor == null || valor.trim().isEmpty) {
      return '$campo es obligatorio';
    }
    return null;
  }

  static String? email(String? valor) {
    if (valor == null || valor.trim().isEmpty) return null;
    final regex = RegExp(r'^[\w\.\-]+@[\w\-]+\.[\w\-\.]+$');
    if (!regex.hasMatch(valor.trim())) {
      return 'Correo electrónico inválido';
    }
    return null;
  }

  static String? numero(String? valor, {String campo = 'Este campo'}) {
    if (valor == null || valor.trim().isEmpty) return null;
    if (num.tryParse(valor.trim()) == null) {
      return '$campo debe ser un número válido';
    }
    return null;
  }

  static String? minLength(String? valor, int longitud, {String campo = 'Este campo'}) {
    if (valor == null || valor.length < longitud) {
      return '$campo debe tener al menos $longitud caracteres';
    }
    return null;
  }
}
