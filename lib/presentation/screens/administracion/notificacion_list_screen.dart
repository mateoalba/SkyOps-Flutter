import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../domain/model/notificacion.dart';
import '../../../theme/app_colors.dart';
import '../../providers/notificacion_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/confirm_delete_dialog.dart';
import '../../widgets/loading_overlay.dart';
import '../../widgets/search_field.dart';

/// Íconos/colores por tipo (ver TIPO_CHOICES en airport/models/notificacion.py).
const Map<String, IconData> _iconoTipo = {
  'retraso': Icons.schedule,
  'cancelacion': Icons.cancel_outlined,
  'cambio_puerta': Icons.door_front_door_outlined,
  'embarque': Icons.flight_takeoff,
  'confirmacion': Icons.check_circle_outline,
  'recordatorio': Icons.notifications_active_outlined,
  'equipaje': Icons.luggage_outlined,
  'otro': Icons.info_outline,
};

const Map<String, Color> _colorTipo = {
  'retraso': AppColors.warning,
  'cancelacion': AppColors.error,
  'cambio_puerta': AppColors.secondary,
  'embarque': AppColors.primary,
  'confirmacion': AppColors.success,
  'recordatorio': AppColors.gold,
  'equipaje': AppColors.secondary,
  'otro': AppColors.textSecondary,
};

const Map<String, String> _etiquetaTipo = {
  'retraso': 'Retraso',
  'cancelacion': 'Cancelación',
  'cambio_puerta': 'Cambio de puerta',
  'embarque': 'Embarque',
  'confirmacion': 'Confirmación',
  'recordatorio': 'Recordatorio',
  'equipaje': 'Equipaje',
  'otro': 'Otro',
};

const _meses = [
  '', 'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
  'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre',
];

class NotificacionListScreen extends StatefulWidget {
  const NotificacionListScreen({super.key});

  @override
  State<NotificacionListScreen> createState() => _NotificacionListScreenState();
}

