import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../domain/model/user.dart';
import '../../../theme/app_colors.dart';
import '../../providers/aeropuerto_provider.dart';
import '../../providers/aerolinea_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/banner_promocional_provider.dart';
import '../../providers/incidente_provider.dart';
import '../../providers/notificacion_provider.dart';
import '../../providers/vuelo_provider.dart';
import '../../widgets/editor_imagen_dialog.dart';
import '../../widgets/vuelo_card.dart';

/// Pantalla principal de Home, compartida por todos los roles: mismo look
/// (encabezado degradado, buscador rápido, tarjetas redondeadas) en toda la
/// pantalla. Lo que cambia según el rol son las secciones de acción:
///
/// - Administrador: accesos rápidos para gestionar vuelos y una vista previa
///   de los próximos vuelos con acceso directo a editarlos.
/// - Pasajero / usuario normal: carrusel de ofertas (vacío por ahora, listo
///   para agregar imágenes), acceso a "Mis reservas" y un acceso directo
///   para consultar el estado de un vuelo.
class DashboardHomeScreen extends StatefulWidget {
  final VoidCallback? onVerTodosVuelos;
  final VoidCallback? onVerReservas;

  const DashboardHomeScreen({super.key, this.onVerTodosVuelos, this.onVerReservas});

  @override
  State<DashboardHomeScreen> createState() => _DashboardHomeScreenState();
}

