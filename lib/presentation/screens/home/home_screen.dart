import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../theme/app_colors.dart';
import '../../../domain/model/user.dart';
import '../../providers/auth_provider.dart';

/// Nivel mínimo de acceso que exige el backend para poder al menos VER
/// (listar) cada entidad. Coincide con las permission_classes reales de
/// cada ViewSet en Django (ver airport/permissions.py):
/// - [todos]: cualquier usuario autenticado puede leer (SoloLectura,
///   EsUsuarioOAdmin, IsAuthenticated, o filtrado a "lo mío").
/// - [operador]: EsOperador exige is_staff o pertenecer al grupo Django
///   "Operadores" (Usuario.puedeOperar).
/// - [admin]: EsAdmin exige is_staff (Usuario.esAdmin).
enum _Nivel { todos, operador, admin }

class _EntradaMenu {
  final String titulo;
  final IconData icono;
  final String ruta;
  final _Nivel nivel;
  const _EntradaMenu(this.titulo, this.icono, this.ruta, [this.nivel = _Nivel.todos]);
}

/// Panel principal de SkyOps: agrupa las 25 entidades del backend por categoría.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const Map<String, List<_EntradaMenu>> _grupos = {
    'Operaciones de vuelo': [
      _EntradaMenu('Buscar vuelo (reservar)', Icons.search, '/vuelos/buscar'),
      _EntradaMenu('Vuelos', Icons.flight_takeoff, '/vuelos'),
      _EntradaMenu('Asignaciones de tripulación', Icons.assignment_ind, '/asignaciones', _Nivel.operador),
      _EntradaMenu('Incidentes', Icons.report_problem, '/incidentes', _Nivel.operador),
      _EntradaMenu('Asignaciones de pista', Icons.merge_type, '/asignaciones-pista', _Nivel.operador),
      _EntradaMenu('Horarios', Icons.schedule, '/horarios'),
      _EntradaMenu('Escalas', Icons.alt_route, '/escalas'),
    ],
    'Infraestructura del aeropuerto': [
      _EntradaMenu('Aeropuertos', Icons.local_airport, '/aeropuertos'),
      _EntradaMenu('Puertas de embarque', Icons.door_front_door, '/puertas', _Nivel.operador),
      _EntradaMenu('Terminales', Icons.apartment, '/terminales', _Nivel.operador),
      _EntradaMenu('Pistas', Icons.airline_stops, '/pistas', _Nivel.operador),
    ],
    'Flota y mantenimiento': [
      _EntradaMenu('Aeronaves', Icons.flight, '/aeronaves', _Nivel.operador),
      _EntradaMenu('Tipos de aeronave', Icons.category, '/tipos-aeronave', _Nivel.operador),
      _EntradaMenu('Mantenimientos', Icons.build, '/mantenimientos', _Nivel.operador),
      _EntradaMenu('Certificaciones', Icons.verified, '/certificaciones', _Nivel.operador),
    ],
    'Pasajeros y personal': [
      _EntradaMenu('Pasajeros', Icons.person, '/pasajeros', _Nivel.operador),
      _EntradaMenu('Reservas', Icons.event_seat, '/reservas'),
      _EntradaMenu('Tripulantes', Icons.badge, '/tripulantes', _Nivel.operador),
      _EntradaMenu('Equipajes', Icons.luggage, '/equipajes'),
      _EntradaMenu('Tarjetas de embarque', Icons.airplane_ticket, '/tarjetas-embarque'),
      _EntradaMenu('Categorías de pasajero', Icons.star, '/categorias-pasajero'),
    ],
    'Administración del sistema': [
      _EntradaMenu('Aerolíneas', Icons.airlines, '/aerolineas'),
      _EntradaMenu('Notificaciones', Icons.notifications, '/notificaciones'),
      _EntradaMenu('Perfiles de usuario', Icons.account_circle, '/perfiles-usuario', _Nivel.operador),
      _EntradaMenu('Sesiones de usuario', Icons.devices, '/sesiones-usuario', _Nivel.admin),
      _EntradaMenu('Registro de auditoría', Icons.history, '/audit-log', _Nivel.admin),
      _EntradaMenu('Contenido público', Icons.web, '/contenido-publico', _Nivel.admin),
    ],
  };

  static const Map<String, IconData> _iconosGrupo = {
    'Operaciones de vuelo': Icons.flight_takeoff,
    'Infraestructura del aeropuerto': Icons.location_city,
    'Flota y mantenimiento': Icons.airplanemode_active,
    'Pasajeros y personal': Icons.people,
    'Administración del sistema': Icons.admin_panel_settings,
  };

  static const Map<String, String> _descripcionesGrupo = {
    'Operaciones de vuelo': 'Planes de vuelo, rutas y despachos.',
    'Infraestructura del aeropuerto': 'Terminales, pistas y servicios en tierra.',
    'Flota y mantenimiento': 'Estado técnico y rotación de aeronaves.',
    'Pasajeros y personal': 'Manifiesto, tripulación y check-in.',
    'Administración del sistema': 'Usuarios, sesiones, auditoría y contenido.',
  };

  bool _visiblePara(_Nivel nivel, Usuario? usuario) {
    switch (nivel) {
      case _Nivel.todos:
        return true;
      case _Nivel.operador:
        return usuario?.puedeOperar ?? false;
      case _Nivel.admin:
        return usuario?.esAdmin ?? false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final usuario = context.watch<AuthProvider>().usuario;
    final tieneFoto = usuario?.foto != null && usuario!.foto!.trim().isNotEmpty;
    // Un pasajero no "gestiona operaciones", así que el encabezado le habla
    // distinto que a un admin/operador.
    final esPasajero = !(usuario?.puedeOperar ?? false);
    final tituloPanel = esPasajero ? 'Información' : 'Panel de Comando';
    final subtituloPanel = esPasajero
        ? 'Consulta tus vuelos, reservas y toda la información de tu viaje.'
        : 'Seleccione una categoría para gestionar operaciones aéreas.';

    // Filtra cada grupo a solo las entradas que el usuario actual puede al
    // menos ver, y descarta grupos que quedan vacíos.
    final gruposVisibles = _grupos.entries
        .map((grupo) => MapEntry(
              grupo.key,
              grupo.value.where((e) => _visiblePara(e.nivel, usuario)).toList(),
            ))
        .where((grupo) => grupo.value.isNotEmpty)
        .toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 100, 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tituloPanel,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: AppColors.textPrimary, fontSize: 30, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        esPasajero ? subtituloPanel.toUpperCase() : 'SELECCIONE UNA CATEGORIA PARA GESTIONAR',
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                    children: [
                  ...gruposVisibles.map((grupo) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _TarjetaCategoria(
                        icono: _iconosGrupo[grupo.key] ?? Icons.folder_outlined,
                        titulo: grupo.key,
                        descripcion: _descripcionesGrupo[grupo.key] ?? '',
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => _CategoriaScreen(titulo: grupo.key, entradas: grupo.value),
                          ),
                        ),
                      ),
                    );
                  }),
                    ],
                  ),
                ),
              ],
            ),
            Positioned(
              top: 20,
              right: 16,
              child: GestureDetector(
                onTap: () => context.push('/profile'),
                child: CircleAvatar(
                  radius: 28,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.18),
                  backgroundImage: tieneFoto ? NetworkImage(usuario.foto!) : null,
                  child: !tieneFoto
                      ? const Icon(Icons.person_outline, color: AppColors.primary, size: 28)
                      : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TarjetaCategoria extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final String descripcion;
  final VoidCallback onTap;

  const _TarjetaCategoria({
    required this.icono,
    required this.titulo,
    required this.descripcion,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: const BoxDecoration(color: AppColors.surfaceVariant, shape: BoxShape.circle),
                child: Icon(icono, color: AppColors.textPrimary, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titulo,
                      style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      descripcion,
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}

/// Sub-pantalla con las entradas de una categoría (segundo nivel del menú),
/// abierta con Navigator normal (no necesita ruta propia en el router).
class _CategoriaScreen extends StatelessWidget {
  final String titulo;
  final List<_EntradaMenu> entradas;
  const _CategoriaScreen({required this.titulo, required this.entradas});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Text(titulo),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: entradas.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final entrada = entradas[index];
          return Material(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => context.push(entrada.ruta),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: const BoxDecoration(color: AppColors.surfaceVariant, shape: BoxShape.circle),
                      child: Icon(entrada.icono, color: AppColors.textPrimary, size: 18),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        entrada.titulo,
                        style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 14),
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: AppColors.textSecondary),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
