import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/utils/validators.dart';
import '../../../domain/model/aeropuerto.dart';
import '../../providers/aeropuerto_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/loading_overlay.dart';
import '../../../theme/app_colors.dart';

class AeropuertoFormScreen extends StatefulWidget {
  final String? id;
  const AeropuertoFormScreen({super.key, this.id});

  @override
  State<AeropuertoFormScreen> createState() => _AeropuertoFormScreenState();
}

class _AeropuertoFormScreenState extends State<AeropuertoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _cargado = false;
  bool _guardando = false;

  final _nombreCtrl = TextEditingController();
  final _codigoIataCtrl = TextEditingController();
  final _ciudadCtrl = TextEditingController();
  final _paisCtrl = TextEditingController();
  final _latitudCtrl = TextEditingController();
  final _longitudCtrl = TextEditingController();
  final _zonaHorariaCtrl = TextEditingController();
  final _fotoUrlCtrl = TextEditingController();

  bool get _esEdicion => widget.id != null;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _inicializar());
  }

  Future<void> _inicializar() async {

    if (_esEdicion) {
      final provider = context.read<AeropuertoProvider>();
      Aeropuerto? e;
      try {
        e = provider.items.firstWhere((it) => it.id == widget.id);
      } catch (_) {
        e = null;
      }
      if (e != null) {
        setState(() {
          _nombreCtrl.text = e!.nombre?.toString() ?? '';
          _codigoIataCtrl.text = e!.codigoIata?.toString() ?? '';
          _ciudadCtrl.text = e!.ciudad?.toString() ?? '';
          _paisCtrl.text = e!.pais?.toString() ?? '';
          _latitudCtrl.text = e!.latitud?.toString() ?? '';
          _longitudCtrl.text = e!.longitud?.toString() ?? '';
          _zonaHorariaCtrl.text = e!.zonaHoraria?.toString() ?? '';
          _fotoUrlCtrl.text = e!.fotoUrl?.toString() ?? '';
        });
      }
    }
    if (mounted) setState(() => _cargado = true);
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _codigoIataCtrl.dispose();
    _ciudadCtrl.dispose();
    _paisCtrl.dispose();
    _latitudCtrl.dispose();
    _longitudCtrl.dispose();
    _zonaHorariaCtrl.dispose();
    _fotoUrlCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final esAdmin = context.watch<AuthProvider>().usuario?.esAdmin ?? false;
    final puedeEscribir = context.watch<AuthProvider>().usuario?.puedeOperar ?? false;
    final titulo = !puedeEscribir
        ? 'Aeropuerto'
        : (_esEdicion ? 'Editar Aeropuerto' : 'Nuevo Aeropuerto');
    return Scaffold(
      appBar: AppBar(title: Text(titulo)),
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
                  controller: _ciudadCtrl,
                  enabled: puedeEscribir,
                  
                  decoration: const InputDecoration(labelText: 'Ciudad'),
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
                TextFormField(
                  controller: _latitudCtrl,
                  enabled: puedeEscribir,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Latitud'),
                  validator: Validators.numero,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _longitudCtrl,
                  enabled: puedeEscribir,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Longitud'),
                  validator: Validators.numero,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _zonaHorariaCtrl,
                  enabled: puedeEscribir,
                  
                  decoration: const InputDecoration(labelText: 'Zona Horaria'),
                  validator: Validators.requerido,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _fotoUrlCtrl,
                  enabled: puedeEscribir,
                  decoration: const InputDecoration(
                    labelText: 'Foto Url',
                    hintText: 'https://... (opcional)',
                  ),
                  validator: null,
                ),
                if (puedeEscribir) ...[
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _guardando ? null : _guardar,
                    child: Text(_esEdicion ? 'Guardar cambios' : 'Crear registro'),
                  ),
                ],
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
    final item = Aeropuerto(
      id: widget.id,
      nombre: _nombreCtrl.text.trim(),
      codigoIata: _codigoIataCtrl.text.trim(),
      ciudad: _ciudadCtrl.text.trim(),
      pais: _paisCtrl.text.trim(),
      latitud: double.tryParse(_latitudCtrl.text.trim())!,
      longitud: double.tryParse(_longitudCtrl.text.trim())!,
      zonaHoraria: _zonaHorariaCtrl.text.trim(),
      fotoUrl: _fotoUrlCtrl.text.trim().isEmpty ? null : _fotoUrlCtrl.text.trim(),
    );

    final provider = context.read<AeropuertoProvider>();
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
