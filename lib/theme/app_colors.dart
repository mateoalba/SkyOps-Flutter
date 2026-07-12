import 'package:flutter/material.dart';

/// Paleta de colores de SkyOps.
/// Tema oscuro (casi negro) con acento azul — identidad "torre de control".
class AppColors {
  AppColors._();

  // Fondo y superficies
  static const Color background = Color(0xFF0A0A0F);
  static const Color surface = Color(0xFF16161D);
  static const Color surfaceVariant = Color(0xFF1E1E27);

  // Marca — azul principal (botones, links, estados activos)
  static const Color primary = Color(0xFF2E5CFF);
  static const Color secondary = Color(0xFF5B82FF);

  // Alias de acento (se mantienen por compatibilidad con pantallas existentes;
  // ahora apuntan a la misma familia de azules en vez de dorado).
  static const Color gold = Color(0xFF2E5CFF);
  static const Color goldLight = Color(0xFF5B82FF);
  static const Color goldDark = Color(0xFF1A3FCC);

  // Botón oscuro sobre fondos azules (ej. splash screen)
  static const Color buttonDark = Color(0xFF0F0F14);

  // Texto
  static const Color textPrimary = Color(0xFFF5F5F7);
  static const Color textSecondary = Color(0xFF9195A6);

  // Estados
  static const Color error = Color(0xFFFF5470);
  static const Color success = Color(0xFF34D399);
  static const Color warning = Color(0xFFFBBF24);

  /// Colores usados por StatusBadge según el estado textual del backend.
  static Color colorEstado(String? estado) {
    switch (estado?.toLowerCase()) {
      case 'activo':
      case 'activa':
      case 'confirmada':
      case 'confirmado':
      case 'completado':
      case 'completada':
      case 'operativo':
      case 'operativa':
      case 'despegado':
      case 'aterrizado':
      case 'abordada':
        return success;
      case 'cancelado':
      case 'cancelada':
      case 'inactivo':
      case 'inactiva':
        return error;
      case 'pendiente':
      case 'en proceso':
      case 'programado':
      case 'programada':
      case 'embarcando':
      case 'retrasado':
        return warning;
      default:
        return textSecondary;
    }
  }
}
