import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/utils/validators.dart';
import '../../../domain/model/horario.dart';
import '../../providers/horario_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/aerolinea_provider.dart';
import '../../providers/aeropuerto_provider.dart';
import '../../widgets/loading_overlay.dart';
import '../../../theme/app_colors.dart';

class HorarioFormScreen extends StatefulWidget {
  final String? id;
  const HorarioFormScreen({super.key, this.id});

  @override
  State<HorarioFormScreen> createState() => _HorarioFormScreenState();
}

class _HorarioFormScreenState extends State<HorarioFormScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _cargado = false;
  bool _guardando = false;

  String? _aerolinea;
  String? _origen;
  String? _destino;
  final _numeroVueloBaseCtrl = TextEditingController();
  TimeOfDay? _horaSalida;
  bool _activo = true;
  DateTime? _creadoEn;

  bool get _esEdicion => widget.id != null;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _inicializar());
  }

  Future<void> _inicializar() async {
    await context.read<AerolineaProvider>().cargar();
    await context.read<AeropuertoProvider>().cargar();
    if (_esEdicion) {
      final provider = context.read<HorarioProvider>();
      Horario? e;
      try {
        e = provider.items.firstWhere((it) => it.id == widget.id);
      } catch (_) {
        e = null;
      }
      if (e != null) {
        setState(() {
          _aerolinea = e!.aerolinea;
          _origen = e!.origen;
          _destino = e!.destino;
          _numeroVueloBaseCtrl.text = e!.numeroVueloBase?.toString() ?? '';
          _horaSalida = _parsearHora(e!.horaSalida);
          _activo = e!.activo;
          _creadoEn = e!.creadoEn;
        });
      }
    }
    if (mounted) setState(() => _cargado = true);
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
    _numeroVueloBaseCtrl.dispose();
    super.dispose();
  }

  TimeOfDay? _parsearHora(String? valor) {
    if (valor == null || valor.isEmpty) return null;
    final partes = valor.split(':');
    if (partes.length < 2) return null;
    final h = int.tryParse(partes[0]);
    final m = int.tryParse(partes[1]);
    if (h == null || m == null) return null;
    return TimeOfDay(hour: h, minute: m);
  }

  String _formatearHora(TimeOfDay hora) {
    final h = hora.hour.toString().padLeft(2, '0');
    final m = hora.minute.toString().padLeft(2, '0');
    return '$h:$m:00';
  }

  Future<void> _seleccionarHora() async {
    final hora = await showTimePicker(
      context: context,
      initialTime: _horaSalida ?? TimeOfDay.now(),
    );
    if (hora != null) setState(() => _horaSalida = hora);
  }

  @override
  Widget build(BuildContext context) {
    final _opcAerolineaProvider = context.watch<AerolineaProvider>().items;
    final _opcAeropuertoProvider = context.watch<AeropuertoProvider>().items;
    final esAdmin = context.watch<AuthProvider>().usuario?.esAdmin ?? false;
    final puedeEscribir = esAdmin;
    return Scaffold(
      appBar: AppBar(title: Text(_esEdicion ? 'Editar Horario de Vuelo' : 'Nuevo Horario de Vuelo')),
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
                  value: _aerolinea,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Aerolínea'),
                  items: _opcAerolineaProvider.map((item) {
                    return DropdownMenuItem<String>(
                      value: item.id,
                      child: Text(item.nombre, overflow: TextOverflow.ellipsis),
                    );
                  }).toList(),
                  onChanged: !puedeEscribir ? null : (v) => setState(() => _aerolinea = v),
                  validator: (v) => v == null ? 'Selecciona aerolínea' : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _origen,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Origen'),
                  items: _opcAeropuertoProvider.map((item) {
                    return DropdownMenuItem<String>(
                      value: item.id,
                      child: Text('${item.codigoIata} - ${item.nombre}', overflow: TextOverflow.ellipsis),
                    );
                  }).toList(),
                  onChanged: !puedeEscribir ? null : (v) => setState(() => _origen = v),
                  validator: (v) => v == null ? 'Selecciona aeropuerto' : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _destino,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Destino'),
                  items: _opcAeropuertoProvider.map((item) {
                    return DropdownMenuItem<String>(
                      value: item.id,
                      child: Text('${item.codigoIata} - ${item.nombre}', overflow: TextOverflow.ellipsis),
                    );
                  }).toList(),
                  onChanged: !puedeEscribir ? null : (v) => setState(() => _destino = v),
                  validator: (v) => v == null ? 'Selecciona aeropuerto' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _numeroVueloBaseCtrl,
                  enabled: puedeEscribir,
                  decoration: const InputDecoration(labelText: 'Numero Vuelo Base'),
                  validator: Validators.requerido,
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: !puedeEscribir ? null : _seleccionarHora,
                  child: InputDecorator(
                    decoration: const InputDecoration(labelText: 'Hora Salida'),
                    child: Text(_horaSalida == null ? 'Seleccionar...' : _horaSalida!.format(context)),
                  ),
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  value: _activo,
                  onChanged: !puedeEscribir ? null : (v) => setState(() => _activo = v),
                  title: const Text('Activo'),
                  contentPadding: EdgeInsets.zero,
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: !puedeEscribir ? null : () => _seleccionarFecha((d) => setState(() => _creadoEn = d), _creadoEn),
                  child: InputDecorator(
                    decoration: const InputDecoration(labelText: 'Creado En'),
                    child: Text(_creadoEn == null ? 'Seleccionar...' : _creadoEn.toString()),
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
    if (_horaSalida == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona la hora de salida')),
      );
      return;
    }
    setState(() => _guardando = true);
    final item = Horario(
      id: widget.id,
      aerolinea: _aerolinea!,
      origen: _origen!,
      destino: _destino!,
      numeroVueloBase: _numeroVueloBaseCtrl.text.trim(),
      horaSalida: _formatearHora(_horaSalida!),
      activo: _activo,
      creadoEn: _creadoEn,
    );

    final provider = context.read<HorarioProvider>();
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
