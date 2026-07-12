import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/utils/validators.dart';
import '../../../domain/model/mantenimiento.dart';
import '../../providers/mantenimiento_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/aeronave_provider.dart';
import '../../providers/aeropuerto_provider.dart';
import '../../widgets/loading_overlay.dart';
import '../../../theme/app_colors.dart';

class MantenimientoFormScreen extends StatefulWidget {
  final String? id;
  const MantenimientoFormScreen({super.key, this.id});

  @override
  State<MantenimientoFormScreen> createState() => _MantenimientoFormScreenState();
}

class _MantenimientoFormScreenState extends State<MantenimientoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _cargado = false;
  bool _guardando = false;

  String? _aeronave;
  String? _aeropuerto;
  String? _tipo = 'preventivo';
  String? _estado = 'programado';
  final _descripcionCtrl = TextEditingController();
  final _tecnicoResponsableCtrl = TextEditingController();
  DateTime? _fechaInicio;
  DateTime? _fechaFinEstimada;
  DateTime? _fechaFinReal;
  final _costoEstimadoCtrl = TextEditingController();
  final _costoRealCtrl = TextEditingController();
  final _horasFueraServicioCtrl = TextEditingController();
  final _observacionesCtrl = TextEditingController();
  DateTime? _creadoEn;

  bool get _esEdicion => widget.id != null;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _inicializar());
  }

  Future<void> _inicializar() async {
    await context.read<AeronaveProvider>().cargar();
    await context.read<AeropuertoProvider>().cargar();
    if (_esEdicion) {
      final provider = context.read<MantenimientoProvider>();
      Mantenimiento? e;
      try {
        e = provider.items.firstWhere((it) => it.id == widget.id);
      } catch (_) {
        e = null;
      }
      if (e != null) {
        setState(() {
          _aeronave = e!.aeronave;
          _aeropuerto = e!.aeropuerto;
          _tipo = e!.tipo;
          _estado = e!.estado;
          _descripcionCtrl.text = e!.descripcion?.toString() ?? '';
          _tecnicoResponsableCtrl.text = e!.tecnicoResponsable?.toString() ?? '';
          _fechaInicio = e!.fechaInicio;
          _fechaFinEstimada = e!.fechaFinEstimada;
          _fechaFinReal = e!.fechaFinReal;
          _costoEstimadoCtrl.text = e!.costoEstimado?.toString() ?? '';
          _costoRealCtrl.text = e!.costoReal?.toString() ?? '';
          _horasFueraServicioCtrl.text = e!.horasFueraServicio?.toString() ?? '';
          _observacionesCtrl.text = e!.observaciones?.toString() ?? '';
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
    _descripcionCtrl.dispose();
    _tecnicoResponsableCtrl.dispose();
    _costoEstimadoCtrl.dispose();
    _costoRealCtrl.dispose();
    _horasFueraServicioCtrl.dispose();
    _observacionesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final _opcAeronaveProvider = context.watch<AeronaveProvider>().items;
    final _opcAeropuertoProvider = context.watch<AeropuertoProvider>().items;
    final esAdmin = context.watch<AuthProvider>().usuario?.esAdmin ?? false;
    final puedeEscribir = esAdmin;
    return Scaffold(
      appBar: AppBar(title: Text(_esEdicion ? 'Editar Mantenimiento' : 'Nuevo Mantenimiento')),
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
                  value: _aeronave,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Aeronave'),
                  items: _opcAeronaveProvider.map((item) {
                    return DropdownMenuItem<String>(
                      value: item.id,
                      child: Text('${item.matricula} (${item.modelo})', overflow: TextOverflow.ellipsis),
                    );
                  }).toList(),
                  onChanged: !puedeEscribir ? null : (v) => setState(() => _aeronave = v),
                  validator: (v) => v == null ? 'Selecciona aeronave' : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _aeropuerto,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Aeropuerto'),
                  items: _opcAeropuertoProvider.map((item) {
                    return DropdownMenuItem<String>(
                      value: item.id,
                      child: Text('${item.codigoIata} - ${item.nombre}', overflow: TextOverflow.ellipsis),
                    );
                  }).toList(),
                  onChanged: !puedeEscribir ? null : (v) => setState(() => _aeropuerto = v),
                  validator: null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _tipo,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Tipo'),
                  items: [
                    DropdownMenuItem(value: 'preventivo', child: Text('Preventivo')),
                    DropdownMenuItem(value: 'correctivo', child: Text('Correctivo')),
                    DropdownMenuItem(value: 'revision_a', child: Text('Revisión A')),
                    DropdownMenuItem(value: 'revision_b', child: Text('Revisión B')),
                    DropdownMenuItem(value: 'revision_c', child: Text('Revisión C')),
                    DropdownMenuItem(value: 'emergencia', child: Text('Emergencia')),
                  ],
                  onChanged: !puedeEscribir ? null : (v) => setState(() => _tipo = v),
                  validator: (v) => v == null ? 'Selecciona tipo' : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _estado,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Estado'),
                  items: [
                    DropdownMenuItem(value: 'programado', child: Text('Programado')),
                    DropdownMenuItem(value: 'en_progreso', child: Text('En progreso')),
                    DropdownMenuItem(value: 'completado', child: Text('Completado')),
                    DropdownMenuItem(value: 'cancelado', child: Text('Cancelado')),
                    DropdownMenuItem(value: 'postergado', child: Text('Postergado')),
                  ],
                  onChanged: !puedeEscribir ? null : (v) => setState(() => _estado = v),
                  validator: (v) => v == null ? 'Selecciona estado' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descripcionCtrl,
                  enabled: puedeEscribir,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'Descripcion'),
                  validator: Validators.requerido,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _tecnicoResponsableCtrl,
                  enabled: puedeEscribir,
                  
                  decoration: const InputDecoration(labelText: 'Tecnico Responsable'),
                  validator: Validators.requerido,
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: !puedeEscribir ? null : () => _seleccionarFecha((d) => setState(() => _fechaInicio = d), _fechaInicio),
                  child: InputDecorator(
                    decoration: const InputDecoration(labelText: 'Fecha Inicio'),
                    child: Text(_fechaInicio == null ? 'Seleccionar...' : _fechaInicio.toString()),
                  ),
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: !puedeEscribir ? null : () => _seleccionarFecha((d) => setState(() => _fechaFinEstimada = d), _fechaFinEstimada),
                  child: InputDecorator(
                    decoration: const InputDecoration(labelText: 'Fecha Fin Estimada'),
                    child: Text(_fechaFinEstimada == null ? 'Seleccionar...' : _fechaFinEstimada.toString()),
                  ),
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: !puedeEscribir ? null : () => _seleccionarFecha((d) => setState(() => _fechaFinReal = d), _fechaFinReal),
                  child: InputDecorator(
                    decoration: const InputDecoration(labelText: 'Fecha Fin Real'),
                    child: Text(_fechaFinReal == null ? 'Seleccionar...' : _fechaFinReal.toString()),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _costoEstimadoCtrl,
                  enabled: puedeEscribir,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Costo Estimado'),
                  validator: null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _costoRealCtrl,
                  enabled: puedeEscribir,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Costo Real'),
                  validator: null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _horasFueraServicioCtrl,
                  enabled: puedeEscribir,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Horas Fuera Servicio'),
                  validator: null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _observacionesCtrl,
                  enabled: puedeEscribir,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'Observaciones'),
                  validator: null,
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
    final item = Mantenimiento(
      id: widget.id,
      aeronave: _aeronave!,
      aeropuerto: _aeropuerto,
      tipo: _tipo!,
      estado: _estado!,
      descripcion: _descripcionCtrl.text.trim(),
      tecnicoResponsable: _tecnicoResponsableCtrl.text.trim(),
      fechaInicio: _fechaInicio!,
      fechaFinEstimada: _fechaFinEstimada!,
      fechaFinReal: _fechaFinReal,
      costoEstimado: double.tryParse(_costoEstimadoCtrl.text.trim()),
      costoReal: double.tryParse(_costoRealCtrl.text.trim()),
      horasFueraServicio: int.tryParse(_horasFueraServicioCtrl.text.trim()),
      observaciones: _observacionesCtrl.text.trim().isEmpty ? null : _observacionesCtrl.text.trim(),
      creadoEn: _creadoEn,
    );

    final provider = context.read<MantenimientoProvider>();
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
