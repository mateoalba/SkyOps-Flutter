import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/utils/validators.dart';
import '../../../domain/model/incidente.dart';
import '../../providers/incidente_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/vuelo_provider.dart';
import '../../widgets/loading_overlay.dart';
import '../../../theme/app_colors.dart';

class IncidenteFormScreen extends StatefulWidget {
  final String? id;
  const IncidenteFormScreen({super.key, this.id});

  @override
  State<IncidenteFormScreen> createState() => _IncidenteFormScreenState();
}

class _IncidenteFormScreenState extends State<IncidenteFormScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _cargado = false;
  bool _guardando = false;

  String? _vuelo;
  String? _tipo = 'tecnico';
  final _descripcionCtrl = TextEditingController();
  String? _severidad = 'baja';
  DateTime? _reportadoEn;
  String? _estadoResolucion = 'abierto';

  bool get _esEdicion => widget.id != null;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _inicializar());
  }

  Future<void> _inicializar() async {
    await context.read<VueloProvider>().cargar();
    if (_esEdicion) {
      final provider = context.read<IncidenteProvider>();
      Incidente? e;
      try {
        e = provider.items.firstWhere((it) => it.id == widget.id);
      } catch (_) {
        e = null;
      }
      if (e != null) {
        setState(() {
          _vuelo = e!.vuelo;
          _tipo = e!.tipo;
          _descripcionCtrl.text = e!.descripcion?.toString() ?? '';
          _severidad = e!.severidad;
          _reportadoEn = e!.reportadoEn;
          _estadoResolucion = e!.estadoResolucion;
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final _opcVueloProvider = context.watch<VueloProvider>().items;
    final esAdmin = context.watch<AuthProvider>().usuario?.esAdmin ?? false;
    final puedeEscribir = context.watch<AuthProvider>().usuario?.puedeOperar ?? false;
    return Scaffold(
      appBar: AppBar(title: Text(_esEdicion ? 'Editar Incidente' : 'Nuevo Incidente')),
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
                  value: _tipo,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Tipo'),
                  items: [
                    DropdownMenuItem(value: 'tecnico', child: Text('Técnico')),
                    DropdownMenuItem(value: 'medico', child: Text('Médico')),
                    DropdownMenuItem(value: 'seguridad', child: Text('Seguridad')),
                    DropdownMenuItem(value: 'meteorologico', child: Text('Meteorológico')),
                    DropdownMenuItem(value: 'operacional', child: Text('Operacional')),
                    DropdownMenuItem(value: 'otro', child: Text('Otro')),
                  ],
                  onChanged: !puedeEscribir ? null : (v) => setState(() => _tipo = v),
                  validator: (v) => v == null ? 'Selecciona tipo' : null,
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
                DropdownButtonFormField<String>(
                  value: _severidad,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Severidad'),
                  items: [
                    DropdownMenuItem(value: 'baja', child: Text('Baja')),
                    DropdownMenuItem(value: 'media', child: Text('Media')),
                    DropdownMenuItem(value: 'alta', child: Text('Alta')),
                    DropdownMenuItem(value: 'critica', child: Text('Crítica')),
                  ],
                  onChanged: !puedeEscribir ? null : (v) => setState(() => _severidad = v),
                  validator: (v) => v == null ? 'Selecciona severidad' : null,
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: !puedeEscribir ? null : () => _seleccionarFecha((d) => setState(() => _reportadoEn = d), _reportadoEn),
                  child: InputDecorator(
                    decoration: const InputDecoration(labelText: 'Reportado En'),
                    child: Text(_reportadoEn == null ? 'Seleccionar...' : _reportadoEn.toString()),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _estadoResolucion,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Estado Resolucion'),
                  items: [
                    DropdownMenuItem(value: 'abierto', child: Text('Abierto')),
                    DropdownMenuItem(value: 'en_proceso', child: Text('En proceso')),
                    DropdownMenuItem(value: 'resuelto', child: Text('Resuelto')),
                  ],
                  onChanged: !puedeEscribir ? null : (v) => setState(() => _estadoResolucion = v),
                  validator: (v) => v == null ? 'Selecciona estado resolucion' : null,
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
    final item = Incidente(
      id: widget.id,
      vuelo: _vuelo!,
      tipo: _tipo!,
      descripcion: _descripcionCtrl.text.trim(),
      severidad: _severidad!,
      reportadoEn: _reportadoEn,
      estadoResolucion: _estadoResolucion!,
    );

    final provider = context.read<IncidenteProvider>();
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
