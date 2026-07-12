import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

/// Tarjeta de vuelo compartida en toda la app (lista de Vuelos, resultados
/// de "Buscar vuelo" y la vista previa de "Próximos vuelos" del Dashboard):
/// icono + número/aerolínea, badge de estado, franja grande de horarios con
/// la duración al centro, y un slot de footer opcional para acciones como
/// "Reservar".
class VueloCard extends StatelessWidget {
  final String numeroVuelo;
  final String aerolineaNombre;
  final String estado;
  final String origenCodigo;
  final String destinoCodigo;
  final String? origenCiudad;
  final String? destinoCiudad;
  final String horaSalida;
  final String horaLlegada;
  final String? horaSalidaReal;
  final String? horaLlegadaReal;
  final int? duracionMin;
  final String? puertaCodigo;
  final String? aeronaveMatricula;
  final VoidCallback? onTap;
  final Widget? trailing;
  final Widget? footer;

  const VueloCard({
    super.key,
    required this.numeroVuelo,
    required this.aerolineaNombre,
    required this.estado,
    required this.origenCodigo,
    required this.destinoCodigo,
    required this.horaSalida,
    required this.horaLlegada,
    this.origenCiudad,
    this.destinoCiudad,
    this.horaSalidaReal,
    this.horaLlegadaReal,
    this.duracionMin,
    this.puertaCodigo,
    this.aeronaveMatricula,
    this.onTap,
    this.trailing,
    this.footer,
  });

  String _estadoLegible(String e) {
    if (e.isEmpty) return e;
    return e[0].toUpperCase() + e.substring(1);
  }

  String? _duracionTexto() {
    if (duracionMin == null || duracionMin! <= 0) return null;
    final h = duracionMin! ~/ 60;
    final m = duracionMin! % 60;
    if (h <= 0) return '${m}m';
    if (m <= 0) return '${h}h';
    return '${h}h${m.toString().padLeft(2, '0')}m';
  }

  @override
  Widget build(BuildContext context) {
    final colorEstado = AppColors.colorEstado(estado);
    final duracionTexto = _duracionTexto();

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.surfaceVariant),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.15), shape: BoxShape.circle),
                    child: const Icon(Icons.flight, color: AppColors.primary, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          numeroVuelo,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                        ),
                        if (aerolineaNombre.isNotEmpty)
                          Text(
                            aerolineaNombre,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: colorEstado.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: colorEstado.withValues(alpha: 0.4)),
                    ),
                    child: Text(
                      _estadoLegible(estado).toUpperCase(),
                      style: TextStyle(color: colorEstado, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.3),
                    ),
                  ),
                  if (trailing != null) trailing!,
                ],
              ),
              const SizedBox(height: 18),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 4,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (horaSalidaReal != null && horaSalidaReal != horaSalida) ...[
                          Text(
                            horaSalida,
                            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, decoration: TextDecoration.lineThrough),
                          ),
                          Text(horaSalidaReal!, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: colorEstado)),
                        ] else
                          Text(horaSalida, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                        const SizedBox(height: 2),
                        Text(
                          origenCiudad != null && origenCiudad!.isNotEmpty ? '$origenCodigo · $origenCiudad' : origenCodigo,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                        ),
                        if (puertaCodigo != null && puertaCodigo!.isNotEmpty)
                          Text('Puerta $puertaCodigo', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Column(
                        children: [
                          if (duracionTexto != null)
                            Text(duracionTexto, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Expanded(child: Container(height: 1, color: AppColors.textSecondary.withValues(alpha: 0.35))),
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 6),
                                child: Icon(Icons.flight, size: 14, color: AppColors.textSecondary),
                              ),
                              Expanded(child: Container(height: 1, color: AppColors.textSecondary.withValues(alpha: 0.35))),
                            ],
                          ),
                          const SizedBox(height: 4),
                          const Text('DIRECTO', style: TextStyle(fontSize: 9, letterSpacing: 0.5, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 4,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (horaLlegadaReal != null && horaLlegadaReal != horaLlegada) ...[
                          Text(
                            horaLlegada,
                            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, decoration: TextDecoration.lineThrough),
                          ),
                          Text(horaLlegadaReal!, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: colorEstado)),
                        ] else
                          Text(horaLlegada, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                        const SizedBox(height: 2),
                        Text(
                          destinoCiudad != null && destinoCiudad!.isNotEmpty ? '$destinoCodigo · $destinoCiudad' : destinoCodigo,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.right,
                          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (aeronaveMatricula != null && aeronaveMatricula!.isNotEmpty) ...[
                const SizedBox(height: 14),
                Container(height: 1, color: AppColors.surfaceVariant),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.airplanemode_active, size: 14, color: AppColors.textSecondary),
                    const SizedBox(width: 6),
                    Text(aeronaveMatricula!, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    const Spacer(),
                    const Text('Detalles ›', style: TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
              if (footer != null) ...[
                const SizedBox(height: 14),
                Container(height: 1, color: AppColors.surfaceVariant),
                const SizedBox(height: 12),
                footer!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}
