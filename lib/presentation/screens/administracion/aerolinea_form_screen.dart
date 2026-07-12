import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/utils/validators.dart';
import '../../../domain/model/aerolinea.dart';
import '../../providers/aerolinea_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/loading_overlay.dart';
import '../../../theme/app_colors.dart';

class AerolineaFormScreen extends StatefulWidget {
  final String? id;
  const AerolineaFormScreen({super.key, this.id});

  @override
  State<AerolineaFormScreen> createState() => _AerolineaFormScreenState();
}

class _AerolineaFormScreenState extends State<AerolineaFormScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _cargado = false;
  bool _guardando = false;

  final _nombreCtrl = TextEditingController();
  final _codigoIataCtrl = TextEditingController();
  final _paisCtrl = TextEditingController();
  bool _activa = true;
  DateTime? _creadoEn;

  bool get _esEdicion => widget.id != null;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _inicializar());
  }

  Future<void> _inicializar() async {

    if (_esEdicion) {
      final provider = context.read<AerolineaProvider>();
      Aerolinea? e;
      try {
        e = provider.items.firstWhere((it) => it.id == widget.id);
      } catch (_) {
        e = null;
      }
      if (e != null) {
        setState(() {
          _nombreCtrl.text = e!.nombre?.toString() ?? '';
          _codigoIataCtrl.text = e!.codigoIata?.toString() ?? '';
          _paisCtrl.text = e!.pais?.toString() ?? '';
          _activa = e!.activa;
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
    _nombreCtrl.dispose();
    _codigoIataCtrl.dispose();
    _paisCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final esAdmin = context.watch<AuthProvider>().usuario?.esAdmin ?? false;
    final puedeEscribir = context.watch<AuthProvider>().usuario?.puedeOperar ?? false;
    return Scaffold(
      appBar: AppBar(title: Text(_esEdicion ? 'Editar Aerolínea' : 'Nueva Aerolínea')),
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
                TextFormField(
                  controller: _nombreCtrl,
                  enabled: puedeEscribir,
                  
                  decoration: const InputDecoration(labelText: 'Nombre'),
                  validator: Validators.requerido,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _codigoIataCtrl,
                  enabled: puedeEscribir,
                  
                  decoration: const InputDecoration(labelText: 'Codigo Iata'),
                  validator: Validators.requerido,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _paisCtrl,
                  enabled: puedeEscribir,
                  
                  decoration: const InputDecoration(labelText: 'Pais'),
                  validator: Validators.requerido,
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  value: _activa,
                  onChanged: !puedeEscribir ? null : (v) => setState(() => _activa = v),
                  title: const Text('Activa'),
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
    setState(() => _guardando = true);
    final item = Aerolinea(
      id: widget.id,
      nombre: _nombreCtrl.text.trim(),
      codigoIata: _codigoIataCtrl.text.trim(),
      pais: _paisCtrl.text.trim(),
      activa: _activa,
      creadoEn: _creadoEn,
    );

    final provider = context.read<AerolineaProvider>();
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
