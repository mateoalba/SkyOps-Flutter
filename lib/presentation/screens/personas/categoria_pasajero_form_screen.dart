import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/utils/validators.dart';
import '../../../domain/model/categoria_pasajero.dart';
import '../../providers/categoria_pasajero_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/loading_overlay.dart';
import '../../../theme/app_colors.dart';

class CategoriaPasajeroFormScreen extends StatefulWidget {
  final int? id;
  const CategoriaPasajeroFormScreen({super.key, this.id});

  @override
  State<CategoriaPasajeroFormScreen> createState() => _CategoriaPasajeroFormScreenState();
}

class _CategoriaPasajeroFormScreenState extends State<CategoriaPasajeroFormScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _cargado = false;
  bool _guardando = false;

  final _nombreCtrl = TextEditingController();
  String? _tipo = 'frequent_flyer';
  final _descripcionCtrl = TextEditingController();
  bool _requiereAsistencia = true;
  final _beneficiosCtrl = TextEditingController();
  bool _activa = true;

  bool get _esEdicion => widget.id != null;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _inicializar());
  }

  Future<void> _inicializar() async {

    if (_esEdicion) {
      final provider = context.read<CategoriaPasajeroProvider>();
      CategoriaPasajero? e;
      try {
        e = provider.items.firstWhere((it) => it.id == widget.id);
      } catch (_) {
        e = null;
      }
      if (e != null) {
        setState(() {
          _nombreCtrl.text = e!.nombre?.toString() ?? '';
          _tipo = e!.tipo;
          _descripcionCtrl.text = e!.descripcion?.toString() ?? '';
          _requiereAsistencia = e!.requiereAsistencia;
          _beneficiosCtrl.text = e!.beneficios?.toString() ?? '';
          _activa = e!.activa;
        });
      }
    }
    if (mounted) setState(() => _cargado = true);
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _descripcionCtrl.dispose();
    _beneficiosCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final esAdmin = context.watch<AuthProvider>().usuario?.esAdmin ?? false;
    final puedeEscribir = esAdmin;
    return Scaffold(
      appBar: AppBar(title: Text(_esEdicion ? 'Editar Categoría de Pasajero' : 'Nueva Categoría de Pasajero')),
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
                DropdownButtonFormField<String>(
                  value: _tipo,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Tipo'),
                  items: [
                    DropdownMenuItem(value: 'frequent_flyer', child: Text('Viajero frecuente')),
                    DropdownMenuItem(value: 'vip', child: Text('VIP')),
                    DropdownMenuItem(value: 'discapacidad', child: Text('Pasajero con discapacidad')),
                    DropdownMenuItem(value: 'menor_no_acompanado', child: Text('Menor no acompañado')),
                    DropdownMenuItem(value: 'asistencia_medica', child: Text('Requiere asistencia médica')),
                    DropdownMenuItem(value: 'embarazada', child: Text('Embarazada')),
                    DropdownMenuItem(value: 'deportista', child: Text('Deportista / equipo')),
                    DropdownMenuItem(value: 'diplomatico', child: Text('Diplomático')),
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
                  validator: null,
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  value: _requiereAsistencia,
                  onChanged: !puedeEscribir ? null : (v) => setState(() => _requiereAsistencia = v),
                  title: const Text('Requiere Asistencia'),
                  contentPadding: EdgeInsets.zero,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _beneficiosCtrl,
                  enabled: puedeEscribir,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'Beneficios'),
                  validator: null,
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  value: _activa,
                  onChanged: !puedeEscribir ? null : (v) => setState(() => _activa = v),
                  title: const Text('Activa'),
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
    final item = CategoriaPasajero(
      id: widget.id,
      nombre: _nombreCtrl.text.trim(),
      tipo: _tipo!,
      descripcion: _descripcionCtrl.text.trim().isEmpty ? null : _descripcionCtrl.text.trim(),
      requiereAsistencia: _requiereAsistencia,
      beneficios: _beneficiosCtrl.text.trim().isEmpty ? null : _beneficiosCtrl.text.trim(),
      activa: _activa,
    );

    final provider = context.read<CategoriaPasajeroProvider>();
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
