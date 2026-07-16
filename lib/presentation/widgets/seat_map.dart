import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

/// Mapa de asientos (6 por fila, A-F con pasillo entre C y D).
///
/// Tiene dos modos:
///
/// - **Reserva** (por defecto): usado por el pasajero/admin al elegir los
///   asientos de una reserva. Permite seleccionar uno o varios asientos
///   (uno por cada pasajero que ocupa asiento — el límite lo controla
///   quien use el widget, aquí solo se pinta qué está elegido). Si el
///   vuelo tiene [asientosPrimera]/[asientosEjecutiva] configurados, se
///   pintan por clase y solo son tocables los que correspondan a la
///   [clase] elegida en el formulario — el resto se ve atenuado.
/// - **Asignación** ([modoAsignacion] = true): usado por el admin al crear
///   o editar un vuelo, para elegir qué asientos exactos pertenecen a una
///   clase (ej. Primera). Permite selección múltiple (toggle), y los
///   asientos que ya están asignados a LA OTRA clase se ven bloqueados
///   para evitar solaparse.
class SeatMap extends StatelessWidget {
  final int capacidad;
  final bool cargando;
  final Set<String> asientosPrimera;
  final Set<String> asientosEjecutiva;

  // Modo reserva.
  final Set<String> asientosOcupados;
  final Set<String> asientosSeleccionadosReserva;
  final ValueChanged<String>? onSeleccionar;
  final String clase;

  // Modo asignación.
  final bool modoAsignacion;
  final Set<String> asientosSeleccionados;
  final Set<String> asientosOtraClase;
  final ValueChanged<String>? onToggle;
  final Color colorAsignacion;

  const SeatMap({
    super.key,
    required this.capacidad,
    this.asientosOcupados = const {},
    this.asientosSeleccionadosReserva = const {},
    this.onSeleccionar,
    this.cargando = false,
    this.asientosPrimera = const {},
    this.asientosEjecutiva = const {},
    this.clase = 'economica',
    this.modoAsignacion = false,
    this.asientosSeleccionados = const {},
    this.asientosOtraClase = const {},
    this.onToggle,
    this.colorAsignacion = AppColors.primary,
  });

  static const _letras = ['A', 'B', 'C', 'D', 'E', 'F'];

  bool get _restringidoPorClase => asientosPrimera.isNotEmpty || asientosEjecutiva.isNotEmpty;

  String _claseDeAsiento(String codigo) {
    if (asientosPrimera.contains(codigo)) return 'primera';
    if (asientosEjecutiva.contains(codigo)) return 'ejecutiva';
    return 'economica';
  }

  Color _colorClase(String claseAsiento) {
    switch (claseAsiento) {
      case 'primera':
        return AppColors.warning;
      case 'ejecutiva':
        return AppColors.secondary;
      default:
        return AppColors.surfaceVariant;
    }
  }

  @override
  Widget build(BuildContext context) {
    final total = capacidad > 0 ? capacidad : 150;
    final filas = (total / _letras.length).ceil().clamp(1, 60);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.surfaceVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 14,
            runSpacing: 6,
            children: modoAsignacion
                ? [
                    _leyenda(colorAsignacion, 'Elegido'),
                    _leyenda(AppColors.surfaceVariant, 'Disponible'),
                    _leyenda(AppColors.textSecondary.withValues(alpha: 0.3), 'De otra clase'),
                  ]
                : [
                    if (_restringidoPorClase && asientosPrimera.isNotEmpty) _leyenda(AppColors.warning, 'Primera'),
                    if (_restringidoPorClase && asientosEjecutiva.isNotEmpty) _leyenda(AppColors.secondary, 'Ejecutiva'),
                    _leyenda(AppColors.surfaceVariant, 'Disponible'),
                    _leyenda(AppColors.textSecondary, 'Ocupado'),
                    _leyenda(AppColors.primary, 'Elegido'),
                    if (_restringidoPorClase) _leyenda(AppColors.textSecondary.withValues(alpha: 0.25), 'Otra clase'),
                  ],
          ),
          const SizedBox(height: 16),
          if (cargando)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: CircularProgressIndicator()),
            )
          else
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 320),
              child: SingleChildScrollView(
                child: Column(
                  children: List.generate(filas, (fila) {
                    final numeroFila = fila + 1;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 22,
                            child: Text(
                              '$numeroFila',
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                            ),
                          ),
                          const SizedBox(width: 6),
                          ..._letras.asMap().entries.expand((entry) {
                            final i = entry.key;
                            final letra = entry.value;
                            final codigo = '$numeroFila$letra';
                            final widgets = <Widget>[
                              modoAsignacion ? _asientoAsignacion(codigo) : _asientoReserva(codigo),
                            ];
                            if (i == 2) {
                              widgets.add(const SizedBox(width: 18));
                            } else {
                              widgets.add(const SizedBox(width: 6));
                            }
                            return widgets;
                          }),
                        ],
                      ),
                    );
                  }),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _leyenda(Color color, String texto) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3)),
        ),
        const SizedBox(width: 6),
        Text(texto, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
      ],
    );
  }

  Widget _asientoReserva(String codigo) {
    final claseAsiento = _claseDeAsiento(codigo);
    final ocupado = asientosOcupados.contains(codigo);
    final seleccionado = asientosSeleccionadosReserva.contains(codigo);
    final noDisponibleParaClase = _restringidoPorClase && claseAsiento != clase;
    final seleccionable = !ocupado && !noDisponibleParaClase;

    Color color;
    Color colorTexto;
    if (seleccionado) {
      color = AppColors.primary;
      colorTexto = Colors.white;
    } else if (ocupado) {
      color = AppColors.textSecondary.withValues(alpha: 0.3);
      colorTexto = AppColors.textSecondary;
    } else if (noDisponibleParaClase) {
      color = _colorClase(claseAsiento).withValues(alpha: 0.14);
      colorTexto = AppColors.textSecondary.withValues(alpha: 0.5);
    } else if (claseAsiento == 'primera') {
      color = AppColors.warning;
      colorTexto = AppColors.background;
    } else if (claseAsiento == 'ejecutiva') {
      color = AppColors.secondary;
      colorTexto = Colors.white;
    } else {
      color = AppColors.surfaceVariant;
      colorTexto = AppColors.textPrimary;
    }

    return _celda(
      codigo: codigo,
      color: color,
      colorTexto: colorTexto,
      onTap: seleccionable && onSeleccionar != null ? () => onSeleccionar!(codigo) : null,
    );
  }

  Widget _asientoAsignacion(String codigo) {
    final bloqueado = asientosOtraClase.contains(codigo);
    final seleccionado = asientosSeleccionados.contains(codigo);

    Color color;
    Color colorTexto;
    if (seleccionado) {
      color = colorAsignacion;
      colorTexto = Colors.white;
    } else if (bloqueado) {
      color = AppColors.textSecondary.withValues(alpha: 0.18);
      colorTexto = AppColors.textSecondary.withValues(alpha: 0.5);
    } else {
      color = AppColors.surfaceVariant;
      colorTexto = AppColors.textPrimary;
    }

    return _celda(
      codigo: codigo,
      color: color,
      colorTexto: colorTexto,
      onTap: !bloqueado && onToggle != null ? () => onToggle!(codigo) : null,
    );
  }

  Widget _celda({required String codigo, required Color color, required Color colorTexto, required VoidCallback? onTap}) {
    return SizedBox(
      width: 30,
      height: 30,
      child: Material(
        color: color,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: Center(
            child: Text(
              codigo.substring(codigo.length - 1),
              style: TextStyle(color: colorTexto, fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }
}
