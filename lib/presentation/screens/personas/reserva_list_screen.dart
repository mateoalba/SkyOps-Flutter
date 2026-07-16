import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../domain/model/vuelo.dart';
import '../../providers/reserva_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/aeropuerto_provider.dart';
import '../../providers/vuelo_provider.dart';
import '../../widgets/confirm_delete_dialog.dart';
import '../../widgets/loading_overlay.dart';
import '../../widgets/reserva_card.dart';
import '../../widgets/search_field.dart';
import '../../../theme/app_colors.dart';

class ReservaListScreen extends StatefulWidget {
  const ReservaListScreen({super.key});

  @override
  State<ReservaListScreen> createState() => _ReservaListScreenState();
}

class _ReservaListScreenState extends State<ReservaListScreen> {
  String _busqueda = '';
  String _filtroEstado = 'todas';

  static const _meses = [
    '', 'ene', 'feb', 'mar', 'abr', 'may', 'jun', 'jul', 'ago', 'sep', 'oct', 'nov', 'dic',
  ];

  static const _filtros = [
    (valor: 'todas', etiqueta: 'Todas'),
    (valor: 'confirmada', etiqueta: 'Confirmadas'),
    (valor: 'pendiente', etiqueta: 'Pendientes'),
    (valor: 'abordada', etiqueta: 'Abordadas'),
    (valor: 'cancelada', etiqueta: 'Canceladas'),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReservaProvider>().cargar();
      context.read<AeropuertoProvider>().cargar();
      context.read<VueloProvider>().cargar();
    });
  }

  Future<void> _eliminar(BuildContext context, String id, String nombre) async {
    final confirmado = await confirmarEliminacion(context, nombre: nombre);
    if (!confirmado || !context.mounted) return;
    final provider = context.read<ReservaProvider>();
    final ok = await provider.eliminar(id);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(ok ? 'Registro eliminado' : (provider.error ?? 'No se pudo eliminar'))),
    );
  }

  String? _fmtFecha(DateTime? d) {
    if (d == null) return null;
    return '${d.day} ${_meses[d.month]}, ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ReservaProvider>();
    final auth = context.watch<AuthProvider>();
    final opcAeropuerto = context.watch<AeropuertoProvider>().items;
    final opcVuelo = context.watch<VueloProvider>().items;
    final esAdmin = auth.usuario?.esAdmin ?? false;

    String? ciudadPorCodigo(String? codigo) {
      if (codigo == null) return null;
      try {
        return opcAeropuerto.firstWhere((a) => a.codigoIata == codigo).ciudad;
      } catch (_) {
        return null;
      }
    }

    String fmtHora(DateTime d) {
      final hh = d.hour.toString().padLeft(2, '0');
      final mm = d.minute.toString().padLeft(2, '0');
      return '$hh:$mm';
    }

    final items = provider.items.where((item) {
      if (_filtroEstado != 'todas' && item.estado != _filtroEstado) return false;
      if (_busqueda.trim().isEmpty) return true;
      final q = _busqueda.trim().toLowerCase();
      final nombreCompleto = '${item.pasajeroNombre ?? ''} ${item.pasajeroApellido ?? ''}'.trim();
      return item.codigoReserva.toLowerCase().contains(q) ||
          nombreCompleto.toLowerCase().contains(q) ||
          item.numeroAsiento.toLowerCase().contains(q);
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Reservas')),
      floatingActionButton: FloatingActionButton(
        heroTag: 'reservas_nuevo_fab',
        // Un pasajero no elige vuelo desde un dropdown (ver
        // ReservaFormScreen): siempre debe pasar primero por "Buscar
        // vuelo" para llegar con uno preseleccionado. Un admin sí puede
        // crear la reserva directo, con dropdowns de vuelo y pasajero.
        onPressed: () => context.push(esAdmin ? '/reservas/nuevo' : '/vuelos/buscar'),
        child: const Icon(Icons.add),
      ),
      body: LoadingOverlay(
        visible: provider.cargando,
        child: RefreshIndicator(
          onRefresh: () => context.read<ReservaProvider>().cargar(forzar: true),
          child: Column(
            children: [
              SearchField(
                hintText: 'Buscar por pasajero o PNR...',
                onChanged: (v) => setState(() => _busqueda = v),
              ),
              SizedBox(
                height: 40,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  itemCount: _filtros.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final f = _filtros[index];
                    final seleccionado = f.valor == _filtroEstado;
                    return ChoiceChip(
                      label: Text(f.etiqueta),
                      selected: seleccionado,
                      onSelected: (_) => setState(() => _filtroEstado = f.valor),
                      backgroundColor: AppColors.surface,
                      selectedColor: AppColors.primary,
                      side: BorderSide(color: seleccionado ? AppColors.primary : AppColors.surfaceVariant),
                      labelStyle: TextStyle(
                        color: seleccionado ? Colors.white : AppColors.textSecondary,
                        fontWeight: seleccionado ? FontWeight.bold : FontWeight.normal,
                        fontSize: 12,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 4),
              Expanded(
                child: items.isEmpty
                    ? ListView(
                        children: [
                          const SizedBox(height: 80),
                          Center(
                            child: Text(
                              provider.estado == EstadoCargaReserva.error
                                  ? (provider.error ?? 'No se pudo cargar. Verifica tu sesión/permisos.')
                                  : (_busqueda.isEmpty ? 'No hay registros todavía' : 'Sin resultados'),
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.white70),
                            ),
                          ),
                        ],
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: items.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final item = items[index];
                          final nombreCompleto = ('${item.pasajeroNombre ?? ''} ${item.pasajeroApellido ?? ''}').trim();
                          Vuelo? vueloReserva;
                          try {
                            vueloReserva = opcVuelo.firstWhere((v) => v.id == item.vuelo);
                          } catch (_) {
                            vueloReserva = null;
                          }
                          return ReservaCard(
                            nombrePasajero: nombreCompleto.isEmpty ? 'Pasajero' : nombreCompleto,
                            pnr: item.codigoReserva,
                            estado: item.estado,
                            origenCodigo: item.vueloOrigen,
                            origenCiudad: ciudadPorCodigo(item.vueloOrigen),
                            destinoCodigo: item.vueloDestino,
                            destinoCiudad: ciudadPorCodigo(item.vueloDestino),
                            vueloNumero: item.vueloNumero,
                            horaSalida: vueloReserva != null ? fmtHora(vueloReserva.salidaProgramada) : null,
                            horaLlegada: vueloReserva != null ? fmtHora(vueloReserva.llegadaProgramada) : null,
                            duracionMin: vueloReserva?.duracionMin,
                            fecha: _fmtFecha(item.reservadoEn),
                            precio: item.precio,
                            totalPasajeros: item.totalPasajeros,
                            onEliminar: esAdmin && item.id != null ? () => _eliminar(context, item.id!, item.codigoReserva) : null,
                            onTap: () => context.push('/reservas/${item.id}/editar'),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
