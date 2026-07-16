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
import '../../../core/utils/formatters.dart';
import '../../../core/utils/precios.dart';

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
  Set<String> _asientosElegidos = {};
  String? _clase = 'economica';
  String _estado = 'pendiente';

  int _adultos = 1;
  int _ninos = 0;
  int _bebes = 0;
  static const _maxPasajerosTotal = 9;

  List<String> _asientosOcupados = [];
  bool _cargandoAsientos = false;
  int _capacidadAeronave = 150;
  Set<String> _asientosOriginales = {};

  bool get _esEdicion => widget.id != null;

  /// Cuántos asientos hacen falta: uno por adulto y por niño — los bebés
  /// viajan en brazos y no ocupan asiento propio.
  int get _asientosRequeridos => _adultos + _ninos;

  String _resumenPasajeros() {
    final partes = <String>['$_adultos ${_adultos == 1 ? 'adulto' : 'adultos'}'];
    if (_ninos > 0) partes.add('$_ninos ${_ninos == 1 ? 'niño' : 'niños'}');
    if (_bebes > 0) partes.add('$_bebes ${_bebes == 1 ? 'bebé' : 'bebés'}');
    return partes.join(', ');
  }

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
        _asientosElegidos = e.asientos.toSet();
        _asientosOriginales = e.asientos.toSet();
        _clase = e.clase;
        _estado = e.estado;
        _adultos = e.pasajerosAdultos;
        _ninos = e.pasajerosNinos;
        _bebes = e.pasajerosBebes;
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

  /// Clase a la que pertenece un asiento (ej. "12A") según los asientos de
  /// primera/ejecutiva que el admin asignó al vuelo. Si el vuelo no tiene
  /// ningún asiento asignado a ninguna clase, no hay restricción real y se
  /// considera que cualquier asiento es válido para cualquier clase.
  String? _claseDeAsiento(String codigo) {
    final v = _vueloInfo;
    if (v == null || (v.asientosPrimera.isEmpty && v.asientosEjecutiva.isEmpty)) return null;
    final normalizado = codigo.trim().toUpperCase();
    if (v.asientosPrimera.contains(normalizado)) return 'primera';
    if (v.asientosEjecutiva.contains(normalizado)) return 'ejecutiva';
    return 'economica';
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

  /// Alterna la selección de un asiento en el mapa: lo quita si ya estaba
  /// elegido, lo agrega si todavía falta cubrir gente del grupo, o avisa
  /// si ya se completó el cupo (adultos + niños) y hay que soltar uno
  /// antes de elegir otro.
  void _alternarAsiento(String codigo) {
    if (_asientosElegidos.contains(codigo)) {
      setState(() => _asientosElegidos = {..._asientosElegidos}..remove(codigo));
      return;
    }
    if (_asientosElegidos.length >= _asientosRequeridos) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ya elegiste los $_asientosRequeridos asientos del grupo. Quita uno antes de elegir otro.')),
      );
      return;
    }
    setState(() => _asientosElegidos = {..._asientosElegidos, codigo});
  }

  /// Abre [builder] como una hoja deslizable desde abajo, con animación
  /// simétrica de entrada Y salida (320ms, easeOutCubic/easeInCubic). Se
  /// usa Navigator.push con un PageRouteBuilder en vez de
  /// showModalBottomSheet/showGeneralDialog porque esos widgets no
  /// exponen una reverseTransitionDuration propia — su cierre usa una
  /// duración por defecto tan corta que la animación casi no se alcanza
  /// a ver.
  Future<T?> _hojaAnimada<T>(WidgetBuilder builder) {
    return Navigator.of(context).push<T>(
      PageRouteBuilder<T>(
        opaque: false,
        barrierDismissible: true,
        barrierColor: Colors.black54,
        barrierLabel: 'Cerrar',
        transitionDuration: const Duration(milliseconds: 320),
        reverseTransitionDuration: const Duration(milliseconds: 320),
        pageBuilder: (context, animation, secondaryAnimation) => builder(context),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final curva = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic, reverseCurve: Curves.easeInCubic);
          return SlideTransition(
            position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero).animate(curva),
            child: child,
          );
        },
      ),
    );
  }

  /// Envoltorio visual compartido por todas las hojas deslizables del
  /// formulario (fondo, esquinas redondeadas arriba, padding, safe area).
  Widget _hojaContenedor(Widget child) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Material(
        color: AppColors.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            child: child,
          ),
        ),
      ),
    );
  }

  static const _opcionesClase = [
    (valor: 'economica', etiqueta: 'Económica', subtitulo: 'La opción más económica'),
    (valor: 'ejecutiva', etiqueta: 'Ejecutiva', subtitulo: 'Más espacio y comodidad'),
    (valor: 'primera', etiqueta: 'Primera clase', subtitulo: 'La mejor experiencia de vuelo'),
  ];

  String _etiquetaClase(String? valor) {
    for (final op in _opcionesClase) {
      if (op.valor == valor) return op.etiqueta;
    }
    return 'Elegir clase';
  }

  Future<void> _elegirClase() async {
    final elegido = await _hojaAnimada<String>((context) {
      return _hojaContenedor(
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Expanded(child: Text('Elegir clase', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17))),
                IconButton(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.close)),
              ],
            ),
            const Divider(height: 1, color: AppColors.surfaceVariant),
            ..._opcionesClase.map((op) {
              final seleccionado = op.valor == _clase;
              return Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => Navigator.of(context).pop(op.valor),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                op.etiqueta,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                  color: seleccionado ? AppColors.primary : AppColors.textPrimary,
                                ),
                              ),
                              Text(op.subtitulo, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                            ],
                          ),
                        ),
                        if (seleccionado) const Icon(Icons.check_circle, color: AppColors.primary),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      );
    });

    if (elegido == null || elegido == _clase) return;
    setState(() {
      _clase = elegido;
      // Los asientos ya elegidos que no correspondan a la nueva clase se
      // sueltan, para forzar a elegir otros válidos.
      _asientosElegidos.removeWhere((codigo) {
        final claseAsiento = _claseDeAsiento(codigo);
        return claseAsiento != null && claseAsiento != elegido;
      });
    });
  }

  Future<void> _elegirPasajeros() async {
    int adultos = _adultos;
    int ninos = _ninos;
    int bebes = _bebes;

    Widget fila({
      required String titulo,
      required String subtitulo,
      required int valor,
      required int minimo,
      required VoidCallback? onMenos,
      required VoidCallback? onMas,
    }) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(titulo, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                  Text(subtitulo, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                ],
              ),
            ),
            IconButton(
              onPressed: onMenos,
              icon: Icon(Icons.remove_circle_outline, color: onMenos != null ? AppColors.primary : AppColors.textSecondary.withValues(alpha: 0.3)),
            ),
            SizedBox(width: 22, child: Text('$valor', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
            IconButton(
              onPressed: onMas,
              icon: Icon(Icons.add_circle_outline, color: onMas != null ? AppColors.primary : AppColors.textSecondary.withValues(alpha: 0.3)),
            ),
          ],
        ),
      );
    }

    await _hojaAnimada<void>((context) {
      return StatefulBuilder(
        builder: (context, setModalState) {
          final total = adultos + ninos + bebes;
          return _hojaContenedor(
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    const Expanded(child: Text('Agregar pasajeros', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17))),
                    IconButton(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.close)),
                  ],
                ),
                const Divider(height: 1, color: AppColors.surfaceVariant),
                fila(
                  titulo: 'Adulto',
                  subtitulo: '12 años o más',
                  valor: adultos,
                  minimo: 1,
                  onMenos: adultos > 1 ? () => setModalState(() => adultos--) : null,
                  onMas: total < _maxPasajerosTotal ? () => setModalState(() => adultos++) : null,
                ),
                fila(
                  titulo: 'Niño',
                  subtitulo: 'De 2 a 11 años',
                  valor: ninos,
                  minimo: 0,
                  onMenos: ninos > 0 ? () => setModalState(() => ninos--) : null,
                  onMas: total < _maxPasajerosTotal ? () => setModalState(() => ninos++) : null,
                ),
                fila(
                  titulo: 'Bebé',
                  subtitulo: 'Menos de 2 años · no ocupa asiento',
                  valor: bebes,
                  minimo: 0,
                  onMenos: bebes > 0 ? () => setModalState(() => bebes--) : null,
                  onMas: total < _maxPasajerosTotal ? () => setModalState(() => bebes++) : null,
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      final requeridos = adultos + ninos;
                      setState(() {
                        _adultos = adultos;
                        _ninos = ninos;
                        _bebes = bebes;
                        // Si ahora hacen falta menos asientos que los que ya
                        // estaban elegidos, se recortan los sobrantes.
                        if (_asientosElegidos.length > requeridos) {
                          _asientosElegidos = _asientosElegidos.take(requeridos).toSet();
                        }
                      });
                      Navigator.of(context).pop();
                    },
                    child: const Text('Listo'),
                  ),
                ),
              ],
            ),
          );
        },
      );
    });
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
            if (v.precioBase > 0) ...[
              const SizedBox(height: 8),
              Text('Desde ${Formatters.precio(v.precioBase)}', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 15)),
            ],
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
                Text(
                  _reservaCreada!.asientos.length > 1
                      ? 'Asientos: ${_reservaCreada!.asientos.join(', ')}'
                      : 'Asiento: ${_reservaCreada!.numeroAsiento}',
                  style: const TextStyle(color: Colors.white70),
                ),
                Text('${_reservaCreada!.totalPasajeros} pasajero(s)', style: const TextStyle(color: Colors.white70)),
                if (_reservaCreada!.precio > 0) ...[
                  const SizedBox(height: 4),
                  Text('Total pagado: ${Formatters.precio(_reservaCreada!.precio)}', style: const TextStyle(color: Colors.white70)),
                ],
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
                    _asientosElegidos = {};
                    _asientosOriginales = {};
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
            InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: _elegirClase,
              child: InputDecorator(
                decoration: const InputDecoration(labelText: 'Clase', suffixIcon: Icon(Icons.expand_more)),
                child: Text(_etiquetaClase(_clase), style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 16),
            InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: _elegirPasajeros,
              child: InputDecorator(
                decoration: const InputDecoration(labelText: 'Pasajeros', suffixIcon: Icon(Icons.expand_more)),
                child: Text(_resumenPasajeros(), style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            if (_vueloInfo != null && _vueloInfo!.precioBase > 0) ...[
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.success.withValues(alpha: 0.35)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.sell_outlined, color: AppColors.success, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Precio estimado', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                          if (_asientosRequeridos > 1)
                            Text(
                              '${Formatters.precio(precioPorClase(_vueloInfo!.precioBase, _clase ?? 'economica'))} x $_asientosRequeridos pasajeros',
                              style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                            ),
                        ],
                      ),
                    ),
                    Text(
                      Formatters.precio(precioPorClase(_vueloInfo!.precioBase, _clase ?? 'economica') * _asientosRequeridos),
                      style: const TextStyle(color: AppColors.success, fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            Text(
              'Asientos (${_asientosElegidos.length}/$_asientosRequeridos)',
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 8),
            if (_vuelo == null)
              mensaje('Selecciona un vuelo para ver los asientos disponibles.')
            else
              SeatMap(
                capacidad: _capacidadAeronave,
                asientosOcupados: _asientosOcupados.toSet()..removeAll(_asientosOriginales),
                asientosSeleccionadosReserva: _asientosElegidos,
                cargando: _cargandoAsientos,
                asientosPrimera: _vueloInfo?.asientosPrimera ?? const {},
                asientosEjecutiva: _vueloInfo?.asientosEjecutiva ?? const {},
                clase: _clase ?? 'economica',
                onSeleccionar: _alternarAsiento,
              ),
            if (_asientosElegidos.isNotEmpty) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: (_asientosElegidos.toList()..sort()).map((codigo) {
                  return Chip(
                    label: Text(codigo, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                    side: BorderSide(color: AppColors.primary.withValues(alpha: 0.4)),
                    deleteIcon: const Icon(Icons.close, size: 16),
                    onDeleted: () => _alternarAsiento(codigo),
                  );
                }).toList(),
              ),
            ],
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
    if (_asientosElegidos.length != _asientosRequeridos) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Elige $_asientosRequeridos asiento(s) en el mapa (uno por adulto/niño del grupo).')),
      );
      return;
    }
    setState(() => _guardando = true);
    final item = Reserva(
      id: widget.id,
      vuelo: _vuelo!,
      pasajero: _pasajero!,
      numeroAsiento: (_asientosElegidos.toList()..sort()).join(','),
      clase: _clase!,
      estado: _estado,
      codigoReserva: '',
      reservadoEn: null,
      pasajerosAdultos: _adultos,
      pasajerosNinos: _ninos,
      pasajerosBebes: _bebes,
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
        setState(() => _reservaCreada = provider.items.first);
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
      numeroAsiento: (_asientosElegidos.toList()..sort()).join(','),
      clase: _clase!,
      estado: 'cancelada',
      codigoReserva: '',
      reservadoEn: null,
      pasajerosAdultos: _adultos,
      pasajerosNinos: _ninos,
      pasajerosBebes: _bebes,
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
