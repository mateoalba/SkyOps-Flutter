import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/utils/validators.dart';
import '../../../domain/model/equipaje.dart';
import '../../providers/equipaje_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/reserva_provider.dart';
import '../../widgets/loading_overlay.dart';
import '../../../theme/app_colors.dart';

class EquipajeFormScreen extends StatefulWidget {
  final int? id;
  const EquipajeFormScreen({super.key, this.id});

  @override
  State<EquipajeFormScreen> createState() => _EquipajeFormScreenState();
}

class _EquipajeFormScreenState extends State<EquipajeFormScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _cargado = false;
  bool _guardando = false;

  String? _reserva;
  String? _tipo = 'mano';
  final _pesoKgCtrl = TextEditingController();
  final _descripcionCtrl = TextEditingController();
  final _codigoEtiquetaCtrl = TextEditingController();
  String? _estado = 'registrado';
  final _costoAdicionalCtrl = TextEditingController();
  DateTime? _fechaRegistro;

  bool get _esEdicion => widget.id != null;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _inicializar());
  }

  Future<void> _inicializar() async {
    await context.read<ReservaProvider>().cargar();
    if (_esEdicion) {
      final provider = context.read<EquipajeProvider>();
      Equipaje? e;
      try {
        e = provider.items.firstWhere((it) => it.id == widget.id);
      } catch (_) {
        e = null;
      }
      if (e != null) {
        setState(() {
          _reserva = e!.reserva;
          _tipo = e!.tipo;
          _pesoKgCtrl.text = e!.pesoKg?.toString() ?? '';
          _descripcionCtrl.text = e!.descripcion?.toString() ?? '';
          _codigoEtiquetaCtrl.text = e!.codigoEtiqueta?.toString() ?? '';
          _estado = e!.estado;
          _costoAdicionalCtrl.text = e!.costoAdicional?.toString() ?? '';
          _fechaRegistro = e!.fechaRegistro;
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
    _pesoKgCtrl.dispose();
    _descripcionCtrl.dispose();
    _codigoEtiquetaCtrl.dispose();
    _costoAdicionalCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final _opcReservaProvider = context.watch<ReservaProvider>().items;
    final esAdmin = context.watch<AuthProvider>().usuario?.esAdmin ?? false;
    final puedeEscribir = esAdmin;
    return Scaffold(
      appBar: AppBar(title: Text(_esEdicion ? 'Editar Equipaje' : 'Nuevo Equipaje')),
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
                    return DropdownMenuItem<String>(
                      value: item.id,
                      child: Text(item.codigoReserva, overflow: TextOverflow.ellipsis),
                    );
                  }).toList(),
                  onChanged: !puedeEscribir ? null : (v) => setState(() => _reserva = v),
                  validator: (v) => v == null ? 'Selecciona reserva' : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _tipo,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Tipo'),
                  items: [
                    DropdownMenuItem(value: 'mano', child: Text('Equipaje de mano')),
                    DropdownMenuItem(value: 'bodega', child: Text('Equipaje de bodega')),
                    DropdownMenuItem(value: 'especial', child: Text('Equipaje especial (bicicleta, instrumento, etc.)')),
                  ],
                  onChanged: !puedeEscribir ? null : (v) => setState(() => _tipo = v),
                  validator: (v) => v == null ? 'Selecciona tipo' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _pesoKgCtrl,
                  enabled: puedeEscribir,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Peso Kg'),
                  validator: Validators.numero,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descripcionCtrl,
                  enabled: puedeEscribir,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'Descripcion'),
                  validator: null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _codigoEtiquetaCtrl,
                  enabled: puedeEscribir,
                  
                  decoration: const InputDecoration(labelText: 'Codigo Etiqueta'),
                  validator: Validators.requerido,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _estado,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Estado'),
                  items: [
                    DropdownMenuItem(value: 'registrado', child: Text('Registrado')),
                    DropdownMenuItem(value: 'en_vuelo', child: Text('En vuelo')),
                    DropdownMenuItem(value: 'entregado', child: Text('Entregado')),
                    DropdownMenuItem(value: 'perdido', child: Text('Perdido')),
                    DropdownMenuItem(value: 'dañado', child: Text('Dañado')),
                    DropdownMenuItem(value: 'retenido', child: Text('Retenido por aduana')),
                  ],
                  onChanged: !puedeEscribir ? null : (v) => setState(() => _estado = v),
                  validator: (v) => v == null ? 'Selecciona estado' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _costoAdicionalCtrl,
                  enabled: puedeEscribir,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Costo Adicional'),
                  validator: Validators.numero,
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: !puedeEscribir ? null : () => _seleccionarFecha((d) => setState(() => _fechaRegistro = d), _fechaRegistro),
                  child: InputDecorator(
                    decoration: const InputDecoration(labelText: 'Fecha Registro'),
                    child: Text(_fechaRegistro == null ? 'Seleccionar...' : _fechaRegistro.toString()),
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
    final item = Equipaje(
      id: widget.id,
      reserva: _reserva!,
      tipo: _tipo!,
      pesoKg: double.tryParse(_pesoKgCtrl.text.trim())!,
      descripcion: _descripcionCtrl.text.trim().isEmpty ? null : _descripcionCtrl.text.trim(),
      codigoEtiqueta: _codigoEtiquetaCtrl.text.trim(),
      estado: _estado!,
      costoAdicional: double.tryParse(_costoAdicionalCtrl.text.trim())!,
      fechaRegistro: _fechaRegistro,
    );

    final provider = context.read<EquipajeProvider>();
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
