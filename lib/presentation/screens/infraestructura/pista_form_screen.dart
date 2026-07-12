import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/utils/validators.dart';
import '../../../domain/model/pista.dart';
import '../../providers/pista_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/aeropuerto_provider.dart';
import '../../widgets/loading_overlay.dart';
import '../../../theme/app_colors.dart';

class PistaFormScreen extends StatefulWidget {
  final String? id;
  const PistaFormScreen({super.key, this.id});

  @override
  State<PistaFormScreen> createState() => _PistaFormScreenState();
}

class _PistaFormScreenState extends State<PistaFormScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _cargado = false;
  bool _guardando = false;

  String? _aeropuerto;
  final _identificadorCtrl = TextEditingController();
  final _longitudMetrosCtrl = TextEditingController();
  String? _superficie = 'asfalto';
  String? _estado = 'operativa';
  DateTime? _creadoEn;

  bool get _esEdicion => widget.id != null;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _inicializar());
  }

  Future<void> _inicializar() async {
    await context.read<AeropuertoProvider>().cargar();
    if (_esEdicion) {
      final provider = context.read<PistaProvider>();
      Pista? e;
      try {
        e = provider.items.firstWhere((it) => it.id == widget.id);
      } catch (_) {
        e = null;
      }
      if (e != null) {
        setState(() {
          _aeropuerto = e!.aeropuerto;
          _identificadorCtrl.text = e!.identificador?.toString() ?? '';
          _longitudMetrosCtrl.text = e!.longitudMetros?.toString() ?? '';
          _superficie = e!.superficie;
          _estado = e!.estado;
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
    _identificadorCtrl.dispose();
    _longitudMetrosCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final _opcAeropuertoProvider = context.watch<AeropuertoProvider>().items;
    final esAdmin = context.watch<AuthProvider>().usuario?.esAdmin ?? false;
    final puedeEscribir = esAdmin;
    return Scaffold(
      appBar: AppBar(title: Text(_esEdicion ? 'Editar Pista de Aterrizaje' : 'Nueva Pista de Aterrizaje')),
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
                  validator: (v) => v == null ? 'Selecciona aeropuerto' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _identificadorCtrl,
                  enabled: puedeEscribir,
                  
                  decoration: const InputDecoration(labelText: 'Identificador'),
                  validator: Validators.requerido,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _longitudMetrosCtrl,
                  enabled: puedeEscribir,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Longitud Metros'),
                  validator: Validators.numero,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _superficie,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Superficie'),
                  items: [
                    DropdownMenuItem(value: 'asfalto', child: Text('Asfalto')),
                    DropdownMenuItem(value: 'concreto', child: Text('Concreto')),
                    DropdownMenuItem(value: 'cesped', child: Text('Césped')),
                    DropdownMenuItem(value: 'grava', child: Text('Grava')),
                  ],
                  onChanged: !puedeEscribir ? null : (v) => setState(() => _superficie = v),
                  validator: (v) => v == null ? 'Selecciona superficie' : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _estado,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Estado'),
                  items: [
                    DropdownMenuItem(value: 'operativa', child: Text('Operativa')),
                    DropdownMenuItem(value: 'cerrada', child: Text('Cerrada')),
                    DropdownMenuItem(value: 'mantenimiento', child: Text('En mantenimiento')),
                  ],
                  onChanged: !puedeEscribir ? null : (v) => setState(() => _estado = v),
                  validator: (v) => v == null ? 'Selecciona estado' : null,
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
    final item = Pista(
      id: widget.id,
      aeropuerto: _aeropuerto!,
      identificador: _identificadorCtrl.text.trim(),
      longitudMetros: int.tryParse(_longitudMetrosCtrl.text.trim())!,
      superficie: _superficie!,
      estado: _estado!,
      creadoEn: _creadoEn,
    );

    final provider = context.read<PistaProvider>();
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
