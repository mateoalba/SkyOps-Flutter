import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/aeropuerto_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/confirm_delete_dialog.dart';
import '../../widgets/loading_overlay.dart';
import '../../widgets/search_field.dart';
import '../../../theme/app_colors.dart';

class AeropuertoListScreen extends StatefulWidget {
  const AeropuertoListScreen({super.key});

  @override
  State<AeropuertoListScreen> createState() => _AeropuertoListScreenState();
}

class _AeropuertoListScreenState extends State<AeropuertoListScreen> {
  String _busqueda = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AeropuertoProvider>().cargar();
    });
  }

  Future<void> _eliminar(BuildContext context, String id, String nombre) async {
    final confirmado = await confirmarEliminacion(context, nombre: nombre);
    if (!confirmado || !context.mounted) return;
    final provider = context.read<AeropuertoProvider>();
    final ok = await provider.eliminar(id);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(ok ? 'Registro eliminado' : (provider.error ?? 'No se pudo eliminar'))),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AeropuertoProvider>();
    final auth = context.watch<AuthProvider>();
    final esAdmin = auth.usuario?.esAdmin ?? false;
    final puedeEscribir = auth.usuario?.puedeOperar ?? false;

    final items = provider.items.where((item) {
      if (_busqueda.trim().isEmpty) return true;
      final q = _busqueda.trim().toLowerCase();
      return item.nombre.toString().toLowerCase().contains(q) ||
          item.codigoIata.toString().toLowerCase().contains(q) ||
          item.ciudad.toString().toLowerCase().contains(q) ||
          item.pais.toString().toLowerCase().contains(q);
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Aeropuertos')),
      floatingActionButton: puedeEscribir
          ? FloatingActionButton(
              heroTag: 'aeropuertos_nuevo_fab',
              onPressed: () => context.push('/aeropuertos/nuevo'),
              child: const Icon(Icons.add),
            )
          : null,
      body: LoadingOverlay(
        visible: provider.cargando,
        child: RefreshIndicator(
          onRefresh: () => context.read<AeropuertoProvider>().cargar(forzar: true),
          child: Column(
            children: [
              SearchField(
                hintText: 'Buscar aeropuerto o IATA...',
                onChanged: (v) => setState(() => _busqueda = v),
              ),
              Expanded(
                child: items.isEmpty
                    ? ListView(
                        children: [
                          const SizedBox(height: 80),
                          Center(
                            child: Text(
                              provider.estado == EstadoCargaAeropuerto.error
                                  ? (provider.error ?? 'No se pudo cargar. Verifica tu sesión/permisos.')
                                  : (_busqueda.isEmpty ? 'No hay registros todavía' : 'Sin resultados'),
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.white70),
                            ),
                          ),
                        ],
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: items.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 14),
                        itemBuilder: (context, index) {
                          final item = items[index];
                          return _AeropuertoHeroCard(
                            nombre: item.nombre,
                            codigoIata: item.codigoIata,
                            ciudad: item.ciudad,
                            pais: item.pais,
                            zonaHoraria: item.zonaHoraria,
                            fotoUrl: item.fotoUrl,
                            totalPuertas: item.totalPuertas,
                            puedeEliminar: esAdmin && item.id != null,
                            onEliminar: () => _eliminar(context, item.id!, item.nombre),
                            onTap: () => context.push('/aeropuertos/${item.id}/editar'),
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

/// Tarjeta con la foto del aeropuerto de fondo (o un degradado con ícono si
/// aún no tiene 'Foto Url' cargada), estilo "hub de operaciones": badges de
/// código IATA / Internacional arriba, ciudad y país, nombre, botón "Ver
/// detalles" y estadísticas reales (puertas registradas, zona horaria)
/// abajo. Ningún dato mostrado es inventado: todo sale del backend.
class _AeropuertoHeroCard extends StatelessWidget {
  final String nombre;
  final String codigoIata;
  final String ciudad;
  final String pais;
  final String zonaHoraria;
  final String? fotoUrl;
  final int? totalPuertas;
  final bool puedeEliminar;
  final VoidCallback onEliminar;
  final VoidCallback onTap;

  const _AeropuertoHeroCard({
    required this.nombre,
    required this.codigoIata,
    required this.ciudad,
    required this.pais,
    required this.zonaHoraria,
    required this.fotoUrl,
    required this.totalPuertas,
    required this.puedeEliminar,
    required this.onEliminar,
    required this.onTap,
  });

  bool get _esInternacional => nombre.toLowerCase().contains('internacional');

  @override
  Widget build(BuildContext context) {
    final tieneFoto = fotoUrl != null && fotoUrl!.trim().isNotEmpty;

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(24),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 200,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (tieneFoto)
                Image.network(
                  fotoUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _FondoPorDefecto(),
                  loadingBuilder: (context, child, progress) =>
                      progress == null ? child : _FondoPorDefecto(),
                )
              else
                _FondoPorDefecto(),
              // Degradado para legibilidad del texto.
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: [0.0, 0.55, 1.0],
                    colors: [Color(0x33000000), Color(0x66000000), Color(0xF2000000)],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _Badge(texto: codigoIata, color: AppColors.primary),
                        if (_esInternacional) ...[
                          const SizedBox(width: 8),
                          _Badge(texto: 'Internacional', color: AppColors.success),
                        ],
                        const Spacer(),
                        if (puedeEliminar)
                          _BotonCircular(
                            icono: Icons.delete_outline,
                            onTap: onEliminar,
                          ),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      '${ciudad.toUpperCase()}, ${pais.toUpperCase()}',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.6,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Text(
                            nombre,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              height: 1.15,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        _BotonVerDetalles(onTap: onTap),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(height: 1, color: Colors.white24),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _Estadistica('PUERTAS', totalPuertas != null ? '$totalPuertas' : '—'),
                        const SizedBox(width: 24),
                        _Estadistica('ZONA HORARIA', zonaHoraria.isNotEmpty ? zonaHoraria : '—'),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FondoPorDefecto extends StatelessWidget {
  const _FondoPorDefecto();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.surfaceVariant, AppColors.background],
        ),
      ),
      child: const Center(
        child: Icon(Icons.local_airport, size: 48, color: Colors.white24),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String texto;
  final Color color;
  const _Badge({required this.texto, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        texto,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

class _BotonCircular extends StatelessWidget {
  final IconData icono;
  final VoidCallback onTap;
  const _BotonCircular({required this.icono, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.35),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(7),
          child: Icon(icono, size: 16, color: Colors.white),
        ),
      ),
    );
  }
}

class _BotonVerDetalles extends StatelessWidget {
  final VoidCallback onTap;
  const _BotonVerDetalles({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          child: Text(
            'Ver detalles',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}

class _Estadistica extends StatelessWidget {
  final String etiqueta;
  final String valor;
  const _Estadistica(this.etiqueta, this.valor);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          etiqueta,
          style: const TextStyle(
            fontSize: 9,
            letterSpacing: 0.4,
            fontWeight: FontWeight.w600,
            color: Colors.white60,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          valor,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