class _NotificacionListScreenState extends State<NotificacionListScreen> {
  String _busqueda = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificacionProvider>().cargar();
    });
  }

  Future<void> _eliminar(BuildContext context, int id, String nombre) async {
    final confirmado = await confirmarEliminacion(context, nombre: nombre);
    if (!confirmado || !context.mounted) return;
    final provider = context.read<NotificacionProvider>();
    final ok = await provider.eliminar(id);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(ok ? 'Registro eliminado' : (provider.error ?? 'No se pudo eliminar'))),
    );
  }

  DateTime? _fechaRef(Notificacion n) => n.creadaEn ?? n.fechaEnvio;

  /// 'HOY' / 'AYER' / 'ANTERIORES', según qué tan vieja sea la notificación.
  String _grupoDe(DateTime? fecha) {
    if (fecha == null) return 'ANTERIORES';
    final hoy = DateTime.now();
    final d = DateTime(fecha.year, fecha.month, fecha.day);
    final h = DateTime(hoy.year, hoy.month, hoy.day);
    final dias = h.difference(d).inDays;
    if (dias <= 0) return 'HOY';
    if (dias == 1) return 'AYER';
    return 'ANTERIORES';
  }

  String _fmtHora(DateTime d) {
    final hora12 = d.hour % 12 == 0 ? 12 : d.hour % 12;
    final mm = d.minute.toString().padLeft(2, '0');
    final ampm = d.hour < 12 ? 'AM' : 'PM';
    return '$hora12:$mm $ampm';
  }

  String _fmtFechaCompleta(DateTime d) {
    return '${d.day} de ${_meses[d.month]}, ${d.year} · ${_fmtHora(d)}';
  }

  /// Detalle de la notificación en una hoja inferior: al abrirla, si
  /// todavía no está marcada como leída, avisa al backend para que el
  /// numerito rojo de la campana en Inicio baje de inmediato.
  void _mostrarDetalle(BuildContext context, Notificacion item) {
    context.read<NotificacionProvider>().marcarLeida(item.id!);
    final color = _colorTipo[item.tipo] ?? AppColors.textSecondary;
    final icono = _iconoTipo[item.tipo] ?? Icons.notifications_none;
    final etiqueta = _etiquetaTipo[item.tipo] ?? item.tipo;
    final fecha = _fechaRef(item);

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 18),
                    decoration: BoxDecoration(color: AppColors.surfaceVariant, borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(color: color.withValues(alpha: 0.15), shape: BoxShape.circle),
                      child: Icon(icono, color: color, size: 22),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                            decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(20)),
                            child: Text(
                              etiqueta.toUpperCase(),
                              style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.4),
                            ),
                          ),
                          if (fecha != null) ...[
                            const SizedBox(height: 6),
                            Text(_fmtFechaCompleta(fecha), style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Text(item.asunto, style: const TextStyle(color: AppColors.textPrimary, fontSize: 19, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Text(item.mensaje, style: const TextStyle(color: AppColors.textSecondary, fontSize: 14.5, height: 1.4)),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text('Cerrar', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Texto pequeño a la derecha del título: hora si es de hoy, "Ayer" para
  /// esa sección, o "hace X días/semanas" para las más viejas.
  String _fmtTrailing(DateTime? fecha, String grupo) {
    if (fecha == null) return '';
    if (grupo == 'HOY') return _fmtHora(fecha);
    if (grupo == 'AYER') return 'Ayer';
    final dias = DateTime.now().difference(fecha).inDays;
    if (dias < 7) return 'hace $dias días';
    final semanas = (dias / 7).floor();
    return semanas <= 1 ? 'hace 1 semana' : 'hace $semanas semanas';
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NotificacionProvider>();
    final auth = context.watch<AuthProvider>();
    final esAdmin = auth.usuario?.esAdmin ?? false;
    final puedeEscribir = esAdmin;

    final items = provider.items.where((item) {
      if (_busqueda.trim().isEmpty) return true;
      final q = _busqueda.trim().toLowerCase();
      return item.asunto.toString().toLowerCase().contains(q) ||
          item.tipo.toString().toLowerCase().contains(q);
    }).toList()
      ..sort((a, b) {
        final fa = _fechaRef(a);
        final fb = _fechaRef(b);
        if (fa == null && fb == null) return 0;
        if (fa == null) return 1;
        if (fb == null) return -1;
        return fb.compareTo(fa);
      });

    // Agrupa manteniendo el orden HOY -> AYER -> ANTERIORES.
    final grupos = <String, List<Notificacion>>{'HOY': [], 'AYER': [], 'ANTERIORES': []};
    for (final item in items) {
      grupos[_grupoDe(_fechaRef(item))]!.add(item);
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Notificaciones')),
      floatingActionButton: puedeEscribir
          ? FloatingActionButton(
              heroTag: 'notificaciones_nuevo_fab',
              onPressed: () => context.push('/notificaciones/nuevo'),
              child: const Icon(Icons.add),
            )
          : null,
      body: LoadingOverlay(
        visible: provider.cargando,
        child: RefreshIndicator(
          onRefresh: () => context.read<NotificacionProvider>().cargar(forzar: true),
          child: Column(
            children: [
              SearchField(
                hintText: 'Buscar notificación...',
                onChanged: (v) => setState(() => _busqueda = v),
              ),
              Expanded(
                child: items.isEmpty
                    ? ListView(
                        children: [
                          const SizedBox(height: 80),
                          Center(
                            child: Text(
                              provider.estado == EstadoCargaNotificacion.error
                                  ? (provider.error ?? 'No se pudo cargar. Verifica tu sesión/permisos.')
                                  : (_busqueda.isEmpty ? 'No hay registros todavía' : 'Sin resultados'),
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.white70),
                            ),
                          ),
                        ],
                      )
                    : ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          for (final grupo in ['HOY', 'AYER', 'ANTERIORES'])
                            if (grupos[grupo]!.isNotEmpty) ...[
                              Padding(
                                padding: const EdgeInsets.only(bottom: 10, top: 4),
                                child: Text(
                                  grupo,
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ),
                              ...grupos[grupo]!.map(
                                (item) => Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: _TarjetaNotificacion(
                                    item: item,
                                    trailing: _fmtTrailing(_fechaRef(item), grupo),
                                    onEliminar: esAdmin && item.id != null
                                        ? () => _eliminar(context, item.id!, item.asunto)
                                        : null,
                                    onTap: item.id == null
                                        ? null
                                        : puedeEscribir
                                            ? () => context.push('/notificaciones/${item.id}/editar')
                                            : () => _mostrarDetalle(context, item),
                                  ),
                                ),
                              ),
                            ],
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TarjetaNotificacion extends StatelessWidget {
  final Notificacion item;
  final String trailing;
  final VoidCallback? onEliminar;
  final VoidCallback? onTap;

  const _TarjetaNotificacion({
    required this.item,
    required this.trailing,
    required this.onEliminar,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = _colorTipo[item.tipo] ?? AppColors.textSecondary;
    final icono = _iconoTipo[item.tipo] ?? Icons.notifications_none;
    final etiqueta = _etiquetaTipo[item.tipo] ?? item.tipo;

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(width: 4, color: color),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(color: color.withValues(alpha: 0.15), shape: BoxShape.circle),
                        child: Icon(icono, color: color, size: 18),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (item.estado != 'leida') ...[
                                  Container(
                                    margin: const EdgeInsets.only(top: 5, right: 6),
                                    width: 7,
                                    height: 7,
                                    decoration: const BoxDecoration(color: AppColors.error, shape: BoxShape.circle),
                                  ),
                                ],
                                Expanded(
                                  child: Text(
                                    item.asunto,
                                    style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 14),
                                  ),
                                ),
                                if (trailing.isNotEmpty) ...[
                                  const SizedBox(width: 8),
                                  Text(trailing, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                                ],
                                if (onEliminar != null) ...[
                                  const SizedBox(width: 4),
                                  InkWell(
                                    onTap: onEliminar,
                                    borderRadius: BorderRadius.circular(20),
                                    child: const Padding(
                                      padding: EdgeInsets.all(4),
                                      child: Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item.mensaje,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: AppColors.textSecondary, fontSize: 12.5),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                etiqueta.toUpperCase(),
                                style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.4),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}