import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../domain/model/asignacion.dart';
import '../../providers/asignacion_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/vuelo_provider.dart';
import '../../providers/tripulante_provider.dart';
import '../../widgets/loading_overlay.dart';
import '../../../theme/app_colors.dart';

class AsignacionFormScreen extends StatefulWidget {
  final String? id;
  const AsignacionFormScreen({super.key, this.id});

  @override
  State<AsignacionFormScreen> createState() => _AsignacionFormScreenState();
}

class _AsignacionFormScreenState extends State<AsignacionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _cargado = false;
  bool _guardando = false;

  static const List<String> _rolesDisponibles = [
    'Piloto al mando',
    'Copiloto',
    'Jefe de cabina',
    'Auxiliar de vuelo',
  ];

  String? _vuelo;
  String? _tripulante;
  String? _rolAsignado;

  bool get _esEdicion => widget.id != null;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _inicializar());
  }

  Future<void> _inicializar() async {
    await context.read<VueloProvider>().cargar();
    await context.read<TripulanteProvider>().cargar();
    if (_esEdicion) {
      final provider = context.read<AsignacionProvider>();
      Asignacion? e;
      try {
        e = provider.items.firstWhere((it) => it.id == widget.id);
      } catch (_) {
        e = null;
      }
      if (e != null) {
        setState(() {
          _vuelo = e!.vuelo;
          _tripulante = e!.tripulante;
          _rolAsignado = e!.rolAsignado;
        });
      }
    }
    if (mounted) setState(() => _cargado = true);
  }

  /// Cuando se elige un tripulante, se sugiere su rol solo si el rol
  /// asignado todavia esta vacio (no pisa una eleccion ya hecha).
  String? _rolSugerido(String rolTripulante) {
    switch (rolTripulante) {
      case 'piloto':
        return 'Piloto al mando';
      case 'copiloto':
        return 'Copiloto';
      case 'jefe_cabina':
        return 'Jefe de cabina';
      case 'auxiliar':
        return 'Auxiliar de vuelo';
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final _opcVueloProvider = context.watch<VueloProvider>().items;
    final _opcTripulanteProvider = context.watch<TripulanteProvider>().items;
    final esAdmin = context.watch<AuthProvider>().usuario?.esAdmin ?? false;
    final puedeEscribir = context.watch<AuthProvider>().usuario?.puedeOperar ?? false;
    return Scaffold(
      appBar: AppBar(title: Text(_esEdicion ? 'Editar Asignación de Tripulación' : 'Nueva Asignación de Tripulación')),
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
                  value: _tripulante,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Tripulante'),
                  items: _opcTripulanteProvider.map((item) {
                    return DropdownMenuItem<String>(
                      value: item.id,
                      child: Text('${item.nombre} ${item.apellido}', overflow: TextOverflow.ellipsis),
                    );
                  }).toList(),
                  onChanged: !puedeEscribir ? null : (v) => setState(() {
                    _tripulante = v;
                    if (_rolAsignado == null && v != null) {
                      try {
                        final t = _opcTripulanteProvider.firstWhere((x) => x.id == v);
                        _rolAsignado = _rolSugerido(t.rol);
                      } catch (_) {}
                    }
                  }),
                  validator: (v) => v == null ? 'Selecciona tripulante' : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _rolAsignado,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Rol Asignado'),
                  items: {
                    ..._rolesDisponibles,
                    if (_rolAsignado != null) _rolAsignado!,
                  }.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
                  onChanged: !puedeEscribir ? null : (v) => setState(() => _rolAsignado = v),
                  validator: (v) => v == null || v.isEmpty ? 'Selecciona el rol asignado' : null,
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
    final item = Asignacion(
      id: widget.id,
      vuelo: _vuelo!,
      tripulante: _tripulante!,
      rolAsignado: _rolAsignado!,
    );

    final provider = context.read<AsignacionProvider>();
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