class _DashboardHomeScreenState extends State<DashboardHomeScreen> {
  final _paginaOfertasCtrl = PageController();
  int _paginaOferta = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final esAdmin = context.read<AuthProvider>().usuario?.esAdmin ?? false;
      context.read<VueloProvider>().cargar();
      context.read<AeropuertoProvider>().cargar();
      context.read<AerolineaProvider>().cargar();
      context.read<BannerPromocionalProvider>().cargar();
      context.read<NotificacionProvider>().cargar();
      // Incidentes es información operativa interna: solo admin/operador
      // tiene permiso en el backend, así que un pasajero no debe pedirla.
      if (esAdmin) context.read<IncidenteProvider>().cargar();
    });
  }

  @override
  void dispose() {
    _paginaOfertasCtrl.dispose();
    super.dispose();
  }

  Future<void> _refrescar() async {
    final esAdmin = context.read<AuthProvider>().usuario?.esAdmin ?? false;
    await Future.wait([
      context.read<VueloProvider>().cargar(),
      context.read<AeropuertoProvider>().cargar(),
      context.read<AerolineaProvider>().cargar(),
      context.read<NotificacionProvider>().cargar(forzar: true),
      if (esAdmin) context.read<IncidenteProvider>().cargar(),
    ]);
  }

  Future<void> _editarBanner(String clave, {required String titulo}) async {
    final banners = context.read<BannerPromocionalProvider>();
    final nuevaUrl = await mostrarEditorImagen(
      context,
      titulo: titulo,
      actual: banners.urlPara(clave),
    );
    if (nuevaUrl == null || !mounted) return;
    final ok = await banners.guardar(clave, nuevaUrl);
    if (!mounted) return;
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(banners.error ?? 'No se pudo guardar la imagen')),
      );
    }
  }

  /// A diferencia de [_editarBanner] (solo imagen, para el encabezado),
  /// las tarjetas de oferta también llevan título/texto en negrita
  /// superpuestos abajo a la izquierda.
  Future<void> _editarOferta(String clave) async {
    final banners = context.read<BannerPromocionalProvider>();
    final resultado = await mostrarEditorContenido(
      context,
      dialogoTitulo: 'Oferta de vuelos',
      actualTitulo: banners.tituloPara(clave) ?? '',
      actualTexto: banners.textoPara(clave) ?? '',
      actualImagenUrl: banners.urlPara(clave) ?? '',
    );
    if (resultado == null || !mounted) return;
    final ok = await banners.guardarContenido(
      clave,
      titulo: resultado.titulo,
      texto: resultado.texto,
      imagenUrl: resultado.imagenUrl,
    );
    if (!mounted) return;
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(banners.error ?? 'No se pudo guardar la oferta')),
      );
    }
  }

  /// Claves de oferta que corresponde mostrar: el admin siempre ve las 3
  /// (con botón para agregar la que falte); un pasajero solo ve las que
  /// ya tienen imagen puesta por el admin.
  List<String> _clavesOferta(bool esAdmin, BannerPromocionalProvider banners) {
    const todas = ['oferta_1', 'oferta_2', 'oferta_3'];
    if (esAdmin) return todas;
    return todas.where((c) => banners.urlPara(c) != null).toList();
  }

  List<Widget> _seccionOfertas(bool esAdmin, BannerPromocionalProvider banners) {
    final claves = _clavesOferta(esAdmin, banners);
    if (claves.isEmpty) return const [];
    if (_paginaOferta >= claves.length) _paginaOferta = 0;
    return [
      const Text('Oferta de vuelos', style: TextStyle(color: AppColors.textPrimary, fontSize: 17, fontWeight: FontWeight.bold)),
      const SizedBox(height: 12),
      SizedBox(
        height: 150,
        child: PageView.builder(
          controller: _paginaOfertasCtrl,
          itemCount: claves.length,
          onPageChanged: (i) => setState(() => _paginaOferta = i),
          itemBuilder: (context, index) {
            final clave = claves[index];
            return Padding(
              padding: const EdgeInsets.only(right: 4),
              child: _TarjetaOferta(
                imagenUrl: banners.urlPara(clave),
                titulo: banners.tituloPara(clave),
                texto: banners.textoPara(clave),
                puedeEditar: esAdmin,
                onEditar: () => _editarOferta(clave),
              ),
            );
          },
        ),
      ),
      const SizedBox(height: 10),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(claves.length, (i) {
          final activo = i == _paginaOferta;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: activo ? 18 : 6,
            height: 6,
            decoration: BoxDecoration(
              color: activo ? AppColors.primary : AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(3),
            ),
          );
        }),
      ),
      const SizedBox(height: 28),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final vuelos = context.watch<VueloProvider>();
    final aeropuertos = context.watch<AeropuertoProvider>();
    final aerolineas = context.watch<AerolineaProvider>();
    final banners = context.watch<BannerPromocionalProvider>();
    final notificaciones = context.watch<NotificacionProvider>();

    String codigoAeropuerto(String? id) {
      if (id == null) return '?';
      try {
        return aeropuertos.items.firstWhere((a) => a.id == id).codigoIata;
      } catch (_) {
        return '?';
      }
    }

    String? ciudadAeropuerto(String? id) {
      if (id == null) return null;
      try {
        return aeropuertos.items.firstWhere((a) => a.id == id).ciudad;
      } catch (_) {
        return null;
      }
    }

    String nombreAerolinea(String? id) {
      if (id == null) return '';
      try {
        return aerolineas.items.firstWhere((a) => a.id == id).nombre;
      } catch (_) {
        return '';
      }
    }

    String fmtHora(DateTime d) {
      final hh = d.hour.toString().padLeft(2, '0');
      final mm = d.minute.toString().padLeft(2, '0');
      return '$hh:$mm';
    }

    final hoy = DateTime.now();
    final proximosVuelos = vuelos.items.where((v) => v.salidaProgramada.isAfter(hoy)).toList()
      ..sort((a, b) => a.salidaProgramada.compareTo(b.salidaProgramada));

    final esAdmin = auth.usuario?.esAdmin ?? false;
    final nombre = (auth.usuario?.nombreCompleto.isNotEmpty ?? false) ? auth.usuario!.nombreCompleto : 'viajero';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: _refrescar,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            _Encabezado(
              usuario: auth.usuario,
              esAdmin: esAdmin,
              imagenUrl: banners.urlPara('dashboard'),
              puedeEditar: esAdmin,
              onEditar: () => _editarBanner('dashboard', titulo: 'Imagen del encabezado'),
              notificacionesNoLeidas: notificaciones.noLeidas,
            ),
            Transform.translate(
              offset: const Offset(0, -28),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 90),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _BuscadorRapido(onTap: () => context.push('/vuelos/buscar')),
                    const SizedBox(height: 28),
                    ..._seccionOfertas(esAdmin, banners),
                    if (esAdmin) ...[
                      const Text('Accesos rápidos', style: TextStyle(color: AppColors.textPrimary, fontSize: 17, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      _TarjetaAccion(
                        icono: Icons.flight_outlined,
                        titulo: 'Gestionar vuelos',
                        subtitulo: 'Crea, edita y administra los vuelos programados.',
                        textoBoton: 'Ver',
                        onTap: widget.onVerTodosVuelos ?? () => context.push('/vuelos'),
                      ),
                      const SizedBox(height: 12),
                      _TarjetaAccion(
                        icono: Icons.add_circle_outline,
                        titulo: 'Nuevo vuelo',
                        subtitulo: 'Programa un vuelo nuevo con ruta, aeronave y horarios.',
                        textoBoton: 'Crear',
                        onTap: () => context.push('/vuelos/nuevo'),
                      ),
                      const SizedBox(height: 28),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Próximos vuelos', style: TextStyle(color: AppColors.textPrimary, fontSize: 17, fontWeight: FontWeight.bold)),
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(6),
                              onTap: widget.onVerTodosVuelos ?? () => context.push('/vuelos'),
                              child: const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                child: Text(
                                  'VER TODOS',
                                  style: TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (vuelos.cargando && vuelos.items.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 24),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      else if (proximosVuelos.isEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Center(
                            child: Text('No hay vuelos próximos', style: TextStyle(color: AppColors.textSecondary)),
                          ),
                        )
                      else
                        ...proximosVuelos.take(3).map(
                              (v) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: VueloCard(
                                  numeroVuelo: v.numeroVuelo,
                                  aerolineaNombre: nombreAerolinea(v.aerolinea),
                                  estado: v.estado,
                                  origenCodigo: codigoAeropuerto(v.origen),
                                  destinoCodigo: codigoAeropuerto(v.destino),
                                  origenCiudad: ciudadAeropuerto(v.origen),
                                  destinoCiudad: ciudadAeropuerto(v.destino),
                                  duracionMin: v.duracionMin,
                                  horaSalida: fmtHora(v.salidaProgramada),
                                  horaLlegada: fmtHora(v.llegadaProgramada),
                                  onTap: () => context.push('/vuelos/${v.id}'),
                                ),
                              ),
                            ),
                    ] else ...[
                      const Text('¿Ya tienes una reserva?', style: TextStyle(color: AppColors.textPrimary, fontSize: 17, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      _TarjetaAccion(
                        icono: Icons.confirmation_number_outlined,
                        titulo: 'Mis reservas',
                        subtitulo: 'Consulta el estado y los detalles de tus vuelos reservados.',
                        textoBoton: 'Ver',
                        onTap: widget.onVerReservas ?? () => context.push('/reservas'),
                      ),
                      const SizedBox(height: 28),
                      const Text('Consulta el estado de tu vuelo', style: TextStyle(color: AppColors.textPrimary, fontSize: 17, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      _BuscadorEstado(onBuscar: () => context.push('/vuelos/buscar')),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Encabezado extends StatelessWidget {
  final Usuario? usuario;
  final bool esAdmin;
  final String? imagenUrl;
  final bool puedeEditar;
  final VoidCallback onEditar;
  final int notificacionesNoLeidas;

  const _Encabezado({
    required this.usuario,
    required this.esAdmin,
    required this.imagenUrl,
    required this.puedeEditar,
    required this.onEditar,
    this.notificacionesNoLeidas = 0,
  });

  @override
  Widget build(BuildContext context) {
    final nombre = (usuario?.nombreCompleto.isNotEmpty ?? false) ? usuario!.nombreCompleto : 'Operador';
    final tieneImagen = imagenUrl != null && imagenUrl!.trim().isNotEmpty;

    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF17337A), Color(0xFF2E5CFF), Color(0xFF0A0A0F)],
        ),
      ),
      child: Stack(
        fit: StackFit.passthrough,
        children: [
          if (tieneImagen)
            Positioned.fill(
              child: Image.network(
                imagenUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),
          if (tieneImagen)
            const Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0x332E5CFF), Color(0x140A0A0F), Color(0xFF0A0A0F)],
                    stops: [0.0, 0.6, 1.0],
                  ),
                ),
              ),
            ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 60),
              child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.flight, color: Colors.white, size: 22),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'SkyOps',
                        style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    if (puedeEditar) ...[
                      Container(
                        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), shape: BoxShape.circle),
                        child: IconButton(
                          icon: const Icon(Icons.image_outlined, color: Colors.white, size: 20),
                          tooltip: 'Cambiar imagen de fondo',
                          onPressed: onEditar,
                        ),
                      ),
                      const SizedBox(width: 4),
                    ],
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), shape: BoxShape.circle),
                          child: IconButton(
                            icon: const Icon(Icons.notifications_outlined, color: Colors.white, size: 20),
                            onPressed: () => context.push('/notificaciones'),
                          ),
                        ),
                        if (notificacionesNoLeidas > 0)
                          Positioned(
                            top: 2,
                            right: 2,
                            child: IgnorePointer(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                                decoration: BoxDecoration(
                                  color: AppColors.error,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: const Color(0xFF17337A), width: 1.5),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  notificacionesNoLeidas > 9 ? '9+' : '$notificacionesNoLeidas',
                                  style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold, height: 1),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(width: 4),
                    Container(
                      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), shape: BoxShape.circle),
                      child: IconButton(
                        icon: const Icon(Icons.menu, color: Colors.white, size: 20),
                        tooltip: 'Menú',
                        onPressed: () => context.push('/menu'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                Text(
                  'Hola, $nombre',
                  style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2),
                Text(
                  esAdmin ? 'Gestiona las operaciones de hoy' : '¿A dónde quieres viajar?',
                  style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BuscadorRapido extends StatelessWidget {
  final VoidCallback onTap;
  const _BuscadorRapido({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(28),
      elevation: 4,
      shadowColor: Colors.black45,
      child: InkWell(
        borderRadius: BorderRadius.circular(28),
        onTap: onTap,
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          child: Row(
            children: [
              Icon(Icons.search, color: AppColors.textSecondary),
              SizedBox(width: 12),
              Text('Buscar un vuelo', style: TextStyle(color: AppColors.textSecondary, fontSize: 15)),
            ],
          ),
        ),
      ),
    );
  }
}

/// Una tarjeta del carrusel "Oferta de vuelos". Si tiene [imagenUrl] la
/// muestra de fondo (con un lápiz para que el admin la cambie); si no,
/// solo el admin ve un botón para agregarla — un pasajero nunca ve esta
/// tarjeta vacía (se filtra antes, en `_clavesOferta`).
class _TarjetaOferta extends StatelessWidget {
  final String? imagenUrl;
  final String? titulo;
  final String? texto;
  final bool puedeEditar;
  final VoidCallback onEditar;

  const _TarjetaOferta({
    required this.imagenUrl,
    this.titulo,
    this.texto,
    required this.puedeEditar,
    required this.onEditar,
  });

  @override
  Widget build(BuildContext context) {
    final tieneImagen = imagenUrl != null && imagenUrl!.trim().isNotEmpty;
    final tieneTitulo = titulo != null && titulo!.trim().isNotEmpty;
    final tieneTexto = texto != null && texto!.trim().isNotEmpty;
    final tieneOverlay = tieneTitulo || tieneTexto;

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: puedeEditar ? onEditar : null,
        child: Container(
          decoration: BoxDecoration(border: Border.all(color: AppColors.surfaceVariant)),
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (tieneImagen)
                Image.network(
                  imagenUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(color: AppColors.surface),
                )
              else
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        puedeEditar ? Icons.add_photo_alternate_outlined : Icons.image_outlined,
                        color: AppColors.textSecondary.withValues(alpha: 0.5),
                        size: 32,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        puedeEditar ? 'Agregar imagen' : 'Espacio para promoción',
                        style: TextStyle(color: AppColors.textSecondary.withValues(alpha: 0.7), fontSize: 12),
                      ),
                    ],
                  ),
                ),
              if (tieneImagen && tieneOverlay)
                const Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black87],
                        stops: [0.35, 1.0],
                      ),
                    ),
                  ),
                ),
              if (tieneImagen && tieneOverlay)
                Positioned(
                  left: 12,
                  right: 12,
                  bottom: 10,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (tieneTitulo)
                        Text(
                          titulo!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            height: 1.2,
                          ),
                        ),
                      if (tieneTexto) ...[
                        const SizedBox(height: 2),
                        Text(
                          texto!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 11),
                        ),
                      ],
                    ],
                  ),
                ),
              if (puedeEditar && tieneImagen)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Material(
                    color: Colors.black.withValues(alpha: 0.4),
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: onEditar,
                      child: const Padding(
                        padding: EdgeInsets.all(7),
                        child: Icon(Icons.edit, size: 16, color: Colors.white),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TarjetaAccion extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final String subtitulo;
  final String textoBoton;
  final VoidCallback onTap;

  const _TarjetaAccion({
    required this.icono,
    required this.titulo,
    required this.subtitulo,
    required this.textoBoton,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.surfaceVariant),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icono, color: AppColors.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(titulo, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 2),
                Text(subtitulo, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: onTap,
            style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10)),
            child: Text(textoBoton),
          ),
        ],
      ),
    );
  }
}

class _BuscadorEstado extends StatelessWidget {
  final VoidCallback onBuscar;
  const _BuscadorEstado({required this.onBuscar});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.surfaceVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: onBuscar,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.flight_takeoff, size: 18, color: AppColors.textSecondary),
                  SizedBox(width: 10),
                  Text('Origen', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: onBuscar,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.flight_land, size: 18, color: AppColors.textSecondary),
                  SizedBox(width: 10),
                  Text('Destino', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: onBuscar,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.confirmation_number_outlined, size: 18, color: AppColors.textSecondary),
                  SizedBox(width: 10),
                  Text('Número o código de vuelo', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onBuscar,
            child: const Text('Buscar'),
          ),
        ],
      ),
    );
  }
}
