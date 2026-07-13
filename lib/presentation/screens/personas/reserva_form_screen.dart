import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../domain/model/reserva.dart';
import '../../../domain/model/vuelo.dart';
import '../../providers/reserva_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/vuelo_provider.dart';
import '../../providers/pasajero_provider.dart';
import '../../providers/aeropuerto_provider.dart';
import '../../providers/aerolinea_provider.dart';
import '../../providers/aeronave_provider.dart';
import '../../widgets/loading_overlay.dart';
import '../../widgets/seat_map.dart';
import '../../../theme/app_colors.dart';

/// Formulario de Reserva.
///
/// - Administrador: puede reservar a nombre de cualquier pasajero, para
///   cualquier vuelo, y cambiar el estado libremente (comportamiento CRUD
///   completo, igual que el resto de módulos de gestión).
/// - Usuario normal: solo puede reservar a su propio nombre (el pasajero se
///   autoselecciona a partir de su cuenta; el backend además valida esto de
///   forma independiente). Si llega con un vuelo preseleccionado (desde la
///   pantalla de búsqueda), el vuelo se muestra como resumen de solo lectura
///   en vez de un dropdown con todos los vuelos.
class ReservaFormScreen extends StatefulWidget {
  final String? id;
  final Vuelo? vueloPreseleccionado;
  const ReservaFormScreen({super.key, this.id, this.vueloPreseleccionado});

  @override
  State<ReservaFormScreen> createState() => _ReservaFormScreenState();
}

