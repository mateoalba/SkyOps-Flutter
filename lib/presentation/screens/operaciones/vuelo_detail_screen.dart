import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../domain/model/vuelo.dart';
import '../../../domain/model/aeropuerto.dart';
import '../../providers/vuelo_provider.dart';
import '../../providers/aeropuerto_provider.dart';
import '../../providers/aerolinea_provider.dart';
import '../../providers/aeronave_provider.dart';
import '../../providers/puerta_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/loading_overlay.dart';
import '../../../theme/app_colors.dart';

/// Pantalla de detalle de vuelo — pantalla única para ambos roles.
///
/// Un pasajero ve solo la información relevante para viajar y el botón
/// "Reservar este vuelo" (solo lectura). Un administrador ve exactamente el
/// mismo diseño de tarjeta, pero con TODOS los campos del vuelo editables
/// directamente ahí mismo (aerolínea, aeronave, origen/destino, puerta,
/// horarios, número de vuelo, duración), más el selector rápido de estado y
/// un botón para guardar los cambios — sin pasar por un formulario aparte.
class VueloDetailScreen extends StatefulWidget {
  final String id;
  const VueloDetailScreen({super.key, required this.id});

  @override
  State<VueloDetailScreen> createState() => _VueloDetailScreenState();
}

class _VueloDetailScreenState extends State<VueloDetailScreen> {
  bool _actualizandoEstado = false;

