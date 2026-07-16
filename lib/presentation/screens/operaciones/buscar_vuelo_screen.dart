import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../domain/model/vuelo.dart';
import '../../providers/vuelo_provider.dart';
import '../../providers/aeropuerto_provider.dart';
import '../../providers/aerolinea_provider.dart';
import '../../widgets/loading_overlay.dart';
import '../../widgets/vuelo_card.dart';
import '../../../theme/app_colors.dart';

/// Pantalla de búsqueda de vuelos para pasajeros: en vez de un CRUD con
/// todos los campos operativos (aeronave, puerta, horarios...), el usuario
/// solo elige origen, destino y fecha, ve los vuelos que ya programó el
/// administrador, y presiona "Reservar" para ir directo al formulario de
/// Reserva con ese vuelo ya seleccionado.
///
/// El filtro se resuelve en el backend contra GET /vuelos/ usando los
/// parámetros reales de VueloFilter (origen_codigo, destino_codigo, fecha).
class BuscarVueloScreen extends StatefulWidget {
  const BuscarVueloScreen({super.key});

  @override
  State<BuscarVueloScreen> createState() => _BuscarVueloScreenState();
}

class _BuscarVueloScreenState extends State<BuscarVueloScreen> {
  String? _origenId;
  String? _destinoId;
  DateTime? _fecha;
  final _numeroVueloCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AeropuertoProvider>().cargar();
      context.read<AerolineaProvider>().cargar();
    });
  }

  @override
  void dispose() {
    _numeroVueloCtrl.dispose();
    super.dispose();
  }

  Future<void> _elegirFecha() async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: _fecha ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (fecha != null) setState(() => _fecha = fecha);
  }

  Future<void> _buscar() async {
    final aeropuertos = context.read<AeropuertoProvider>().items;
    String? codigo(String? id) {
      if (id == null) return null;
      try {
        return aeropuertos.firstWhere((a) => a.id == id).codigoIata;
      } catch (_) {
        return null;
      }
    }

    await context.read<VueloProvider>().buscarVuelos(
          origenCodigo: codigo(_origenId),
          destinoCodigo: codigo(_destinoId),
          fecha: _fecha,
          numeroVuelo: _numeroVueloCtrl.text,
        );
  }

  InputDecoration _decoracionPill(String etiqueta, IconData icono) {
    final borde = OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: AppColors.surfaceVariant),
    );
    return InputDecoration(
      labelText: etiqueta,
      labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
      prefixIcon: Icon(icono, color: AppColors.textSecondary, size: 20),
      filled: true,
      fillColor: AppColors.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 16),
      border: borde,
      enabledBorder: borde,
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final opcAeropuerto = context.watch<AeropuertoProvider>().items;
    final opcAerolinea = context.watch<AerolineaProvider>().items;
    final vueloProvider = context.watch<VueloProvider>();

    String codigoAeropuerto(String? id) {
      if (id == null) return '?';
      try {
        return opcAeropuerto.firstWhere((a) => a.id == id).codigoIata;
      } catch (_) {
        return '?';
      }
    }

    String? ciudadAeropuerto(String? id) {
      if (id == null) return null;
      try {
        return opcAeropuerto.firstWhere((a) => a.id == id).ciudad;
      } catch (_) {
        return null;
      }
    }

    String nombreAerolinea(String? id) {
      if (id == null) return '';
      try {
        return opcAerolinea.firstWhere((a) => a.id == id).nombre;
      } catch (_) {
        return '';
      }
    }

    String fmtHora(DateTime d) {
      final hh = d.hour.toString().padLeft(2, '0');
      final mm = d.minute.toString().padLeft(2, '0');
      return '$hh:$mm';
    }

    final resultados = vueloProvider.resultadosBusqueda;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Buscar vuelo')),
      body: LoadingOverlay(
        visible: vueloProvider.buscando,
        child: SingleChildScrollView(
          padding: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: AppColors.surfaceVariant),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    DropdownButtonFormField<String>(
                      value: _origenId,
                      isExpanded: true,
                      dropdownColor: AppColors.surface,
                      style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                      decoration: _decoracionPill('Origen', Icons.flight_takeoff),
                      items: opcAeropuerto.map((a) {
                        return DropdownMenuItem(value: a.id, child: Text('${a.codigoIata} - ${a.ciudad}', overflow: TextOverflow.ellipsis));
                      }).toList(),
                      onChanged: (v) => setState(() => _origenId = v),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _destinoId,
                      isExpanded: true,
                      dropdownColor: AppColors.surface,
                      style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                      decoration: _decoracionPill('Destino', Icons.flight_land),
                      items: opcAeropuerto.map((a) {
                        return DropdownMenuItem(value: a.id, child: Text('${a.codigoIata} - ${a.ciudad}', overflow: TextOverflow.ellipsis));
                      }).toList(),
                      onChanged: (v) => setState(() => _destinoId = v),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _numeroVueloCtrl,
                      textCapitalization: TextCapitalization.characters,
                      style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                      decoration: _decoracionPill('Número o código de vuelo (ej. AV205)', Icons.confirmation_number_outlined),
                    ),
                    const SizedBox(height: 12),
                    InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: _elegirFecha,
                      child: InputDecorator(
                        decoration: _decoracionPill('Fecha de salida', Icons.calendar_today_outlined),
                        child: Text(
                          _fecha == null
                              ? 'Cualquier fecha'
                              : '${_fecha!.day.toString().padLeft(2, '0')}/${_fecha!.month.toString().padLeft(2, '0')}/${_fecha!.year}',
                          style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _buscar,
                        icon: const Icon(Icons.search),
                        label: const Text('Buscar vuelos', style: TextStyle(fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (!vueloProvider.buscoAlMenosUnaVez)
                const SizedBox.shrink()
              else if (vueloProvider.errorBusqueda != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
                  child: Center(child: Text(vueloProvider.errorBusqueda!, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.error))),
                )
              else if (resultados.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 60, horizontal: 24),
                  child: Center(
                    child: Text('No hay vuelos disponibles con esos filtros.', textAlign: TextAlign.center, style: TextStyle(color: AppColors.textSecondary)),
                  ),
                )
              else ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                  child: Text(
                    '${resultados.length} ${resultados.length == 1 ? 'RESULTADO ENCONTRADO' : 'RESULTADOS ENCONTRADOS'}',
                    style: const TextStyle(fontSize: 11, letterSpacing: 0.5, color: AppColors.textSecondary, fontWeight: FontWeight.w700),
                  ),
                ),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  itemCount: resultados.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final Vuelo v = resultados[index];
                    final cancelado = v.estado.toLowerCase() == 'cancelado';
                    return VueloCard(
                      numeroVuelo: v.numeroVuelo,
                      aerolineaNombre: nombreAerolinea(v.aerolinea),
                      estado: v.estado,
                      origenCodigo: codigoAeropuerto(v.origen),
                      destinoCodigo: codigoAeropuerto(v.destino),
                      origenCiudad: ciudadAeropuerto(v.origen),
                      destinoCiudad: ciudadAeropuerto(v.destino),
                      duracionMin: v.duracionMin,
                      horaSalida: fmtHora(v.salidaProgramada),
                      horaLlegada: fmtHora(v.llegadaProgramada),
                      onTap: () => context.push('/vuelos/${v.id}'),
                      footer: Row(
                        children: [
                          Expanded(
                            child: Text(
                              cancelado ? 'Este vuelo fue cancelado y no admite reservas.' : 'Toca la tarjeta para ver el detalle.',
                              style: TextStyle(fontSize: 11, color: cancelado ? AppColors.error : AppColors.textSecondary),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: cancelado ? null : () => context.push('/reservas/nuevo', extra: v),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                            child: const Text('Reservar', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
