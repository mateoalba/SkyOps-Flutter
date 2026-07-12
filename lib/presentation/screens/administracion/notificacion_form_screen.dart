import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/utils/validators.dart';
import '../../../domain/model/notificacion.dart';
import '../../providers/notificacion_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/pasajero_provider.dart';
import '../../providers/vuelo_provider.dart';
import '../../providers/reserva_provider.dart';
import '../../widgets/loading_overlay.dart';
import '../../../theme/app_colors.dart';

class NotificacionFormScreen extends StatefulWidget {
  final int? id;
  const NotificacionFormScreen({super.key, this.id});

  @override
  State<NotificacionFormScreen> createState() => _NotificacionFormScreenState();
}

class _NotificacionFormScreenState extends State<NotificacionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _cargado = false;
  bool _guardando = false;

  String? _pasajero;
  String? _vuelo;
  String? _tipo = 'retraso';
  String? _canal = 'email';
  final _asuntoCtrl = TextEditingController();
  final _mensajeCtrl = TextEditingController();
  String? _estado = 'pendiente';
  DateTime? _fechaEnvio;
  DateTime? _fechaLectura;
  DateTime? _creadaEn;

  bool get _esEdicion => widget.id != null;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _inicializar());
  }

  Future<void> _inicializar() async {
    await context.read<PasajeroProvider>().cargar();
    await context.read<VueloProvider>().cargar();
    await context.read<ReservaProvider>().cargar();
    if (_esEdicion) {
      final provider = context.read<NotificacionProvider>();
      Notificacion? e;
      try {
        e = provider.items.firstWhere((it) => it.id == widget.id);
      } catch (_) {
        e = null;
      }
      if (e != null) {
        setState(() {
          _pasajero = e!.pasajero;
          _vuelo = e!.vuelo;
          _tipo = e!.tipo;
          _canal = e!.canal;
          _asuntoCtrl.text = e!.asunto?.toString() ?? '';
          _mensajeCtrl.text = e!.mensaje?.toString() ?? '';
          _estado = e!.estado;
          _fechaEnvio = e!.fechaEnvio;
          _fechaLectura = e!.fechaLectura;
          _creadaEn = e!.creadaEn;
        });
      }
    }
    if (mounted) setState(() => _cargado = true);
  }

  // El pasajero no tiene un vuelo asociado directamente: la relación pasa
  // por su reserva más reciente (pasajero -> reserva -> vuelo). Al elegir
  // el pasajero, se busca esa reserva y se autocompleta el vuelo.
  void _autocompletarDesdePasajero(String pasajeroId) {
    final reservas = context.read<ReservaProvider>().items.where((r) => r.pasajero == pasajeroId).toList()
      ..sort((a, b) => (b.reservadoEn ?? DateTime(0)).compareTo(a.reservadoEn ?? DateTime(0)));
    if (reservas.isNotEmpty) {
      final vueloId = reservas.first.vuelo;
      final existe = context.read<VueloProvider>().items.any((v) => v.id == vueloId);
      if (existe) setState(() => _vuelo = vueloId);
    }
    _autocompletarPlantilla();
  }

  // Sugiere asunto/mensaje según el tipo elegido, usando el nombre del
  // pasajero y el número de vuelo ya seleccionados. Solo rellena si el
  // admin todavía no escribió nada, para no pisar texto manual.
  void _autocompletarPlantilla() {
    if (_asuntoCtrl.text.trim().isNotEmpty || _mensajeCtrl.text.trim().isNotEmpty) return;
    String? nombrePasajero;
    if (_pasajero != null) {
      try {
        final p = context.read<PasajeroProvider>().items.firstWhere((it) => it.id == _pasajero);
        nombrePasajero = p.nombre;
      } catch (_) {}
    }
    String? numeroVuelo;
    if (_vuelo != null) {
      try {
        final v = context.read<VueloProvider>().items.firstWhere((it) => it.id == _vuelo);
        numeroVuelo = v.numeroVuelo;
      } catch (_) {}
    }
    final plantilla = _plantilla(_tipo, nombrePasajero, numeroVuelo);
    setState(() {
      _asuntoCtrl.text = plantilla.$1;
      _mensajeCtrl.text = plantilla.$2;
    });
  }

  (String, String) _plantilla(String? tipo, String? nombre, String? vuelo) {
    final n = (nombre?.isNotEmpty ?? false) ? nombre! : 'pasajero';
    final v = (vuelo?.isNotEmpty ?? false) ? vuelo! : 'tu vuelo';
    switch (tipo) {
      case 'retraso':
        return ('Tu vuelo $v tiene un retraso', 'Estimado/a $n, te informamos que $v ha sido reprogramado. Revisa la nueva hora de salida en la app.');
      case 'cancelacion':
        return ('Tu vuelo $v ha sido cancelado', 'Estimado/a $n, lamentamos informarte que $v fue cancelado. Contáctanos para reprogramar tu viaje.');
      case 'cambio_puerta':
        return ('Cambio de puerta de embarque', 'Estimado/a $n, la puerta de embarque de $v cambió. Dirígete a la nueva puerta con anticipación.');
      case 'embarque':
        return ('Llamado a embarque: $v', 'Estimado/a $n, tu vuelo $v está iniciando el proceso de embarque. Dirígete a la puerta asignada.');
      case 'confirmacion':
        return ('Tu reserva ha sido confirmada', 'Estimado/a $n, hemos confirmado tu reserva para el vuelo $v. ¡Buen viaje!');
      case 'recordatorio':
        return ('Recordatorio de tu vuelo $v', 'Estimado/a $n, te recordamos que tu vuelo $v se acerca. Revisa los horarios y documentos necesarios.');
      case 'equipaje':
        return ('Actualización de tu equipaje', 'Estimado/a $n, hay una actualización sobre el estado de tu equipaje del vuelo $v.');
      default:
        return ('Notificación sobre tu vuelo $v', 'Estimado/a $n, tenemos información importante sobre $v.');
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
    _asuntoCtrl.dispose();
    _mensajeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final _opcPasajeroProvider = context.watch<PasajeroProvider>().items;
    final _opcVueloProvider = context.watch<VueloProvider>().items;
    final esAdmin = context.watch<AuthProvider>().usuario?.esAdmin ?? false;
    final puedeEscribir = esAdmin;
    return Scaffold(
      appBar: AppBar(title: Text(_esEdicion ? 'Editar Notificación' : 'Nueva Notificación')),
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
                  value: _pasajero,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Pasajero'),
                  items: _opcPasajeroProvider.map((item) {
                    return DropdownMenuItem<String>(
                      value: item.id,
                      child: Text('${item.nombre} ${item.apellido}', overflow: TextOverflow.ellipsis),
                    );
                  }).toList(),
                  onChanged: !puedeEscribir ? null : (v) {
                    setState(() => _pasajero = v);
                    if (v != null) _autocompletarDesdePasajero(v);
                  },
                  validator: (v) => v == null ? 'Selecciona pasajero' : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _vuelo,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Vuelo'),
                  items: _opcVueloProvider.map((item) {
                    return DropdownMenuItem<String>(
                      value: item.id,
                      child: Text(item.numeroVuelo, overflow: TextOverflow.ellipsis),
                    );
                  }).toList(),
                  onChanged: !puedeEscribir ? null : (v) {
                    setState(() => _vuelo = v);
                    _autocompletarPlantilla();
                  },
                  validator: null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _tipo,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Tipo'),
                  items: [
                    DropdownMenuItem(value: 'retraso', child: Text('Retraso de vuelo')),
                    DropdownMenuItem(value: 'cancelacion', child: Text('Cancelación de vuelo')),
                    DropdownMenuItem(value: 'cambio_puerta', child: Text('Cambio de puerta')),
                    DropdownMenuItem(value: 'embarque', child: Text('Llamado a embarque')),
                    DropdownMenuItem(value: 'confirmacion', child: Text('Confirmación de reserva')),
                    DropdownMenuItem(value: 'recordatorio', child: Text('Recordatorio de vuelo')),
                    DropdownMenuItem(value: 'equipaje', child: Text('Estado de equipaje')),
                    DropdownMenuItem(value: 'otro', child: Text('Otro')),
                  ],
                  onChanged: !puedeEscribir ? null : (v) {
                    setState(() => _tipo = v);
                    _autocompletarPlantilla();
                  },
                  validator: (v) => v == null ? 'Selecciona tipo' : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _canal,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Canal'),
                  items: [
                    DropdownMenuItem(value: 'email', child: Text('Correo electrónico')),
                    DropdownMenuItem(value: 'sms', child: Text('SMS')),
                    DropdownMenuItem(value: 'push', child: Text('Notificación push')),
                    DropdownMenuItem(value: 'sistema', child: Text('Sistema interno')),
                  ],
                  onChanged: !puedeEscribir ? null : (v) => setState(() => _canal = v),
                  validator: (v) => v == null ? 'Selecciona canal' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _asuntoCtrl,
                  enabled: puedeEscribir,
                  
                  decoration: const InputDecoration(labelText: 'Asunto'),
                  validator: Validators.requerido,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _mensajeCtrl,
                  enabled: puedeEscribir,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'Mensaje'),
                  validator: Validators.requerido,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _estado,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Estado'),
                  items: [
                    DropdownMenuItem(value: 'pendiente', child: Text('Pendiente de envío')),
                    DropdownMenuItem(value: 'enviada', child: Text('Enviada')),
                    DropdownMenuItem(value: 'leida', child: Text('Leída')),
                    DropdownMenuItem(value: 'fallida', child: Text('Fallo en el envío')),
                  ],
                  onChanged: !puedeEscribir ? null : (v) => setState(() => _estado = v),
                  validator: (v) => v == null ? 'Selecciona estado' : null,
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: !puedeEscribir ? null : () => _seleccionarFecha((d) => setState(() => _fechaEnvio = d), _fechaEnvio),
                  child: InputDecorator(
                    decoration: const InputDecoration(labelText: 'Fecha Envio'),
                    child: Text(_fechaEnvio == null ? 'Seleccionar...' : _fechaEnvio.toString()),
                  ),
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: !puedeEscribir ? null : () => _seleccionarFecha((d) => setState(() => _fechaLectura = d), _fechaLectura),
                  child: InputDecorator(
                    decoration: const InputDecoration(labelText: 'Fecha Lectura'),
                    child: Text(_fechaLectura == null ? 'Seleccionar...' : _fechaLectura.toString()),
                  ),
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: !puedeEscribir ? null : () => _seleccionarFecha((d) => setState(() => _creadaEn = d), _creadaEn),
                  child: InputDecorator(
                    decoration: const InputDecoration(labelText: 'Creada En'),
                    child: Text(_creadaEn == null ? 'Seleccionar...' : _creadaEn.toString()),
                  ),
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
    final item = Notificacion(
      id: widget.id,
      pasajero: _pasajero!,
      vuelo: _vuelo,
      tipo: _tipo!,
      canal: _canal!,
      asunto: _asuntoCtrl.text.trim(),
      mensaje: _mensajeCtrl.text.trim(),
      estado: _estado!,
      fechaEnvio: _fechaEnvio,
      fechaLectura: _fechaLectura,
      creadaEn: _creadaEn,
    );

    final provider = context.read<NotificacionProvider>();
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
