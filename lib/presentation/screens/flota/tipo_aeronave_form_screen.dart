import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/utils/validators.dart';
import '../../../domain/model/tipo_aeronave.dart';
import '../../providers/tipo_aeronave_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/loading_overlay.dart';
import '../../../theme/app_colors.dart';

class TipoAeronaveFormScreen extends StatefulWidget {
  final int? id;
  const TipoAeronaveFormScreen({super.key, this.id});

  @override
  State<TipoAeronaveFormScreen> createState() => _TipoAeronaveFormScreenState();
}

class _TipoAeronaveFormScreenState extends State<TipoAeronaveFormScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _cargado = false;
  bool _guardando = false;

  final _fabricanteCtrl = TextEditingController();
  final _modeloCtrl = TextEditingController();
  final _codigoIataCtrl = TextEditingController();
  String? _categoria = 'narrow';
  final _capacidadPasajerosMinCtrl = TextEditingController();
  final _capacidadPasajerosMaxCtrl = TextEditingController();
  final _autonomiaKmCtrl = TextEditingController();
  final _velocidadCruceroKmhCtrl = TextEditingController();
  final _descripcionCtrl = TextEditingController();
  bool _enProduccion = true;

  bool get _esEdicion => widget.id != null;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _inicializar());
  }

  Future<void> _inicializar() async {

    if (_esEdicion) {
      final provider = context.read<TipoAeronaveProvider>();
      TipoAeronave? e;
      try {
        e = provider.items.firstWhere((it) => it.id == widget.id);
      } catch (_) {
        e = null;
      }
      if (e != null) {
        setState(() {
          _fabricanteCtrl.text = e!.fabricante?.toString() ?? '';
          _modeloCtrl.text = e!.modelo?.toString() ?? '';
          _codigoIataCtrl.text = e!.codigoIata?.toString() ?? '';
          _categoria = e!.categoria;
          _capacidadPasajerosMinCtrl.text = e!.capacidadPasajerosMin?.toString() ?? '';
          _capacidadPasajerosMaxCtrl.text = e!.capacidadPasajerosMax?.toString() ?? '';
          _autonomiaKmCtrl.text = e!.autonomiaKm?.toString() ?? '';
          _velocidadCruceroKmhCtrl.text = e!.velocidadCruceroKmh?.toString() ?? '';
          _descripcionCtrl.text = e!.descripcion?.toString() ?? '';
          _enProduccion = e!.enProduccion;
        });
      }
    }
    if (mounted) setState(() => _cargado = true);
  }

  @override
  void dispose() {
    _fabricanteCtrl.dispose();
    _modeloCtrl.dispose();
    _codigoIataCtrl.dispose();
    _capacidadPasajerosMinCtrl.dispose();
    _capacidadPasajerosMaxCtrl.dispose();
    _autonomiaKmCtrl.dispose();
    _velocidadCruceroKmhCtrl.dispose();
    _descripcionCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final esAdmin = context.watch<AuthProvider>().usuario?.esAdmin ?? false;
    final puedeEscribir = esAdmin;
    return Scaffold(
      appBar: AppBar(title: Text(_esEdicion ? 'Editar Tipo de Aeronave' : 'Nuevo Tipo de Aeronave')),
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
                  controller: _fabricanteCtrl,
                  enabled: puedeEscribir,
                  
                  decoration: const InputDecoration(labelText: 'Fabricante'),
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
                  controller: _codigoIataCtrl,
                  enabled: puedeEscribir,
                  
                  decoration: const InputDecoration(labelText: 'Codigo Iata'),
                  validator: null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _categoria,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Categoria'),
                  items: [
                    DropdownMenuItem(value: 'narrow', child: Text('Narrow-body (pasillo único)')),
                    DropdownMenuItem(value: 'wide', child: Text('Wide-body (doble pasillo)')),
                    DropdownMenuItem(value: 'regional', child: Text('Regional / turbohélice')),
                    DropdownMenuItem(value: 'cargo', child: Text('Carguero')),
                    DropdownMenuItem(value: 'privado', child: Text('Aviación privada')),
                  ],
                  onChanged: !puedeEscribir ? null : (v) => setState(() => _categoria = v),
                  validator: (v) => v == null ? 'Selecciona categoria' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _capacidadPasajerosMinCtrl,
                  enabled: puedeEscribir,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Capacidad Pasajeros Min'),
                  validator: Validators.numero,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _capacidadPasajerosMaxCtrl,
                  enabled: puedeEscribir,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Capacidad Pasajeros Max'),
                  validator: Validators.numero,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _autonomiaKmCtrl,
                  enabled: puedeEscribir,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Autonomia Km'),
                  validator: Validators.numero,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _velocidadCruceroKmhCtrl,
                  enabled: puedeEscribir,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Velocidad Crucero Kmh'),
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
                SwitchListTile(
                  value: _enProduccion,
                  onChanged: !puedeEscribir ? null : (v) => setState(() => _enProduccion = v),
                  title: const Text('En Produccion'),
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
    final item = TipoAeronave(
      id: widget.id,
      fabricante: _fabricanteCtrl.text.trim(),
      modelo: _modeloCtrl.text.trim(),
      codigoIata: _codigoIataCtrl.text.trim(),
      categoria: _categoria!,
      capacidadPasajerosMin: int.tryParse(_capacidadPasajerosMinCtrl.text.trim())!,
      capacidadPasajerosMax: int.tryParse(_capacidadPasajerosMaxCtrl.text.trim())!,
      autonomiaKm: int.tryParse(_autonomiaKmCtrl.text.trim())!,
      velocidadCruceroKmh: int.tryParse(_velocidadCruceroKmhCtrl.text.trim())!,
      descripcion: _descripcionCtrl.text.trim(),
      enProduccion: _enProduccion,
    );

    final provider = context.read<TipoAeronaveProvider>();
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
