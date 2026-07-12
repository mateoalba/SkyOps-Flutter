import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../domain/model/vuelo.dart';
import '../../../domain/model/aeropuerto.dart';
import '../../providers/vuelo_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/aerolinea_provider.dart';
import '../../providers/aeronave_provider.dart';
import '../../providers/aeropuerto_provider.dart';
import '../../providers/puerta_provider.dart';
import '../../widgets/loading_overlay.dart';
import '../../../theme/app_colors.dart';

/// Formulario para crear (o editar) un vuelo, con el mismo lenguaje visual
/// que la pantalla de detalle: tarjeta redondeada, campos compactos y
/// selector DESDE/HASTA por aeropuerto.
class VueloFormScreen extends StatefulWidget {
  final String? id;
  const VueloFormScreen({super.key, this.id});

  @override
  State<VueloFormScreen> createState() => _VueloFormScreenState();
}

class _VueloFormScreenState extends State<VueloFormScreen> {
  bool _cargado = false;
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
  String _estado = 'programado';
  final _duracionMinCtrl = TextEditingController();

  bool get _esEdicion => widget.id != null;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _inicializar());
  }

  @override
  void dispose() {
    _numeroVueloCtrl.dispose();
    _duracionMinCtrl.dispose();
    super.dispose();
  }

  Future<void> _inicializar() async {
    await context.read<AerolineaProvider>().cargar();
    await context.read<AeronaveProvider>().cargar();
    await context.read<AeropuertoProvider>().cargar();
    await context.read<PuertaProvider>().cargar();
    if (_esEdicion) {
      final provider = context.read<VueloProvider>();
      Vuelo? e;
      try {
        e = provider.items.firstWhere((it) => it.id == widget.id);
      } catch (_) {
        e = null;
      }
      if (e != null) {
        setState(() {
          _aerolinea = e!.aerolinea;
          _aeronave = e!.aeronave;
          _origen = e!.origen;
          _destino = e!.destino;
          _puerta = e!.puerta;
          _numeroVueloCtrl.text = e!.numeroVuelo;
          _salidaProgramada = e!.salidaProgramada;
          _llegadaProgramada = e!.llegadaProgramada;
          _salidaReal = e!.salidaReal;
          _llegadaReal = e!.llegadaReal;
          _estado = e!.estado;
          _duracionMinCtrl.text = e!.duracionMin?.toString() ?? '';
        });
      }
    }
    if (mounted) setState(() => _cargado = true);
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

  String _fmtFechaHora(DateTime d) {
    final hh = d.hour.toString().padLeft(2, '0');
    final mm = d.minute.toString().padLeft(2, '0');
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year} $hh:$mm';
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

  Future<void> _guardar() async {
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
    final item = Vuelo(
      id: widget.id,
      aerolinea: _aerolinea!,
      aeronave: _aeronave,
      origen: _origen!,
      destino: _destino!,
      puerta: _puerta,
      numeroVuelo: _numeroVueloCtrl.text.trim(),
      salidaProgramada: _salidaProgramada!,
      llegadaProgramada: _llegadaProgramada!,
      salidaReal: _salidaReal,
      llegadaReal: _llegadaReal,
      estado: _estado,
      duracionMin: int.tryParse(_duracionMinCtrl.text.trim()),
    );

    final provider = context.read<VueloProvider>();
    final ok = _esEdicion ? await provider.actualizar(widget.id!, item) : await provider.crear(item);

    if (!mounted) return;
    setState(() => _guardando = false);
    if (ok) {
      context.pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.error ?? 'No se pudo guardar')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final opcAerolinea = context.watch<AerolineaProvider>().items;
    final opcAeronave = context.watch<AeronaveProvider>().items;
    final opcAeropuerto = context.watch<AeropuertoProvider>().items;
    final opcPuerta = context.watch<PuertaProvider>().items;
    final esAdmin = context.watch<AuthProvider>().usuario?.esAdmin ?? false;
    final puedeEscribir = esAdmin;

    dynamic aeropuertoPorId(String? id) {
      if (id == null) return null;
      try {
        return opcAeropuerto.firstWhere((a) => a.id == id);
      } catch (_) {
        return null;
      }
    }

    final origenAp = aeropuertoPorId(_origen);
    final destinoAp = aeropuertoPorId(_destino);

    final aeronavesFiltradas = _aerolinea == null
        ? opcAeronave
        : opcAeronave.where((a) => a.aerolinea == _aerolinea).toList();
    final puertasFiltradas = _origen == null
        ? opcPuerta
        : opcPuerta.where((p) => p.aeropuerto == _origen).toList();

    return Scaffold(
      appBar: AppBar(title: Text(_esEdicion ? 'Editar Vuelo' : 'Nuevo Vuelo')),
      body: LoadingOverlay(
        visible: !_cargado || _guardando,
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
                    if (!puedeEscribir)
                      Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.amber.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.lock_outline, color: Colors.amber, size: 18),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Solo un administrador puede crear o editar vuelos.',
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
                    DropdownButtonFormField<String>(
                      value: _aerolinea,
                      isExpanded: true,
                      dropdownColor: AppColors.surface,
                      decoration: _decoracionCompacta('Aerolínea'),
                      items: opcAerolinea.map((a) {
                        return DropdownMenuItem(value: a.id, child: Text(a.nombre, overflow: TextOverflow.ellipsis));
                      }).toList(),
                      onChanged: !puedeEscribir ? null : (val) => setState(() {
                        _aerolinea = val;
                        if (_aeronave != null && !opcAeronave.any((a) => a.id == _aeronave && a.aerolinea == val)) {
                          _aeronave = null;
                        }
                      }),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _numeroVueloCtrl,
                      enabled: puedeEscribir,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      decoration: _decoracionCompacta('Número de vuelo'),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: InkWell(
                            borderRadius: BorderRadius.circular(10),
                            onTap: !puedeEscribir ? null : () => _seleccionarAeropuerto(opcAeropuerto, (id) => setState(() {
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
                            onTap: !puedeEscribir ? null : () => _seleccionarAeropuerto(opcAeropuerto, (id) => setState(() => _destino = id)),
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
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _aeronave,
                      isExpanded: true,
                      dropdownColor: AppColors.surface,
                      decoration: _decoracionCompacta('Aeronave', ayuda: _aerolinea == null ? 'Elige primero la aerolínea' : null),
                      items: aeronavesFiltradas.map((a) {
                        return DropdownMenuItem(value: a.id, child: Text('${a.matricula} · ${a.modelo}', overflow: TextOverflow.ellipsis));
                      }).toList(),
                      onChanged: (!puedeEscribir || _aerolinea == null) ? null : (val) => setState(() => _aeronave = val),
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
                      onChanged: (!puedeEscribir || _origen == null) ? null : (val) => setState(() => _puerta = val),
                    ),
                    const SizedBox(height: 16),
                    Container(height: 1, color: AppColors.surfaceVariant),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: !puedeEscribir ? null : () => _seleccionarFecha((d) => setState(() => _salidaProgramada = d), _salidaProgramada),
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
                            onTap: !puedeEscribir ? null : () => _seleccionarFecha((d) => setState(() => _llegadaProgramada = d), _llegadaProgramada),
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
                            onTap: !puedeEscribir ? null : () => _seleccionarFecha((d) => setState(() => _salidaReal = d), _salidaReal),
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
                            onTap: !puedeEscribir ? null : () => _seleccionarFecha((d) => setState(() => _llegadaReal = d), _llegadaReal),
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
                      enabled: puedeEscribir,
                      keyboardType: TextInputType.number,
                      decoration: _decoracionCompacta('Duración (minutos)'),
                    ),
                    const SizedBox(height: 16),
                    Container(height: 1, color: AppColors.surfaceVariant),
                    const SizedBox(height: 16),
                    const Text(
                      'ESTADO',
                      style: TextStyle(fontSize: 10, letterSpacing: 0.4, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 10),
                    _EstadoSelector(
                      estadoActual: _estado,
                      cargando: !puedeEscribir,
                      onSeleccionar: (nuevo) => setState(() => _estado = nuevo),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: (!puedeEscribir || _guardando) ? null : _guardar,
                icon: Icon(_esEdicion ? Icons.save_outlined : Icons.add_circle_outline),
                label: Text(_esEdicion ? 'Guardar cambios' : 'Crear vuelo'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Grilla de 6 botones para elegir el estado del vuelo al crearlo o
/// editarlo (mismo estilo que el selector de la pantalla de detalle).
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
