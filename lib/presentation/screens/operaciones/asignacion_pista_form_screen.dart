import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/utils/validators.dart';
import '../../../domain/model/asignacion_pista.dart';
import '../../providers/asignacion_pista_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/vuelo_provider.dart';
import '../../providers/pista_provider.dart';
import '../../widgets/loading_overlay.dart';
import '../../../theme/app_colors.dart';

class AsignacionPistaFormScreen extends StatefulWidget {
  final String? id;
  const AsignacionPistaFormScreen({super.key, this.id});

  @override
  State<AsignacionPistaFormScreen> createState() => _AsignacionPistaFormScreenState();
}

class _AsignacionPistaFormScreenState extends State<AsignacionPistaFormScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _cargado = false;
  bool _guardando = false;

  String? _vuelo;
  String? _pista;
  String? _tipoOperacion = 'aterrizaje';
  DateTime? _horaInicio;
  DateTime? _horaFin;
  DateTime? _creadoEn;

  bool get _esEdicion => widget.id != null;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _inicializar());
  }

  Future<void> _inicializar() async {
    await context.read<VueloProvider>().cargar();
    await context.read<PistaProvider>().cargar();
    if (_esEdicion) {
      final provider = context.read<AsignacionPistaProvider>();
      AsignacionPista? e;
      try {
        e = provider.items.firstWhere((it) => it.id == widget.id);
      } catch (_) {
        e = null;
      }
      if (e != null) {
        setState(() {
          _vuelo = e!.vuelo;
          _pista = e!.pista;
          _tipoOperacion = e!.tipoOperacion;
          _horaInicio = e!.horaInicio;
          _horaFin = e!.horaFin;
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

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final _opcVueloProvider = context.watch<VueloProvider>().items;
    final _opcPistaProvider = context.watch<PistaProvider>().items;
    final esAdmin = context.watch<AuthProvider>().usuario?.esAdmin ?? false;
    final puedeEscribir = esAdmin;
    return Scaffold(
      appBar: AppBar(title: Text(_esEdicion ? 'Editar Asignación de Pista' : 'Nueva Asignación de Pista')),
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
                  value: _vuelo,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Vuelo'),
                  items: _opcVueloProvider.map((item) {
                    return DropdownMenuItem<String>(
                      value: item.id,
                      child: Text(item.numeroVuelo, overflow: TextOverflow.ellipsis),
                    );
                  }).toList(),
                  onChanged: !puedeEscribir ? null : (v) => setState(() => _vuelo = v),
                  validator: (v) => v == null ? 'Selecciona vuelo' : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _pista,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Pista'),
                  items: _opcPistaProvider.map((item) {
                    return DropdownMenuItem<String>(
                      value: item.id,
                      child: Text(item.identificador, overflow: TextOverflow.ellipsis),
                    );
                  }).toList(),
                  onChanged: !puedeEscribir ? null : (v) => setState(() => _pista = v),
                  validator: (v) => v == null ? 'Selecciona pista' : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _tipoOperacion,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Tipo Operacion'),
                  items: [
                    DropdownMenuItem(value: 'aterrizaje', child: Text('Aterrizaje')),
                    DropdownMenuItem(value: 'despegue', child: Text('Despegue')),
                    DropdownMenuItem(value: 'prueba', child: Text('Prueba')),
                  ],
                  onChanged: !puedeEscribir ? null : (v) => setState(() => _tipoOperacion = v),
                  validator: (v) => v == null ? 'Selecciona tipo operacion' : null,
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: !puedeEscribir ? null : () => _seleccionarFecha((d) => setState(() => _horaInicio = d), _horaInicio),
                  child: InputDecorator(
                    decoration: const InputDecoration(labelText: 'Hora Inicio'),
                    child: Text(_horaInicio == null ? 'Seleccionar...' : _horaInicio.toString()),
                  ),
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: !puedeEscribir ? null : () => _seleccionarFecha((d) => setState(() => _horaFin = d), _horaFin),
                  child: InputDecorator(
                    decoration: const InputDecoration(labelText: 'Hora Fin'),
                    child: Text(_horaFin == null ? 'Seleccionar...' : _horaFin.toString()),
                  ),
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
    setState(() => _guardando = true);
    final item = AsignacionPista(
      id: widget.id,
      vuelo: _vuelo!,
      pista: _pista!,
      tipoOperacion: _tipoOperacion!,
      horaInicio: _horaInicio!,
      horaFin: _horaFin!,
      creadoEn: _creadoEn,
    );

    final provider = context.read<AsignacionPistaProvider>();
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
