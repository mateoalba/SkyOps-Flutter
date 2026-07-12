import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/utils/validators.dart';
import '../../../domain/model/aeronave.dart';
import '../../providers/aeronave_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/aerolinea_provider.dart';
import '../../widgets/loading_overlay.dart';
import '../../../theme/app_colors.dart';

class AeronaveFormScreen extends StatefulWidget {
  final String? id;
  const AeronaveFormScreen({super.key, this.id});

  @override
  State<AeronaveFormScreen> createState() => _AeronaveFormScreenState();
}

class _AeronaveFormScreenState extends State<AeronaveFormScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _cargado = false;
  bool _guardando = false;

  String? _aerolinea;
  final _matriculaCtrl = TextEditingController();
  final _modeloCtrl = TextEditingController();
  final _fabricanteCtrl = TextEditingController();
  final _capacidadCtrl = TextEditingController();
  String? _estado = 'activa';

  bool get _esEdicion => widget.id != null;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _inicializar());
  }

  Future<void> _inicializar() async {
    await context.read<AerolineaProvider>().cargar();
    if (_esEdicion) {
      final provider = context.read<AeronaveProvider>();
      Aeronave? e;
      try {
        e = provider.items.firstWhere((it) => it.id == widget.id);
      } catch (_) {
        e = null;
      }
      if (e != null) {
        setState(() {
          _aerolinea = e!.aerolinea;
          _matriculaCtrl.text = e!.matricula?.toString() ?? '';
          _modeloCtrl.text = e!.modelo?.toString() ?? '';
          _fabricanteCtrl.text = e!.fabricante?.toString() ?? '';
          _capacidadCtrl.text = e!.capacidad?.toString() ?? '';
          _estado = e!.estado;
        });
      }
    }
    if (mounted) setState(() => _cargado = true);
  }

  @override
  void dispose() {
    _matriculaCtrl.dispose();
    _modeloCtrl.dispose();
    _fabricanteCtrl.dispose();
    _capacidadCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final _opcAerolineaProvider = context.watch<AerolineaProvider>().items;
    final esAdmin = context.watch<AuthProvider>().usuario?.esAdmin ?? false;
    final puedeEscribir = context.watch<AuthProvider>().usuario?.puedeOperar ?? false;
    return Scaffold(
      appBar: AppBar(title: Text(_esEdicion ? 'Editar Aeronave' : 'Nueva Aeronave')),
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
                  controller: _matriculaCtrl,
                  enabled: puedeEscribir,
                  
                  decoration: const InputDecoration(labelText: 'Matricula'),
                  validator: Validators.requerido,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _modeloCtrl,
                  enabled: puedeEscribir,
                  
                  decoration: const InputDecoration(labelText: 'Modelo'),
                  validator: Validators.requerido,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _fabricanteCtrl,
                  enabled: puedeEscribir,
                  
                  decoration: const InputDecoration(labelText: 'Fabricante'),
                  validator: Validators.requerido,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _capacidadCtrl,
                  enabled: puedeEscribir,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Capacidad'),
                  validator: Validators.numero,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _estado,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Estado'),
                  items: [
                    DropdownMenuItem(value: 'activa', child: Text('Activa')),
                    DropdownMenuItem(value: 'mantenimiento', child: Text('En mantenimiento')),
                    DropdownMenuItem(value: 'retirada', child: Text('Retirada')),
                  ],
                  onChanged: !puedeEscribir ? null : (v) => setState(() => _estado = v),
                  validator: (v) => v == null ? 'Selecciona estado' : null,
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
    final item = Aeronave(
      id: widget.id,
      aerolinea: _aerolinea!,
      matricula: _matriculaCtrl.text.trim(),
      modelo: _modeloCtrl.text.trim(),
      fabricante: _fabricanteCtrl.text.trim(),
      capacidad: int.tryParse(_capacidadCtrl.text.trim())!,
      estado: _estado!,
    );

    final provider = context.read<AeronaveProvider>();
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
