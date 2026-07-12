import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Estilos de texto reutilizables de SkyOps (Design System Módulo 1).
class AppTextStyles {
  AppTextStyles._();

  static const TextStyle titulo = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    letterSpacing: 0.2,
  );

  static const TextStyle subtitulo = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle cuerpo = TextStyle(
    fontSize: 14,
    color: AppColors.textPrimary,
  );

  static const TextStyle etiqueta = TextStyle(
    fontSize: 12,
    color: AppColors.textSecondary,
  );

  static const TextStyle acentoDorado = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.gold,
    letterSpacing: 0.4,
  );
}
