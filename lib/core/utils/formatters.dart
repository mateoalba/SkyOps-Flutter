import 'package:intl/intl.dart';

/// Formateadores de fecha/hora usados en toda la app.
class Formatters {
  Formatters._();

  static final DateFormat _fechaHora = DateFormat('dd/MM/yyyy HH:mm');
  static final DateFormat _fecha = DateFormat('dd/MM/yyyy');

  static String fechaHora(DateTime? valor) {
    if (valor == null) return '-';
    return _fechaHora.format(valor.toLocal());
  }

  static String fecha(DateTime? valor) {
    if (valor == null) return '-';
    return _fecha.format(valor.toLocal());
  }

  static const List<String> _mesesCortos = [
    'ene', 'feb', 'mar', 'abr', 'may', 'jun',
    'jul', 'ago', 'sep', 'oct', 'nov', 'dic',
  ];

  /// Formato largo en español sin depender de inicializar locales de intl,
  /// ej. "27 may 2026". Usado en encabezados/saludos.
  static String fechaLarga(DateTime? valor) {
    if (valor == null) return '-';
    final v = valor.toLocal();
    return '${v.day} ${_mesesCortos[v.month - 1]} ${v.year}';
  }

  static String hora(DateTime? valor) {
    if (valor == null) return '-';
    final v = valor.toLocal();
    final h = v.hour.toString().padLeft(2, '0');
    final m = v.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  /// Formato de dinero simple con separador de miles, ej. 349000 -> "$349.000".
  /// No usa NumberFormat de intl para no depender de inicializar el locale.
  static String precio(num? valor) {
    if (valor == null) return '\$0';
    final entero = valor.round();
    final texto = entero.toString();
    final buffer = StringBuffer();
    for (var i = 0; i < texto.length; i++) {
      final posicionDesdeElFinal = texto.length - i;
      if (i > 0 && posicionDesdeElFinal % 3 == 0) buffer.write('.');
      buffer.write(texto[i]);
    }
    return '\$$buffer';
  }
}
