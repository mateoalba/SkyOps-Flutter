import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/utils/validators.dart';
import '../../../domain/model/tripulante.dart';
import '../../providers/tripulante_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/aerolinea_provider.dart';
import '../../widgets/loading_overlay.dart';
import '../../../theme/app_colors.dart';

class TripulanteFormScreen extends StatefulWidget {
  final String? id;
  const TripulanteFormScreen({super.key, this.id});

  @override
  State<TripulanteFormScreen> createState() => _TripulanteFormScreenState();
}

class _TripulanteFormScreenState extends State<TripulanteFormScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _cargado = false;
  bool _guardando = false;

  String? _aerolinea;
  final _nombreCtrl = TextEditingController();
  final _apellidoCtrl = TextEditingController();
  String? _rol = 'piloto';
  final _numLicenciaCtrl = TextEditingController();
  bool _disponible = true;

  bool get _esEdicion => widget.id != null;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _inicializar());
  }

  Future<void> _inicializar() async {
    await context.read<AerolineaProvider>().cargar();
    if (_esEdicion) {
      final provider = context.read<TripulanteProvider>();
      Tripulante? e;
      try {
        e = provider.items.firstWhere((it) => it.id == widget.id);
      } catch (_) {
        e = null;
      }
      if (e != null) {
        setState(() {
          _aerolinea = e!.aerolinea;
          _nombreCtrl.text = e!.nombre?.toString() ?? '';
          _apellidoCtrl.text = e!.apellido?.toString() ?? '';
          _rol = e!.rol;
          _numLicenciaCtrl.text = e!.numLicencia?.toString() ?? '';
          _disponible = e!.disponible;
        });
      }
    }
    if (mounted) setState(() => _cargado = true);
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _apellidoCtrl.dispose();
    _numLicenciaCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final _opcAerolineaProvider = context.watch<AerolineaProvider>().items;
    final esAdmin = context.watch<AuthProvider>().usuario?.esAdmin ?? false;
    final puedeEscribir = context.watch<AuthProvider>().usuario?.puedeOperar ?? false;
    return Scaffold(
      appBar: AppBar(title: Text(_esEdicion ? 'Editar Tripulante' : 'Nuevo Tripulante')),
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
                TextFormField(
                  controller: _nombreCtrl,
                  enabled: puedeEscribir,
                  
                  decoration: const InputDecoration(labelText: 'Nombre'),
                  validator: Validators.requerido,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _apellidoCtrl,
                  enabled: puedeEscribir,
                  
                  decoration: const InputDecoration(labelText: 'Apellido'),
                  validator: Validators.requerido,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _rol,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Rol'),
                  items: [
                    DropdownMenuItem(value: 'piloto', child: Text('Piloto')),
                    DropdownMenuItem(value: 'copiloto', child: Text('Copiloto')),
                    DropdownMenuItem(value: 'auxiliar', child: Text('Auxiliar de vuelo')),
                    DropdownMenuItem(value: 'jefe_cabina', child: Text('Jefe de cabina')),
                  ],
                  onChanged: !puedeEscribir ? null : (v) => setState(() => _rol = v),
                  validator: (v) => v == null ? 'Selecciona rol' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _numLicenciaCtrl,
                  enabled: puedeEscribir,
                  
                  decoration: const InputDecoration(labelText: 'Num Licencia'),
                  validator: Validators.requerido,
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  value: _disponible,
                  onChanged: !puedeEscribir ? null : (v) => setState(() => _disponible = v),
                  title: const Text('Disponible'),
                  contentPadding: EdgeInsets.zero,
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
    final item = Tripulante(
      id: widget.id,
      aerolinea: _aerolinea!,
      nombre: _nombreCtrl.text.trim(),
      apellido: _apellidoCtrl.text.trim(),
      rol: _rol!,
      numLicencia: _numLicenciaCtrl.text.trim(),
      disponible: _disponible,
    );

    final provider = context.read<TripulanteProvider>();
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
