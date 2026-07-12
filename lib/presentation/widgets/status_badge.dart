import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

/// Chip de color usado para mostrar el estado de vuelos, incidentes,
/// mantenimientos, reservas, etc.
class StatusBadge extends StatelessWidget {
  final String? estado;

  const StatusBadge({super.key, this.estado});

  @override
  Widget build(BuildContext context) {
    if (estado == null || estado!.trim().isEmpty) {
      return const SizedBox.shrink();
    }
    final color = AppColors.colorEstado(estado);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        estado!,
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}
