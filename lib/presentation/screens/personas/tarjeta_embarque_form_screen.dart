import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/utils/validators.dart';
import '../../../domain/model/tarjeta_embarque.dart';
import '../../../domain/model/vuelo.dart';
import '../../../domain/model/reserva.dart';
import '../../providers/tarjeta_embarque_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/reserva_provider.dart';
import '../../providers/vuelo_provider.dart';
import '../../providers/puerta_provider.dart';
import '../../widgets/loading_overlay.dart';
import '../../../theme/app_colors.dart';

class TarjetaEmbarqueFormScreen extends StatefulWidget {
  final int? id;
  const TarjetaEmbarqueFormScreen({super.key, this.id});

  @override
  State<TarjetaEmbarqueFormScreen> createState() => _TarjetaEmbarqueFormScreenState();
}

class _TarjetaEmbarqueFormScreenState extends State<TarjetaEmbarqueFormScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _cargado = false;
  bool _guardando = false;

  String? _reserva;
  final _asientoCtrl = TextEditingController();
  final _puertaEmbarqueCtrl = TextEditingController();
  final _grupoEmbarqueCtrl = TextEditingController();
  DateTime? _horaLimiteEmbarque;
  String? _estado = 'generada';
  DateTime? _fechaEmision;
  bool _checkInOnline = true;
  final _observacionesCtrl = TextEditingController();

  bool get _esEdicion => widget.id != null;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _inicializar());
  }

  Future<void> _inicializar() async {
    await context.read<ReservaProvider>().cargar();
    await context.read<VueloProvider>().cargar();
    await context.read<PuertaProvider>().cargar();
    if (_esEdicion) {
      final provider = context.read<TarjetaEmbarqueProvider>();
      TarjetaEmbarque? e;
      try {
        e = provider.items.firstWhere((it) => it.id == widget.id);
      } catch (_) {
        e = null;
      }
      if (e != null) {
        setState(() {
          _reserva = e!.reserva;
          _asientoCtrl.text = e!.asiento?.toString() ?? '';
          _puertaEmbarqueCtrl.text = e!.puertaEmbarque?.toString() ?? '';
          _grupoEmbarqueCtrl.text = e!.grupoEmbarque?.toString() ?? '';
          _horaLimiteEmbarque = e!.horaLimiteEmbarque;
          _estado = e!.estado;
          _fechaEmision = e!.fechaEmision;
          _checkInOnline = e!.checkInOnline;
          _observacionesCtrl.text = e!.observaciones?.toString() ?? '';
        });
      }
    }
    if (mounted) setState(() => _cargado = true);
  }

  // Al elegir la reserva, autocompleta asiento y puerta con lo que ya se
  // definió al momento de reservar (numero_asiento del pasajero y la
  // puerta asignada al vuelo), en vez de pedirle al admin que los vuelva
  // a escribir a mano.
  void _autocompletarDesdeReserva(String reservaId) {
    final reserva = context.read<ReservaProvider>().items.firstWhere(
          (r) => r.id == reservaId,
          orElse: () => throw StateError('no encontrada'),
        );
    _asientoCtrl.text = reserva.numeroAsiento;

    Vuelo? vuelo;
    try {
      vuelo = context.read<VueloProvider>().items.firstWhere((v) => v.id == reserva.vuelo);
    } catch (_) {
      vuelo = null;
    }
    if (vuelo == null) return;

    if (vuelo.puerta != null) {
      try {
        final puerta = context.read<PuertaProvider>().items.firstWhere((p) => p.id == vuelo!.puerta);
        _puertaEmbarqueCtrl.text = puerta.codigo;
      } catch (_) {
        // La puerta del vuelo no está en el catálogo cargado: se deja que
        // el admin la escriba a mano.
      }
    }

    // Hora límite de embarque por defecto: 45 min antes de la salida
    // programada del vuelo. El admin puede ajustarla si hace falta.
    _horaLimiteEmbarque ??= vuelo.salidaProgramada.subtract(const Duration(minutes: 45));
  }

  bool _reservaSeleccionadaNoConfirmada(List<Reserva> opcReserva) {
    if (_reserva == null) return false;
    try {
      final r = opcReserva.firstWhere((it) => it.id == _reserva);
      return r.estado != 'confirmada';
    } catch (_) {
      return false;
    }
  }

  Future<void> _seleccionarFecha(void Function(DateTime) onSeleccionado, DateTime? actual) async {
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

  @override
  void dispose() {
    _asientoCtrl.dispose();
    _puertaEmbarqueCtrl.dispose();
    _grupoEmbarqueCtrl.dispose();
    _observacionesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final _opcReservaProvider = context.watch<ReservaProvider>().items;
    final esAdmin = context.watch<AuthProvider>().usuario?.esAdmin ?? false;
    final puedeEscribir = esAdmin;
    return Scaffold(
      appBar: AppBar(title: Text(_esEdicion ? 'Editar Tarjeta de Embarque' : 'Nueva Tarjeta de Embarque')),
      body: LoadingOverlay(
        visible: !_cargado || _guardando,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.surfaceVariant),
            ),
            child: Form(
              key: _formKey,
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
                            'Solo un administrador puede crear o editar registros en este módulo.',
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _reserva,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Reserva'),
                  items: _opcReservaProvider.map((item) {
                    final color = AppColors.colorEstado(item.estado);
                    return DropdownMenuItem<String>(
                      value: item.id,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                          ),
                          Flexible(
                            child: Text(
                              '${item.codigoReserva} — ${item.estadoDisplay ?? item.estado}',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: !puedeEscribir ? null : (v) {
                    setState(() => _reserva = v);
                    if (v != null) _autocompletarDesdeReserva(v);
                  },
                  validator: (v) => v == null ? 'Selecciona reserva' : null,
                ),
                if (_reservaSeleccionadaNoConfirmada(_opcReservaProvider)) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.warning_amber_rounded, color: Colors.amber, size: 18),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Esta reserva no está confirmada: el servidor no permitirá crear la tarjeta de embarque hasta que lo esté.',
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                TextFormField(
                  controller: _asientoCtrl,
                  enabled: puedeEscribir,
                  
                  decoration: const InputDecoration(labelText: 'Asiento'),
                  validator: Validators.requerido,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _puertaEmbarqueCtrl,
                  enabled: puedeEscribir,
                  
                  decoration: const InputDecoration(labelText: 'Puerta Embarque'),
                  validator: Validators.requerido,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _grupoEmbarqueCtrl,
                  enabled: puedeEscribir,
                  
                  decoration: const InputDecoration(labelText: 'Grupo Embarque'),
                  validator: null,
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: !puedeEscribir ? null : () => _seleccionarFecha((d) => setState(() => _horaLimiteEmbarque = d), _horaLimiteEmbarque),
                  child: InputDecorator(
                    decoration: const InputDecoration(labelText: 'Hora Limite Embarque'),
                    child: Text(_horaLimiteEmbarque == null ? 'Seleccionar...' : _horaLimiteEmbarque.toString()),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _estado,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Estado'),
                  items: [
                    DropdownMenuItem(value: 'generada', child: Text('Generada')),
                    DropdownMenuItem(value: 'usada', child: Text('Usada — pasajero abordó')),
                    DropdownMenuItem(value: 'cancelada', child: Text('Cancelada')),
                    DropdownMenuItem(value: 'expirada', child: Text('Expirada')),
                  ],
                  onChanged: !puedeEscribir ? null : (v) => setState(() => _estado = v),
                  validator: (v) => v == null ? 'Selecciona estado' : null,
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: !puedeEscribir ? null : () => _seleccionarFecha((d) => setState(() => _fechaEmision = d), _fechaEmision),
                  child: InputDecorator(
                    decoration: const InputDecoration(labelText: 'Fecha Emision'),
                    child: Text(_fechaEmision == null ? 'Seleccionar...' : _fechaEmision.toString()),
                  ),
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  value: _checkInOnline,
                  onChanged: !puedeEscribir ? null : (v) => setState(() => _checkInOnline = v),
                  title: const Text('Check In Online'),
                  contentPadding: EdgeInsets.zero,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _observacionesCtrl,
                  enabled: puedeEscribir,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'Observaciones'),
                  validator: null,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: (!puedeEscribir || _guardando) ? null : _guardar,
                  child: Text(_esEdicion ? 'Guardar cambios' : 'Crear registro'),
                ),
              ],
            ),
          ),
          ),
        ),
      ),
    );
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _guardando = true);
    final item = TarjetaEmbarque(
      id: widget.id,
      reserva: _reserva!,
      // El backend genera codigo_barras solo (UUID automatico) y lo ignora
      // si se manda algo distinto, asi que no hace falta pedirlo en el form.
      codigoBarras: '',
      asiento: _asientoCtrl.text.trim(),
      puertaEmbarque: _puertaEmbarqueCtrl.text.trim(),
      grupoEmbarque: _grupoEmbarqueCtrl.text.trim().isEmpty ? null : _grupoEmbarqueCtrl.text.trim(),
      horaLimiteEmbarque: _horaLimiteEmbarque!,
      estado: _estado!,
      fechaEmision: _fechaEmision,
      checkInOnline: _checkInOnline,
      observaciones: _observacionesCtrl.text.trim().isEmpty ? null : _observacionesCtrl.text.trim(),
    );

    final provider = context.read<TarjetaEmbarqueProvider>();
    final ok = _esEdicion
        ? await provider.actualizar(widget.id!, item)
        : await provider.crear(item);

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
}
