import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

/// Tarjeta de lista reutilizable para las 25 entidades del sistema,
/// inspirada en el estilo "Aerolíneas" (avatar circular con iniciales,
/// título/subtítulo, switch de estado opcional y hasta 2 estadísticas
/// secundarias). Mantiene el mismo lenguaje visual en toda la app.
class EntityListCard extends StatelessWidget {
  /// Texto principal (ej. nombre de la aerolínea, matrícula, etc.)
  final String titulo;

  /// Texto secundario, debajo del título.
  final String? subtitulo;

  /// Iniciales mostradas en el avatar circular (se recortan a 2 letras).
  final String iniciales;

  /// Color base del avatar. Si es null se usa AppColors.primary.
  final Color? colorAvatar;

  /// Si no es null, se muestra un switch de estado (activo/inactivo).
  final bool? activo;
  final ValueChanged<bool>? onCambiarActivo;

  /// Hasta dos pares (etiqueta, valor) mostrados como estadísticas,
  /// igual que "AERONAVES 315" / "VUELOS DIARIOS 1,200".
  final List<MapEntry<String, String>>? estadisticas;

  /// Si se debe mostrar el botón de eliminar (normalmente solo para admin).
  final VoidCallback? onEliminar;

  final VoidCallback? onTap;

  const EntityListCard({
    super.key,
    required this.titulo,
    this.subtitulo,
    required this.iniciales,
    this.colorAvatar,
    this.activo,
    this.onCambiarActivo,
    this.estadisticas,
    this.onEliminar,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final avatarColor = colorAvatar ?? AppColors.primary;
    final iniclalesCortas = iniciales.trim().isEmpty
        ? '?'
        : iniciales.trim().substring(0, iniciales.trim().length >= 2 ? 2 : 1).toUpperCase();

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.surfaceVariant),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: avatarColor.withValues(alpha: 0.18),
                    child: Text(
                      iniclalesCortas,
                      style: TextStyle(
                        color: avatarColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          titulo,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        if (subtitulo != null && subtitulo!.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            subtitulo!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (activo != null)
                    Switch(
                      value: activo!,
                      onChanged: onCambiarActivo,
                    ),
                  if (onEliminar != null)
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: AppColors.error, size: 20),
                      tooltip: 'Eliminar',
                      onPressed: onEliminar,
                    ),
                ],
              ),
              if (estadisticas != null && estadisticas!.isNotEmpty) ...[
                const SizedBox(height: 14),
                Container(height: 1, color: AppColors.surfaceVariant),
                const SizedBox(height: 12),
                Row(
                  children: estadisticas!
                      .map(
                        (e) => Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                e.key.toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 10,
                                  letterSpacing: 0.4,
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                e.value,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