class _ReservaFormScreenState extends State<ReservaFormScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _cargado = false;
  bool _guardando = false;
  String? _errorCarga;
  Reserva? _reservaCreada;

  String? _vuelo;
  Vuelo? _vueloInfo;
  String? _pasajero;
  String? _pasajeroNombre;
  final _numeroAsientoCtrl = TextEditingController();
  String? _clase = 'economica';
  String _estado = 'pendiente';

  List<String> _asientosOcupados = [];
  bool _cargandoAsientos = false;
  int _capacidadAeronave = 150;
  String? _asientoOriginal;

  bool get _esEdicion => widget.id != null;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _inicializar());
  }

  Future<void> _inicializar() async {
    final esAdmin = context.read<AuthProvider>().usuario?.esAdmin ?? false;

    await context.read<VueloProvider>().cargar();
    await context.read<PasajeroProvider>().cargar();
    await context.read<AeronaveProvider>().cargar();
    if (!mounted) return;

    if (_esEdicion) {
      final provider = context.read<ReservaProvider>();
      Reserva? e;
      try {
        e = provider.items.firstWhere((it) => it.id == widget.id);
      } catch (_) {
        e = null;
      }
      if (e != null) {
        _vuelo = e.vuelo;
        _pasajero = e.pasajero;
        _numeroAsientoCtrl.text = e.numeroAsiento;
        _asientoOriginal = e.numeroAsiento;
        _clase = e.clase;
        _estado = e.estado;
      }
    } else if (widget.vueloPreseleccionado != null) {
      _vuelo = widget.vueloPreseleccionado!.id;
      _vueloInfo = widget.vueloPreseleccionado;
    }

    if (_vuelo != null && _vueloInfo == null) {
      try {
        _vueloInfo = context.read<VueloProvider>().items.firstWhere((v) => v.id == _vuelo);
      } catch (_) {}
    }

    if (!esAdmin) {
      final misPasajeros = context.read<PasajeroProvider>().items;
      if (misPasajeros.isNotEmpty) {
        _pasajero = misPasajeros.first.id;
        _pasajeroNombre = '${misPasajeros.first.nombre} ${misPasajeros.first.apellido}';
      } else if (!_esEdicion) {
        _errorCarga = 'Todavía no tienes un perfil de pasajero asociado a tu cuenta. '
            'Pide a un administrador que lo cree con tu mismo correo para poder reservar.';
      }
    } else {
      try {
        final p = context.read<PasajeroProvider>().items.firstWhere((x) => x.id == _pasajero);
        _pasajeroNombre = '${p.nombre} ${p.apellido}';
      } catch (_) {}
    }

    _actualizarCapacidad();
    if (_vuelo != null) await _cargarAsientos(_vuelo!);

    if (mounted) setState(() => _cargado = true);
  }

  void _actualizarCapacidad() {
    final aeronaveId = _vueloInfo?.aeronave;
    if (aeronaveId == null) {
      _capacidadAeronave = 150;
      return;
    }
    try {
      _capacidadAeronave = context.read<AeronaveProvider>().items.firstWhere((a) => a.id == aeronaveId).capacidad;
    } catch (_) {
      _capacidadAeronave = 150;
    }
  }

  Future<void> _cargarAsientos(String vueloId) async {
    setState(() => _cargandoAsientos = true);
    final lista = await context.read<VueloProvider>().asientosOcupados(vueloId);
    if (!mounted) return;
    setState(() {
      _asientosOcupados = lista;
      _cargandoAsientos = false;
    });
  }

  @override
  void dispose() {
    _numeroAsientoCtrl.dispose();
    super.dispose();
  }

  String _fmt(DateTime d) {
    final hh = d.hour.toString().padLeft(2, '0');
    final mm = d.minute.toString().padLeft(2, '0');
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year} $hh:$mm';
  }

  @override
  Widget build(BuildContext context) {
    final esAdmin = context.watch<AuthProvider>().usuario?.esAdmin ?? false;
    final opcVuelo = context.watch<VueloProvider>().items;
    final opcPasajero = context.watch<PasajeroProvider>().items;
    final opcAeropuerto = context.watch<AeropuertoProvider>().items;
    final opcAerolinea = context.watch<AerolineaProvider>().items;

    String codigoAeropuerto(String? id) {
      if (id == null) return '?';
      try {
        return opcAeropuerto.firstWhere((a) => a.id == id).codigoIata;
      } catch (_) {
        return '?';
      }
    }

    String nombreAerolinea(String? id) {
      if (id == null) return '';
      try {
        return opcAerolinea.firstWhere((a) => a.id == id).nombre;
      } catch (_) {
        return '';
      }
    }

    Widget resumenVuelo(Vuelo v) {
      return Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Vuelo ${v.numeroVuelo}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 4),
            Text(nombreAerolinea(v.aerolinea), style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 8),
            Text('${codigoAeropuerto(v.origen)}   →   ${codigoAeropuerto(v.destino)}', style: const TextStyle(fontSize: 15)),
            const SizedBox(height: 4),
            Text('Sale: ${_fmt(v.salidaProgramada)}   ·   Llega: ${_fmt(v.llegadaProgramada)}', style: const TextStyle(color: Colors.white70)),
          ],
        ),
      );
    }

    Widget mensaje(String msg, {IconData icono = Icons.info_outline, Color color = Colors.amber}) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icono, color: color),
            const SizedBox(width: 10),
            Expanded(child: Text(msg)),
          ],
        ),
      );
    }

    Widget cuerpo;
    if (_reservaCreada != null) {
      cuerpo = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                const Icon(Icons.check_circle, color: Colors.greenAccent, size: 40),
                const SizedBox(height: 10),
                const Text('¡Reserva confirmada!', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text('Código: ${_reservaCreada!.codigoReserva}', style: const TextStyle(fontSize: 16)),
                Text('Asiento: ${_reservaCreada!.numeroAsiento}', style: const TextStyle(color: Colors.white70)),
              ],
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => context.pop(),
            child: const Text('Volver'),
          ),
        ],
      );
    } else if (_errorCarga != null) {
      cuerpo = mensaje(_errorCarga!, icono: Icons.lock_outline);
    } else {
      cuerpo = Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_vueloInfo != null)
              resumenVuelo(_vueloInfo!)
            else if (esAdmin)
              DropdownButtonFormField<String>(
                value: _vuelo,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Vuelo'),
                items: opcVuelo.map((item) {
                  return DropdownMenuItem<String>(
                    value: item.id,
                    child: Text(
                      '${item.numeroVuelo} · ${codigoAeropuerto(item.origen)} → ${codigoAeropuerto(item.destino)}',
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
                onChanged: (v) {
                  setState(() {
                    _vuelo = v;
                    _numeroAsientoCtrl.text = '';
                    _asientoOriginal = null;
                    _asientosOcupados = [];
                    try {
                      _vueloInfo = opcVuelo.firstWhere((x) => x.id == v);
                    } catch (_) {
                      _vueloInfo = null;
                    }
                    _actualizarCapacidad();
                  });
                  if (v != null) _cargarAsientos(v);
                },
                validator: (v) => v == null ? 'Selecciona vuelo' : null,
              )
            else
              mensaje('No se seleccionó ningún vuelo. Vuelve a la búsqueda de vuelos.'),
            const SizedBox(height: 16),
            if (esAdmin)
              DropdownButtonFormField<String>(
                value: _pasajero,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Pasajero'),
                items: opcPasajero.map((item) {
                  return DropdownMenuItem<String>(
                    value: item.id,
                    child: Text('${item.nombre} ${item.apellido}', overflow: TextOverflow.ellipsis),
                  );
                }).toList(),
                onChanged: (v) => setState(() => _pasajero = v),
                validator: (v) => v == null ? 'Selecciona pasajero' : null,
              )
            else
              InputDecorator(
                decoration: const InputDecoration(labelText: 'Pasajero'),
                child: Text(_pasajeroNombre ?? '—'),
              ),
            const SizedBox(height: 16),
            const Text('Número de asiento', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            const SizedBox(height: 8),
            if (_vuelo == null)
              mensaje('Selecciona un vuelo para ver los asientos disponibles.')
            else
              SeatMap(
                capacidad: _capacidadAeronave,
                asientosOcupados: _asientosOcupados.toSet()..remove(_asientoOriginal),
                asientoSeleccionado: _numeroAsientoCtrl.text.isEmpty ? null : _numeroAsientoCtrl.text,
                cargando: _cargandoAsientos,
                onSeleccionar: (codigo) => setState(() => _numeroAsientoCtrl.text = codigo),
              ),
            if (_numeroAsientoCtrl.text.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text('Asiento elegido: ${_numeroAsientoCtrl.text}', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
            ],
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _clase,
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'Clase'),
              items: const [
                DropdownMenuItem(value: 'economica', child: Text('Económica')),
                DropdownMenuItem(value: 'ejecutiva', child: Text('Ejecutiva')),
                DropdownMenuItem(value: 'primera', child: Text('Primera clase')),
              ],
              onChanged: (v) => setState(() => _clase = v),
              validator: (v) => v == null ? 'Selecciona clase' : null,
            ),
            if (esAdmin) ...[
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _estado,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Estado'),
                items: const [
                  DropdownMenuItem(value: 'confirmada', child: Text('Confirmada')),
                  DropdownMenuItem(value: 'pendiente', child: Text('Pendiente')),
                  DropdownMenuItem(value: 'cancelada', child: Text('Cancelada')),
                  DropdownMenuItem(value: 'abordada', child: Text('Abordada')),
                ],
                onChanged: (v) => setState(() => _estado = v ?? _estado),
              ),
            ],
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _guardando ? null : _guardar,
              child: Text(_esEdicion ? 'Guardar cambios' : 'Confirmar reserva'),
            ),
            if (_esEdicion && !esAdmin && _estado != 'cancelada') ...[
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: _guardando ? null : _cancelar,
                style: OutlinedButton.styleFrom(foregroundColor: Colors.redAccent),
                child: const Text('Cancelar reserva'),
              ),
            ],
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(_esEdicion ? 'Editar reserva' : 'Nueva reserva')),
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
            child: cuerpo,
          ),
        ),
      ),
    );
  }

  Future<void> _guardar() async {
    if (_errorCarga != null) return;
    if (!_formKey.currentState!.validate()) return;
    if (_vuelo == null || _pasajero == null) return;
    if (_numeroAsientoCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Elige un asiento en el mapa')),
      );
      return;
    }
    setState(() => _guardando = true);
    final item = Reserva(
      id: widget.id,
      vuelo: _vuelo!,
      pasajero: _pasajero!,
      numeroAsiento: _numeroAsientoCtrl.text.trim(),
      clase: _clase!,
      estado: _estado,
      codigoReserva: '',
      reservadoEn: null,
    );

    final provider = context.read<ReservaProvider>();
    final ok = _esEdicion
        ? await provider.actualizar(widget.id!, item)
        : await provider.crear(item);

    if (!mounted) return;
    setState(() => _guardando = false);
    if (ok) {
      if (_esEdicion) {
        context.pop();
      } else {
        setState(() => _reservaCreada = provider.items.last);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.error ?? 'No se pudo guardar')),
      );
    }
  }

  Future<void> _cancelar() async {
    if (widget.id == null || _vuelo == null || _pasajero == null) return;
    setState(() => _guardando = true);
    final item = Reserva(
      id: widget.id,
      vuelo: _vuelo!,
      pasajero: _pasajero!,
      numeroAsiento: _numeroAsientoCtrl.text.trim(),
      clase: _clase!,
      estado: 'cancelada',
      codigoReserva: '',
      reservadoEn: null,
    );
    final provider = context.read<ReservaProvider>();
    final ok = await provider.actualizar(widget.id!, item);
    if (!mounted) return;
    setState(() => _guardando = false);
    if (ok) {
      context.pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.error ?? 'No se pudo cancelar')),
      );
    }
  }
}
