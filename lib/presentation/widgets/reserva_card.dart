import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../core/utils/formatters.dart';

/// Tarjeta de reserva estilo "boarding pass": avatar del pasajero, PNR,
/// franja de ruta (origen → aerolínea/vuelo → destino) y fecha de reserva.
class ReservaCard extends StatelessWidget {
  final String nombrePasajero;
  final String pnr;
  final String estado;
  final String? origenCodigo;
  final String? origenCiudad;
  final String? destinoCodigo;
  final String? destinoCiudad;
  final String? vueloNumero;
  final String? horaSalida;
  final String? horaLlegada;
  final int? duracionMin;
  final String? fecha;
  final double? precio;
  final int? totalPasajeros;
  final VoidCallback? onTap;
  final VoidCallback? onEliminar;

  const ReservaCard({
    super.key,
    required this.nombrePasajero,
    required this.pnr,
    required this.estado,
    this.origenCodigo,
    this.origenCiudad,
    this.destinoCodigo,
    this.destinoCiudad,
    this.vueloNumero,
    this.horaSalida,
    this.horaLlegada,
    this.duracionMin,
    this.fecha,
    this.precio,
    this.totalPasajeros,
    this.onTap,
    this.onEliminar,
  });

  String _estadoLegible(String e) {
    if (e.isEmpty) return e;
    return e[0].toUpperCase() + e.substring(1);
  }

  String _iniciales(String nombre) {
    final partes = nombre.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (partes.isEmpty) return '?';
    if (partes.length == 1) return partes.first.substring(0, 1).toUpperCase();
    return (partes.first.substring(0, 1) + partes.last.substring(0, 1)).toUpperCase();
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
    final tieneRuta = origenCodigo != null && destinoCodigo != null;

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
                    radius: 20,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.18),
                    child: Text(
                      _iniciales(nombrePasajero),
                      style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          nombrePasajero,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textPrimary),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Text('PNR: $pnr', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                            if (totalPasajeros != null && totalPasajeros! > 1) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.secondary.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.people_alt_outlined, size: 11, color: AppColors.secondary),
                                    const SizedBox(width: 3),
                                    Text('$totalPasajeros', style: const TextStyle(fontSize: 11, color: AppColors.secondary, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
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
                  if (onEliminar != null)
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: AppColors.error, size: 20),
                      tooltip: 'Eliminar',
                      onPressed: onEliminar,
                    ),
                ],
              ),
              if (tieneRuta) ...[
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (horaSalida != null)
                              Text(horaSalida!, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                            Text(
                              origenCiudad != null ? '$origenCodigo · ${origenCiudad!}' : origenCodigo!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: horaSalida != null
                                  ? const TextStyle(fontSize: 10, color: AppColors.textSecondary, letterSpacing: 0.3)
                                  : const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            if (vueloNumero != null)
                              Text(vueloNumero!, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                Expanded(child: Container(height: 1, color: AppColors.textSecondary.withValues(alpha: 0.4))),
                                const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 6),
                                  child: Icon(Icons.flight, size: 14, color: AppColors.textSecondary),
                                ),
                                Expanded(child: Container(height: 1, color: AppColors.textSecondary.withValues(alpha: 0.4))),
                              ],
                            ),
                            if (_duracionTexto() != null) ...[
                              const SizedBox(height: 2),
                              Text(_duracionTexto()!, style: const TextStyle(fontSize: 9, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
                            ],
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            if (horaLlegada != null)
                              Text(horaLlegada!, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                            Text(
                              destinoCiudad != null ? '$destinoCodigo · ${destinoCiudad!}' : destinoCodigo!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.right,
                              style: horaLlegada != null
                                  ? const TextStyle(fontSize: 10, color: AppColors.textSecondary, letterSpacing: 0.3)
                                  : const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (fecha != null) ...[
                const SizedBox(height: 12),
                Container(height: 1, color: AppColors.surfaceVariant),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined, size: 13, color: AppColors.textSecondary),
                    const SizedBox(width: 6),
                    Text(fecha!, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    const Spacer(),
                    if (precio != null && precio! > 0) ...[
                      Text(Formatters.precio(precio), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primary)),
                      const SizedBox(width: 10),
                    ],
                    Container(
                      width: 26,
                      height: 26,
                      decoration: const BoxDecoration(color: AppColors.surfaceVariant, shape: BoxShape.circle),
                      child: const Icon(Icons.chevron_right, size: 16, color: AppColors.textPrimary),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
