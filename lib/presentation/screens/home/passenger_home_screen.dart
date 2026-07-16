import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../theme/app_colors.dart';
import '../../providers/auth_provider.dart';

/// Home para pasajeros, inspirado en el estilo de apps de aerolíneas
/// (buscador arriba, carrusel de ofertas, acceso a "mis reservas" y un
/// buscador rápido por ruta). Las tarjetas de oferta quedan vacías a
/// propósito, listas para que se les agregue una imagen más adelante.
class PassengerHomeScreen extends StatefulWidget {
  final VoidCallback? onVerReservas;

  const PassengerHomeScreen({super.key, this.onVerReservas});

  @override
  State<PassengerHomeScreen> createState() => _PassengerHomeScreenState();
}

class _PassengerHomeScreenState extends State<PassengerHomeScreen> {
  final _paginaOfertasCtrl = PageController();
  int _paginaOferta = 0;

  @override
  void dispose() {
    _paginaOfertasCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final nombre = (auth.usuario?.nombreCompleto.isNotEmpty ?? false) ? auth.usuario!.nombreCompleto : 'viajero';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          _Encabezado(nombre: nombre),
          Transform.translate(
            offset: const Offset(0, -28),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _BuscadorRapido(onTap: () => context.push('/vuelos/buscar')),
                  const SizedBox(height: 28),
                  const Text('Oferta de vuelos', style: TextStyle(color: AppColors.textPrimary, fontSize: 17, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 150,
                    child: PageView.builder(
                      controller: _paginaOfertasCtrl,
                      itemCount: 3,
                      onPageChanged: (i) => setState(() => _paginaOferta = i),
                      itemBuilder: (context, index) => Padding(
                        padding: const EdgeInsets.only(right: 4),
                        child: _TarjetaOfertaVacia(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (i) {
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
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Encabezado extends StatelessWidget {
  final String nombre;
  const _Encabezado({required this.nombre});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 60),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF17337A), Color(0xFF2E5CFF), Color(0xFF0A0A0F)],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.flight, color: Colors.white, size: 22),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text('SkyOps', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                ),
                Container(
                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), shape: BoxShape.circle),
                  child: IconButton(
                    icon: const Icon(Icons.notifications_outlined, color: Colors.white, size: 20),
                    onPressed: () => context.push('/notificaciones'),
                  ),
                ),
                const SizedBox(width: 4),
                Material(
                  color: Colors.transparent,
                  shape: const CircleBorder(),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () => context.push('/menu'),
                    child: CircleAvatar(
                      radius: 19,
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                      child: Text(
                        nombre.isNotEmpty ? nombre[0].toUpperCase() : '?',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            Text('Hola, $nombre', style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 2),
            const Text('¿A dónde quieres viajar?', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
          ],
        ),
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

class _TarjetaOfertaVacia extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.surfaceVariant, style: BorderStyle.solid),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.image_outlined, color: AppColors.textSecondary.withValues(alpha: 0.5), size: 32),
            const SizedBox(height: 8),
            Text(
              'Espacio para promoción',
              style: TextStyle(color: AppColors.textSecondary.withValues(alpha: 0.7), fontSize: 12),
            ),
          ],
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