  // --- Estado del formulario inline para administradores ---
  bool _camposListos = false;
  bool _guardando = false;
  String? _aerolinea;
  String? _aeronave;
  String? _origen;
  String? _destino;
  String? _puerta;
  final _numeroVueloCtrl = TextEditingController();
  DateTime? _salidaProgramada;
  DateTime? _llegadaProgramada;
  DateTime? _salidaReal;
  DateTime? _llegadaReal;
  final _duracionMinCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VueloProvider>().cargar();
      context.read<AeropuertoProvider>().cargar();
      context.read<AerolineaProvider>().cargar();
      context.read<AeronaveProvider>().cargar();
      context.read<PuertaProvider>().cargar();
    });
  }

  @override
  void dispose() {
    _numeroVueloCtrl.dispose();
    _duracionMinCtrl.dispose();
    super.dispose();
  }

  void _sincronizarCampos(Vuelo v) {
    if (_camposListos) return;
    _aerolinea = v.aerolinea;
    _aeronave = v.aeronave;
    _origen = v.origen;
    _destino = v.destino;
    _puerta = v.puerta;
    _numeroVueloCtrl.text = v.numeroVuelo;
    _salidaProgramada = v.salidaProgramada;
    _llegadaProgramada = v.llegadaProgramada;
    _salidaReal = v.salidaReal;
    _llegadaReal = v.llegadaReal;
    _duracionMinCtrl.text = v.duracionMin?.toString() ?? '';
    _camposListos = true;
  }

  Future<void> _cambiarEstado(Vuelo actual, String nuevoEstado) async {
    if (nuevoEstado == actual.estado || _actualizandoEstado) return;
    setState(() => _actualizandoEstado = true);
    final provider = context.read<VueloProvider>();
    final ok = await provider.actualizar(actual.id!, actual.copyWith(estado: nuevoEstado));
    if (!mounted) return;
    setState(() => _actualizandoEstado = false);
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.error ?? 'No se pudo actualizar el estado')),
      );
    }
  }

  Future<void> _seleccionarFecha(ValueChanged<DateTime> onSeleccionado, DateTime? actual) async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: actual ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (fecha == null || !mounted) return;
    final hora = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(actual ?? DateTime.now()),
    );
    if (hora == null) return;
    onSeleccionado(DateTime(fecha.year, fecha.month, fecha.day, hora.hour, hora.minute));
  }

  Future<void> _seleccionarAeropuerto(List<Aeropuerto> opciones, ValueChanged<String> onSeleccionado) async {
    final id = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(vertical: 12),
            children: opciones.map((a) {
              return ListTile(
                title: Text('${a.codigoIata} — ${a.nombre}'),
                subtitle: Text('${a.ciudad}, ${a.pais}', style: const TextStyle(color: AppColors.textSecondary)),
                onTap: () => Navigator.of(context).pop(a.id),
              );
            }).toList(),
          ),
        );
      },
    );
    if (id != null) onSeleccionado(id);
  }

  Future<void> _guardarCambios(Vuelo actual) async {
    if (_aerolinea == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Selecciona la aerolínea')));
      return;
    }
    if (_origen == null || _destino == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Selecciona origen y destino')));
      return;
    }
    if (_origen == _destino) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('El destino no puede ser igual al origen')));
      return;
    }
    if (_numeroVueloCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Escribe el número de vuelo')));
      return;
    }
    if (_salidaProgramada == null || _llegadaProgramada == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Completa las fechas de salida y llegada programadas')));
      return;
    }
    setState(() => _guardando = true);
    final item = actual.copyWith(
      aerolinea: _aerolinea,
      aeronave: _aeronave,
      origen: _origen,
      destino: _destino,
      puerta: _puerta,
      numeroVuelo: _numeroVueloCtrl.text.trim(),
      salidaProgramada: _salidaProgramada,
      llegadaProgramada: _llegadaProgramada,
      salidaReal: _salidaReal,
      llegadaReal: _llegadaReal,
      duracionMin: int.tryParse(_duracionMinCtrl.text.trim()),
    );
    final provider = context.read<VueloProvider>();
    final ok = await provider.actualizar(actual.id!, item);
    if (!mounted) return;
    setState(() => _guardando = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(ok ? 'Cambios guardados' : (provider.error ?? 'No se pudo guardar'))),
    );
  }

  String _fmtHora(DateTime d) {
    final hh = d.hour.toString().padLeft(2, '0');
    final mm = d.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }

  String _fmtFechaHora(DateTime d) {
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year} ${_fmtHora(d)}';
  }

  String _estadoLegible(String e) {
    if (e.isEmpty) return e;
    return e[0].toUpperCase() + e.substring(1);
  }

  InputDecoration _decoracionCompacta(String etiqueta, {String? ayuda}) {
    return InputDecoration(
      labelText: etiqueta,
      helperText: ayuda,
      isDense: true,
      labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.surfaceVariant)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.surfaceVariant)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vueloProvider = context.watch<VueloProvider>();
    final opcAeropuerto = context.watch<AeropuertoProvider>().items;
    final opcAerolinea = context.watch<AerolineaProvider>().items;
    final opcAeronave = context.watch<AeronaveProvider>().items;
    final opcPuerta = context.watch<PuertaProvider>().items;
    final esAdmin = context.watch<AuthProvider>().usuario?.esAdmin ?? false;

    Vuelo? v;
    try {
      v = vueloProvider.items.firstWhere((x) => x.id == widget.id);
    } catch (_) {
      v = null;
    }

    if (v == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Vuelo')),
        body: LoadingOverlay(
          visible: vueloProvider.cargando,
          child: Center(
            child: Text(
              vueloProvider.cargando ? '' : 'No se encontró el vuelo.',
              style: const TextStyle(color: Colors.white70),
            ),
          ),
        ),
      );
    }

    final v2 = v;
    if (esAdmin) _sincronizarCampos(v2);

    dynamic aeropuerto(String? id) {
      if (id == null) return null;
      try {
        return opcAeropuerto.firstWhere((a) => a.id == id);
      } catch (_) {
        return null;
      }
    }

    final origenAp = aeropuerto(esAdmin ? _origen : v.origen);
    final destinoAp = aeropuerto(esAdmin ? _destino : v.destino);

    String nombreAerolinea(String? id) {
      if (id == null) return '';
      try {
        return opcAerolinea.firstWhere((a) => a.id == id).nombre;
      } catch (_) {
        return '';
      }
    }

    String? codigoPuerta(String? id) {
      if (id == null) return null;
      try {
        return opcPuerta.firstWhere((p) => p.id == id).codigo;
      } catch (_) {
        return null;
      }
    }

    String? matriculaAeronave(String? id) {
      if (id == null) return null;
      try {
        final a = opcAeronave.firstWhere((a) => a.id == id);
        return '${a.matricula} · ${a.modelo}';
      } catch (_) {
        return null;
      }
    }

    final aeronavesFiltradas = _aerolinea == null
        ? opcAeronave
        : opcAeronave.where((a) => a.aerolinea == _aerolinea).toList();
    final puertasFiltradas = _origen == null
        ? opcPuerta
        : opcPuerta.where((p) => p.aeropuerto == _origen).toList();

    final colorEstado = AppColors.colorEstado(v.estado);

    return Scaffold(
      appBar: AppBar(title: Text(v.numeroVuelo)),
      body: LoadingOverlay(
        visible: vueloProvider.cargando || _guardando,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.surfaceVariant),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (esAdmin) ...[
                      DropdownButtonFormField<String>(
                        value: _aerolinea,
                        isExpanded: true,
                        dropdownColor: AppColors.surface,
                        decoration: _decoracionCompacta('Aerolínea'),
                        items: opcAerolinea.map((a) {
                          return DropdownMenuItem(value: a.id, child: Text(a.nombre, overflow: TextOverflow.ellipsis));
                        }).toList(),
                        onChanged: (val) => setState(() {
                          _aerolinea = val;
                          if (_aeronave != null && !opcAeronave.any((a) => a.id == _aeronave && a.aerolinea == val)) {
                            _aeronave = null;
                          }
                        }),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _numeroVueloCtrl,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        decoration: _decoracionCompacta('Número de vuelo'),
                      ),
                    ] else
                      Text(
                        nombreAerolinea(v.aerolinea),
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                      ),
                    const SizedBox(height: 16),
                    if (esAdmin)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: InkWell(
                              borderRadius: BorderRadius.circular(10),
                              onTap: () => _seleccionarAeropuerto(opcAeropuerto, (id) => setState(() {
                                _origen = id;
                                if (_puerta != null && !opcPuerta.any((p) => p.id == _puerta && p.aeropuerto == id)) {
                                  _puerta = null;
                                }
                              })),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Row(children: [
                                      Text('DESDE', style: TextStyle(fontSize: 10, letterSpacing: 0.4, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
                                      SizedBox(width: 4),
                                      Icon(Icons.edit, size: 11, color: AppColors.textSecondary),
                                    ]),
                                    const SizedBox(height: 4),
                                    Text(origenAp?.codigoIata ?? 'Elegir', style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                                    Text(
                                      origenAp != null ? '${origenAp.ciudad}, ${origenAp.pais}' : '',
                                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.only(top: 18),
                            child: Icon(Icons.arrow_forward, color: AppColors.textSecondary),
                          ),
                          Expanded(
                            child: InkWell(
                              borderRadius: BorderRadius.circular(10),
                              onTap: () => _seleccionarAeropuerto(opcAeropuerto, (id) => setState(() => _destino = id)),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    const Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                                      Icon(Icons.edit, size: 11, color: AppColors.textSecondary),
                                      SizedBox(width: 4),
                                      Text('HASTA', style: TextStyle(fontSize: 10, letterSpacing: 0.4, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
                                    ]),
                                    const SizedBox(height: 4),
                                    Text(destinoAp?.codigoIata ?? 'Elegir', style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                                    Text(
                                      destinoAp != null ? '${destinoAp.ciudad}, ${destinoAp.pais}' : '',
                                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                                      textAlign: TextAlign.right,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    else
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('DESDE', style: TextStyle(fontSize: 10, letterSpacing: 0.4, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
                                const SizedBox(height: 4),
                                Text(origenAp?.codigoIata ?? '?', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                                Text(
                                  origenAp != null ? '${origenAp.ciudad}, ${origenAp.pais}' : '',
                                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.arrow_forward, color: AppColors.textSecondary),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Text('HASTA', style: TextStyle(fontSize: 10, letterSpacing: 0.4, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
                                const SizedBox(height: 4),
                                Text(destinoAp?.codigoIata ?? '?', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                                Text(
                                  destinoAp != null ? '${destinoAp.ciudad}, ${destinoAp.pais}' : '',
                                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                                  textAlign: TextAlign.right,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: colorEstado.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: colorEstado.withValues(alpha: 0.4)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(width: 8, height: 8, decoration: BoxDecoration(color: colorEstado, shape: BoxShape.circle)),
                            const SizedBox(width: 6),
                            Text(_estadoLegible(v.estado), style: TextStyle(color: colorEstado, fontWeight: FontWeight.bold, fontSize: 12)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (esAdmin) ...[
                      DropdownButtonFormField<String>(
                        value: _aeronave,
                        isExpanded: true,
                        dropdownColor: AppColors.surface,
                        decoration: _decoracionCompacta('Aeronave', ayuda: _aerolinea == null ? 'Elige primero la aerolínea' : null),
                        items: aeronavesFiltradas.map((a) {
                          return DropdownMenuItem(value: a.id, child: Text('${a.matricula} · ${a.modelo}', overflow: TextOverflow.ellipsis));
                        }).toList(),
                        onChanged: _aerolinea == null ? null : (val) => setState(() => _aeronave = val),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: _puerta,
                        isExpanded: true,
                        dropdownColor: AppColors.surface,
                        decoration: _decoracionCompacta('Puerta', ayuda: _origen == null ? 'Elige primero el origen' : null),
                        items: puertasFiltradas.map((p) {
                          return DropdownMenuItem(value: p.id, child: Text('Puerta ${p.codigo}', overflow: TextOverflow.ellipsis));
                        }).toList(),
                        onChanged: _origen == null ? null : (val) => setState(() => _puerta = val),
                      ),
                    ] else if (matriculaAeronave(v.aeronave) != null) ...[
                      Row(
                        children: [
                          const Text('AERONAVE', style: TextStyle(fontSize: 10, letterSpacing: 0.4, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
                          const SizedBox(width: 8),
                          Text(matriculaAeronave(v.aeronave)!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        ],
                      ),
                    ],
                    const SizedBox(height: 16),
                    Container(height: 1, color: AppColors.surfaceVariant),
                    const SizedBox(height: 16),
                    if (esAdmin) ...[
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () => _seleccionarFecha((d) => setState(() => _salidaProgramada = d), _salidaProgramada),
                              child: InputDecorator(
                                decoration: _decoracionCompacta('Salida programada'),
                                child: Text(
                                  _salidaProgramada == null ? 'Seleccionar...' : _fmtFechaHora(_salidaProgramada!),
                                  style: const TextStyle(fontSize: 13),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: InkWell(
                              onTap: () => _seleccionarFecha((d) => setState(() => _llegadaProgramada = d), _llegadaProgramada),
                              child: InputDecorator(
                                decoration: _decoracionCompacta('Llegada programada'),
                                child: Text(
                                  _llegadaProgramada == null ? 'Seleccionar...' : _fmtFechaHora(_llegadaProgramada!),
                                  style: const TextStyle(fontSize: 13),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () => _seleccionarFecha((d) => setState(() => _salidaReal = d), _salidaReal),
                              child: InputDecorator(
                                decoration: _decoracionCompacta('Salida real'),
                                child: Text(
                                  _salidaReal == null ? 'Sin registrar' : _fmtFechaHora(_salidaReal!),
                                  style: const TextStyle(fontSize: 13),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: InkWell(
                              onTap: () => _seleccionarFecha((d) => setState(() => _llegadaReal = d), _llegadaReal),
                              child: InputDecorator(
                                decoration: _decoracionCompacta('Llegada real'),
                                child: Text(
                                  _llegadaReal == null ? 'Sin registrar' : _fmtFechaHora(_llegadaReal!),
                                  style: const TextStyle(fontSize: 13),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _duracionMinCtrl,
                        keyboardType: TextInputType.number,
                        decoration: _decoracionCompacta('Duración (minutos)'),
                      ),
                    ] else ...[
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('SALIDA PROGRAMADA', style: TextStyle(fontSize: 10, letterSpacing: 0.4, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
                                const SizedBox(height: 4),
                                Text(_fmtFechaHora(v2.salidaProgramada), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                if (v2.salidaReal != null)
                                  Text('Real: ${_fmtHora(v2.salidaReal!)}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                                if (codigoPuerta(v.puerta) != null)
                                  Text('Puerta ${codigoPuerta(v.puerta)}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('LLEGADA PROGRAMADA', style: TextStyle(fontSize: 10, letterSpacing: 0.4, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
                                const SizedBox(height: 4),
                                Text(_fmtFechaHora(v2.llegadaProgramada), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                if (v2.llegadaReal != null)
                                  Text('Real: ${_fmtHora(v2.llegadaReal!)}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (v.duracionMin != null) ...[
                        const SizedBox(height: 12),
                        Text('Duración estimada: ${v.duracionMin} min', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                      ],
                    ],
                  ],
                ),
              ),
              if (esAdmin) ...[
                const SizedBox(height: 24),
                const Text(
                  'CAMBIAR ESTADO',
                  style: TextStyle(fontSize: 10, letterSpacing: 0.4, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 10),
                _EstadoSelector(
                  estadoActual: v2.estado,
                  cargando: _actualizandoEstado,
                  onSeleccionar: (nuevo) => _cambiarEstado(v2, nuevo),
                ),
              ],
              const SizedBox(height: 20),
              if (esAdmin)
                ElevatedButton.icon(
                  onPressed: _guardando ? null : () => _guardarCambios(v2),
                  icon: const Icon(Icons.save_outlined),
                  label: const Text('Guardar cambios'),
                )
              else if (v.estado == 'cancelado')
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline, color: AppColors.error),
                      SizedBox(width: 10),
                      Expanded(child: Text('Este vuelo fue cancelado y no admite reservas.')),
                    ],
                  ),
                )
              else
                ElevatedButton.icon(
                  onPressed: () => context.push('/reservas/nuevo', extra: v2),
                  icon: const Icon(Icons.airline_seat_recline_normal),
                  label: const Text('Reservar este vuelo'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Grilla de 6 botones para que el administrador cambie el estado del
/// vuelo con un toque, sin pasar por el formulario completo.
class _EstadoSelector extends StatelessWidget {
  final String estadoActual;
  final bool cargando;
  final ValueChanged<String> onSeleccionar;

  const _EstadoSelector({
    required this.estadoActual,
    required this.cargando,
    required this.onSeleccionar,
  });

  static const _opciones = [
    (valor: 'programado', etiqueta: 'Programado', icono: Icons.schedule),
    (valor: 'embarcando', etiqueta: 'Embarcando', icono: Icons.meeting_room_outlined),
    (valor: 'despegado', etiqueta: 'Despegado', icono: Icons.flight_takeoff),
    (valor: 'aterrizado', etiqueta: 'Aterrizado', icono: Icons.flight_land),
    (valor: 'cancelado', etiqueta: 'Cancelado', icono: Icons.cancel_outlined),
    (valor: 'retrasado', etiqueta: 'Retrasado', icono: Icons.warning_amber_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 2.4,
      children: _opciones.map((op) {
        final seleccionado = op.valor == estadoActual;
        final color = AppColors.colorEstado(op.valor);
        return Material(
          color: seleccionado ? color.withValues(alpha: 0.15) : AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: cargando ? null : () => onSeleccionar(op.valor),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: seleccionado ? color : AppColors.surfaceVariant),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(op.icono, color: seleccionado ? color : AppColors.textSecondary, size: 18),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      op.etiqueta,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: seleccionado ? color : AppColors.textPrimary,
                        fontWeight: seleccionado ? FontWeight.bold : FontWeight.normal,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
