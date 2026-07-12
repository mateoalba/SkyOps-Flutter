import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/vuelo_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/aeropuerto_provider.dart';
import '../../providers/aerolinea_provider.dart';
import '../../providers/aeronave_provider.dart';
import '../../providers/puerta_provider.dart';
import '../../providers/banner_promocional_provider.dart';
import '../../widgets/confirm_delete_dialog.dart';
import '../../widgets/loading_overlay.dart';
import '../../widgets/vuelo_card.dart';
import '../../widgets/search_field.dart';
import '../../widgets/editor_imagen_dialog.dart';
import '../../../theme/app_colors.dart';

class VueloListScreen extends StatefulWidget {
  const VueloListScreen({super.key});

  @override
  State<VueloListScreen> createState() => _VueloListScreenState();
}

class _VueloListScreenState extends State<VueloListScreen> {
  String _busqueda = '';
  String _filtroEstado = 'todos';

  static const _filtros = [
    (valor: 'todos', etiqueta: 'Todos'),
    (valor: 'programado', etiqueta: 'Programados'),
    (valor: 'embarcando', etiqueta: 'Embarcando'),
    (valor: 'despegado', etiqueta: 'Despegados'),
    (valor: 'aterrizado', etiqueta: 'Aterrizados'),
    (valor: 'retrasado', etiqueta: 'Retrasados'),
    (valor: 'cancelado', etiqueta: 'Cancelados'),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VueloProvider>().cargar();
      context.read<AeropuertoProvider>().cargar();
      context.read<AerolineaProvider>().cargar();
      context.read<AeronaveProvider>().cargar();
      context.read<PuertaProvider>().cargar();
      context.read<BannerPromocionalProvider>().cargar();
    });
  }

  Future<void> _editarBanner(BuildContext context) async {
    final banners = context.read<BannerPromocionalProvider>();
    final nuevaUrl = await mostrarEditorImagen(
      context,
      titulo: 'Imagen del encabezado',
      actual: banners.urlPara('vuelos'),
    );
    if (nuevaUrl == null || !context.mounted) return;
    final ok = await banners.guardar('vuelos', nuevaUrl);
    if (!context.mounted) return;
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(banners.error ?? 'No se pudo guardar la imagen')),
      );
    }
  }

  Future<void> _eliminar(BuildContext context, String id, String nombre) async {
    final confirmado = await confirmarEliminacion(context, nombre: nombre);
    if (!confirmado || !context.mounted) return;
    final provider = context.read<VueloProvider>();
    final ok = await provider.eliminar(id);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(ok ? 'Registro eliminado' : (provider.error ?? 'No se pudo eliminar'))),
    );
  }

  String _fmtHora(DateTime d) {
    final hh = d.hour.toString().padLeft(2, '0');
    final mm = d.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<VueloProvider>();
    final auth = context.watch<AuthProvider>();
    final opcAeropuerto = context.watch<AeropuertoProvider>().items;
    final opcAerolinea = context.watch<AerolineaProvider>().items;
    final opcAeronave = context.watch<AeronaveProvider>().items;
    final opcPuerta = context.watch<PuertaProvider>().items;
    final banners = context.watch<BannerPromocionalProvider>();
    final esAdmin = auth.usuario?.esAdmin ?? false;
    final puedeEscribir = esAdmin;
    final imagenBanner = banners.urlPara('vuelos');

    String codigoAeropuerto(String? id) {
      if (id == null) return '?';
      try {
        return opcAeropuerto.firstWhere((a) => a.id == id).codigoIata;
      } catch (_) {
        return '?';
      }
    }

    String? ciudadAeropuerto(String? id) {
      if (id == null) return null;
      try {
        return opcAeropuerto.firstWhere((a) => a.id == id).ciudad;
      } catch (_) {
        return null;
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

    String? matriculaAeronave(String? id) {
      if (id == null) return null;
      try {
        return opcAeronave.firstWhere((a) => a.id == id).matricula;
      } catch (_) {
        return null;
      }
    }

    String? codigoPuerta(String? id) {
      if (id == null) return null;
      try {
        return opcPuerta.firstWhere((p) => p.id == id).codigo;
      } catch (_) {
        return null;
      }
    }

    final items = provider.items.where((item) {
      if (_filtroEstado != 'todos' && item.estado != _filtroEstado) return false;
      if (_busqueda.trim().isEmpty) return true;
      final q = _busqueda.trim().toLowerCase();
      return item.numeroVuelo.toString().toLowerCase().contains(q) ||
          item.estado.toString().toLowerCase().contains(q) ||
          codigoAeropuerto(item.origen).toLowerCase().contains(q) ||
          codigoAeropuerto(item.destino).toLowerCase().contains(q) ||
          nombreAerolinea(item.aerolinea).toLowerCase().contains(q);
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: puedeEscribir
          ? FloatingActionButton(
              heroTag: 'vuelos_nuevo_fab',
              onPressed: () => context.push('/vuelos/nuevo'),
              child: const Icon(Icons.add),
            )
          : null,
      body: LoadingOverlay(
        visible: provider.cargando,
        child: RefreshIndicator(
          onRefresh: () => context.read<VueloProvider>().cargar(forzar: true),
          child: CustomScrollView(
            slivers: [
              // Banner con la imagen que haya puesto un admin (o un
              // degradado con ícono decorativo mientras no haya ninguna).
              // Va dentro del scroll para que se oculte al deslizar, igual
              // que el encabezado de la pantalla de Inicio.
              SliverToBoxAdapter(
                child: Container(
                  width: double.infinity,
                  clipBehavior: Clip.hardEdge,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF17337A), Color(0xFF2E5CFF), Color(0xFF0A0A0F)],
                    ),
                  ),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      if (imagenBanner != null)
                        Positioned.fill(
                          child: Image.network(
                            imagenBanner,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                          ),
                        )
                      else
                        Positioned(
                          right: -16,
                          bottom: -18,
                          child: Icon(Icons.flight, size: 130, color: Colors.white.withValues(alpha: 0.10)),
                        ),
                      if (imagenBanner != null)
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
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 64),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.flight_takeoff, color: Colors.white, size: 20),
                                  const SizedBox(width: 8),
                                  const Expanded(
                                    child: Text('Vuelos', style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
                                  ),
                                  if (esAdmin)
                                    Material(
                                      color: Colors.white.withValues(alpha: 0.15),
                                      shape: const CircleBorder(),
                                      child: InkWell(
                                        customBorder: const CircleBorder(),
                                        onTap: () => _editarBanner(context),
                                        child: const Padding(
                                          padding: EdgeInsets.all(8),
                                          child: Icon(Icons.image_outlined, color: Colors.white, size: 18),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: SearchField(
                  hintText: 'Buscar vuelo o aeronave...',
                  onChanged: (v) => setState(() => _busqueda = v),
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 40,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    itemCount: _filtros.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final f = _filtros[index];
                      final seleccionado = f.valor == _filtroEstado;
                      return ChoiceChip(
                        label: Text(f.etiqueta),
                        selected: seleccionado,
                        onSelected: (_) => setState(() => _filtroEstado = f.valor),
                        backgroundColor: AppColors.surface,
                        selectedColor: AppColors.primary,
                        side: BorderSide(color: seleccionado ? AppColors.primary : AppColors.surfaceVariant),
                        labelStyle: TextStyle(
                          color: seleccionado ? Colors.white : AppColors.textSecondary,
                          fontWeight: seleccionado ? FontWeight.bold : FontWeight.normal,
                          fontSize: 12,
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 4)),
              if (items.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 80),
                    child: Center(
                      child: Text(
                        provider.estado == EstadoCargaVuelo.error
                            ? (provider.error ?? 'No se pudo cargar. Verifica tu sesión/permisos.')
                            : (_busqueda.isEmpty && _filtroEstado == 'todos' ? 'No hay registros todavía' : 'Sin resultados'),
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList.separated(
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return VueloCard(
                        numeroVuelo: item.numeroVuelo,
                        aerolineaNombre: nombreAerolinea(item.aerolinea),
                        estado: item.estado,
                        origenCodigo: codigoAeropuerto(item.origen),
                        destinoCodigo: codigoAeropuerto(item.destino),
                        origenCiudad: ciudadAeropuerto(item.origen),
                        destinoCiudad: ciudadAeropuerto(item.destino),
                        duracionMin: item.duracionMin,
                        horaSalida: _fmtHora(item.salidaProgramada),
                        horaLlegada: _fmtHora(item.llegadaProgramada),
                        horaSalidaReal: item.salidaReal != null ? _fmtHora(item.salidaReal!) : null,
                        horaLlegadaReal: item.llegadaReal != null ? _fmtHora(item.llegadaReal!) : null,
                        puertaCodigo: codigoPuerta(item.puerta),
                        aeronaveMatricula: matriculaAeronave(item.aeronave),
                        trailing: esAdmin && item.id != null
                            ? IconButton(
                                icon: const Icon(Icons.delete_outline, color: AppColors.error, size: 20),
                                tooltip: 'Eliminar',
                                onPressed: () => _eliminar(context, item.id!, item.numeroVuelo.toString()),
                              )
                            : null,
                        onTap: () => context.push('/vuelos/${item.id}'),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
