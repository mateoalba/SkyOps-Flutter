import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/utils/validators.dart';
import '../../../domain/model/certificacion.dart';
import '../../providers/certificacion_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/tripulante_provider.dart';
import '../../providers/tipo_aeronave_provider.dart';
import '../../widgets/loading_overlay.dart';
import '../../../theme/app_colors.dart';

class CertificacionFormScreen extends StatefulWidget {
  final String? id;
  const CertificacionFormScreen({super.key, this.id});

  @override
  State<CertificacionFormScreen> createState() => _CertificacionFormScreenState();
}

class _CertificacionFormScreenState extends State<CertificacionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _cargado = false;
  bool _guardando = false;

  String? _tripulante;
  String? _tipoAeronaveHabilitado;
  String? _tipo = 'licencia_piloto';
  String? _estado = 'vigente';
  final _numeroCertificadoCtrl = TextEditingController();
  final _entidadEmisoraCtrl = TextEditingController();
  DateTime? _fechaEmision;
  DateTime? _fechaVencimiento;
  final _observacionesCtrl = TextEditingController();
  DateTime? _creadoEn;

  bool get _esEdicion => widget.id != null;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _inicializar());
  }

  Future<void> _inicializar() async {
    await context.read<TripulanteProvider>().cargar();
    await context.read<TipoAeronaveProvider>().cargar();
    if (_esEdicion) {
      final provider = context.read<CertificacionProvider>();
      Certificacion? e;
      try {
        e = provider.items.firstWhere((it) => it.id == widget.id);
      } catch (_) {
        e = null;
      }
      if (e != null) {
        setState(() {
          _tripulante = e!.tripulante;
          _tipoAeronaveHabilitado = (e!.tipoAeronaveHabilitado?.isNotEmpty ?? false) ? e!.tipoAeronaveHabilitado : null;
          _tipo = e!.tipo;
          _estado = e!.estado;
          _numeroCertificadoCtrl.text = e!.numeroCertificado?.toString() ?? '';
          _entidadEmisoraCtrl.text = e!.entidadEmisora?.toString() ?? '';
          _fechaEmision = e!.fechaEmision;
          _fechaVencimiento = e!.fechaVencimiento;
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
    _numeroCertificadoCtrl.dispose();
    _entidadEmisoraCtrl.dispose();
    _observacionesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final _opcTripulanteProvider = context.watch<TripulanteProvider>().items;
    final opcTipoAeronave = context.watch<TipoAeronaveProvider>().items;
    final esAdmin = context.watch<AuthProvider>().usuario?.esAdmin ?? false;
    final puedeEscribir = esAdmin;

    // Opciones del dropdown: catálogo real de tipos de aeronave. Si el
    // registro ya tenía un valor libre que no está en el catálogo (datos
    // viejos), se agrega igual como opción para no perderlo al editar.
    final opcionesTipoAeronave = opcTipoAeronave.map((t) => '${t.fabricante} ${t.modelo}').toList();
    if (_tipoAeronaveHabilitado != null && !opcionesTipoAeronave.contains(_tipoAeronaveHabilitado)) {
      opcionesTipoAeronave.add(_tipoAeronaveHabilitado!);
    }
    return Scaffold(
      appBar: AppBar(title: Text(_esEdicion ? 'Editar Certificación' : 'Nueva Certificación')),
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
                  value: _tripulante,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Tripulante'),
                  items: _opcTripulanteProvider.map((item) {
                    return DropdownMenuItem<String>(
                      value: item.id,
                      child: Text('${item.nombre} ${item.apellido}', overflow: TextOverflow.ellipsis),
                    );
                  }).toList(),
                  onChanged: !puedeEscribir ? null : (v) => setState(() => _tripulante = v),
                  validator: (v) => v == null ? 'Selecciona tripulante' : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _tipoAeronaveHabilitado,
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: 'Tipo Aeronave Habilitado',
                    helperText: opcTipoAeronave.isEmpty ? 'Sin tipos de aeronave registrados' : null,
                  ),
                  items: opcionesTipoAeronave.map((nombre) {
                    return DropdownMenuItem(value: nombre, child: Text(nombre, overflow: TextOverflow.ellipsis));
                  }).toList(),
                  onChanged: !puedeEscribir ? null : (v) => setState(() => _tipoAeronaveHabilitado = v),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _tipo,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Tipo'),
                  items: [
                    DropdownMenuItem(value: 'licencia_piloto', child: Text('Licencia de piloto')),
                    DropdownMenuItem(value: 'habilitacion_tipo', child: Text('Habilitación de tipo')),
                    DropdownMenuItem(value: 'cert_medico', child: Text('Certificado médico')),
                    DropdownMenuItem(value: 'recurrente', child: Text('Recurrente')),
                    DropdownMenuItem(value: 'emergencias', child: Text('Emergencias')),
                    DropdownMenuItem(value: 'servicio_cabina', child: Text('Servicio de cabina')),
                    DropdownMenuItem(value: 'seguridad', child: Text('Seguridad')),
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
                    DropdownMenuItem(value: 'vigente', child: Text('Vigente')),
                    DropdownMenuItem(value: 'por_vencer', child: Text('Por vencer')),
                    DropdownMenuItem(value: 'vencida', child: Text('Vencida')),
                    DropdownMenuItem(value: 'suspendida', child: Text('Suspendida')),
                    DropdownMenuItem(value: 'renovada', child: Text('Renovada')),
                  ],
                  onChanged: !puedeEscribir ? null : (v) => setState(() => _estado = v),
                  validator: (v) => v == null ? 'Selecciona estado' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _numeroCertificadoCtrl,
                  enabled: puedeEscribir,
                  
                  decoration: const InputDecoration(labelText: 'Numero Certificado'),
                  validator: Validators.requerido,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _entidadEmisoraCtrl,
                  enabled: puedeEscribir,
                  
                  decoration: const InputDecoration(labelText: 'Entidad Emisora'),
                  validator: Validators.requerido,
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
                InkWell(
                  onTap: !puedeEscribir ? null : () => _seleccionarFecha((d) => setState(() => _fechaVencimiento = d), _fechaVencimiento),
                  child: InputDecorator(
                    decoration: const InputDecoration(labelText: 'Fecha Vencimiento'),
                    child: Text(_fechaVencimiento == null ? 'Seleccionar...' : _fechaVencimiento.toString()),
                  ),
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
    final item = Certificacion(
      id: widget.id,
      tripulante: _tripulante!,
      tipoAeronaveHabilitado: _tipoAeronaveHabilitado,
      tipo: _tipo!,
      estado: _estado!,
      numeroCertificado: _numeroCertificadoCtrl.text.trim(),
      entidadEmisora: _entidadEmisoraCtrl.text.trim(),
      fechaEmision: _fechaEmision!,
      fechaVencimiento: _fechaVencimiento!,
      observaciones: _observacionesCtrl.text.trim().isEmpty ? null : _observacionesCtrl.text.trim(),
      creadoEn: _creadoEn,
    );

    final provider = context.read<CertificacionProvider>();
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
