import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

/// Mapa de asientos simple (6 por fila, A-F con pasillo entre C y D).
/// Verde = disponible, gris = ocupado (no seleccionable), azul = elegido.
class SeatMap extends StatelessWidget {
  final int capacidad;
  final Set<String> asientosOcupados;
  final String? asientoSeleccionado;
  final ValueChanged<String> onSeleccionar;
  final bool cargando;

  const SeatMap({
    super.key,
    required this.capacidad,
    required this.asientosOcupados,
    required this.asientoSeleccionado,
    required this.onSeleccionar,
    this.cargando = false,
  });

  static const _letras = ['A', 'B', 'C', 'D', 'E', 'F'];

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
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _leyenda(AppColors.surfaceVariant, 'Disponible'),
              const SizedBox(width: 16),
              _leyenda(AppColors.textSecondary, 'Ocupado'),
              const SizedBox(width: 16),
              _leyenda(AppColors.primary, 'Elegido'),
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
                              _asiento(codigo),
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

  Widget _asiento(String codigo) {
    final ocupado = asientosOcupados.contains(codigo);
    final seleccionado = asientoSeleccionado == codigo;

    Color color;
    Color colorTexto;
    if (seleccionado) {
      color = AppColors.primary;
      colorTexto = Colors.white;
    } else if (ocupado) {
      color = AppColors.textSecondary.withValues(alpha: 0.3);
      colorTexto = AppColors.textSecondary;
    } else {
      color = AppColors.surfaceVariant;
      colorTexto = AppColors.textPrimary;
    }

    return SizedBox(
      width: 30,
      height: 30,
      child: Material(
        color: color,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: ocupado ? null : () => onSeleccionar(codigo),
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
