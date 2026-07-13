import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../theme/app_colors.dart';
import '../../providers/banner_promocional_provider.dart';

/// Pantalla pública principal: accesible SIN iniciar sesión.
/// Carrusel deslizable con los módulos de SkyOps (estilo "onboarding" tipo
/// app de gimnasio), barra superior fija y botones de acceso fijos abajo.
class PublicHomeScreen extends StatefulWidget {
  const PublicHomeScreen({super.key});

  @override
  State<PublicHomeScreen> createState() => _PublicHomeScreenState();
}

class _PublicHomeScreenState extends State<PublicHomeScreen> {
  final _controller = PageController();
  Timer? _timer;
  int _pagina = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BannerPromocionalProvider>().cargar();
    });
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted) return;
      final siguiente = (_pagina + 1) % PublicModulos.lista.length;
      _controller.animateToPage(
        siguiente,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final banners = context.watch<BannerPromocionalProvider>();
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 12, 8),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.flight, color: AppColors.primary, size: 20),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'SkyOps',
                    style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  OutlinedButton.icon(
                    onPressed: () => context.push('/publico/contacto'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textPrimary,
                      side: const BorderSide(color: AppColors.surfaceVariant),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    ),
                    icon: const Icon(Icons.mail_outline, size: 16),
                    label: const Text('Contacto', style: TextStyle(fontSize: 13)),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: PageView.builder(
                    controller: _controller,
                    itemCount: PublicModulos.lista.length,
                    onPageChanged: (i) => setState(() => _pagina = i),
                    itemBuilder: (context, i) {
                      final modulo = PublicModulos.lista[i];
                      final clave = 'carrusel_${modulo.id}';
                      return _SlideModulo(
                        modulo: modulo,
                        titularOverride: banners.tituloPara(clave),
                        resumenOverride: banners.textoPara(clave),
                        imagenUrl: banners.urlPara(clave),
                      );
                    },
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(PublicModulos.lista.length, (i) {
                  final activo = i == _pagina;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: activo ? 22 : 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: activo ? AppColors.primary : AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textPrimary,
                        side: const BorderSide(color: AppColors.surfaceVariant),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                      ),
                      onPressed: () => context.push('/login'),
                      child: const Text('Iniciar sesión', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () => context.push('/register'),
                    child: const Text('¿No tienes cuenta? Crear cuenta'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SlideModulo extends StatelessWidget {
  final ModuloPublico modulo;
  final String? titularOverride;
  final String? resumenOverride;
  final String? imagenUrl;
  const _SlideModulo({
    required this.modulo,
    this.titularOverride,
    this.resumenOverride,
    this.imagenUrl,
  });

  @override
  Widget build(BuildContext context) {
    final tieneImagen = imagenUrl != null && imagenUrl!.trim().isNotEmpty;
    final titular = titularOverride ?? modulo.titular;
    final resumen = resumenOverride ?? modulo.resumen;

    return GestureDetector(
      onTap: () => context.push('/publico/modulos/${modulo.id}'),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration: BoxDecoration(gradient: modulo.gradiente),
          ),
          if (tieneImagen)
            Image.network(
              imagenUrl!,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
            )
          else
            Align(
              alignment: const Alignment(0.75, -0.5),
              child: Icon(modulo.icono, size: 220, color: Colors.white.withValues(alpha: 0.10)),
            ),
          Positioned(
            top: 16,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(modulo.icono, color: Colors.white, size: 14),
                  const SizedBox(width: 6),
                  Text(modulo.etiqueta, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black54],
                stops: [0.4, 1.0],
              ),
            ),
          ),
          Positioned(
            left: 20,
            right: 20,
            bottom: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titular,
                  style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, height: 1.15),
                ),
                const SizedBox(height: 6),
                Text(
                  resumen,
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 13),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Text(
                      'Ver detalle',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.chevron_right, color: Colors.white, size: 16),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ModuloPublico {
  final String id;
  final String etiqueta;
  final String titular;
  final String titulo;
  final String resumen;
  final String descripcion;
  final IconData icono;
  final Gradient gradiente;
  const ModuloPublico({
    required this.id,
    required this.etiqueta,
    required this.titular,
    required this.titulo,
    required this.resumen,
    required this.descripcion,
    required this.icono,
    required this.gradiente,
  });
}

/// Contenido informativo público (no requiere API/autenticación).
class PublicModulos {
  static const List<ModuloPublico> lista = [
    ModuloPublico(
      id: 'operaciones',
      etiqueta: 'Operaciones',
      titular: 'Controla cada vuelo\nen tiempo real',
      titulo: 'Operaciones de vuelo',
      resumen: 'Vuelos, horarios, escalas, asignaciones de tripulación y de pista.',
      descripcion:
          'Controla el ciclo de vida completo de un vuelo: programación, cambios de estado '
          '(programado, embarcando, en vuelo, aterrizado, cancelado), asignación de tripulación '
          'y de pista de despegue/aterrizaje, y registro de incidentes operativos.',
      icono: Icons.flight_takeoff,
      gradiente: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF0F1E4D), Color(0xFF2E5CFF)],
      ),
    ),
    ModuloPublico(
      id: 'infraestructura',
      etiqueta: 'Infraestructura',
      titular: 'Aeropuertos y terminales\nbajo control',
      titulo: 'Infraestructura del aeropuerto',
      resumen: 'Aeropuertos, terminales, puertas de embarque y pistas.',
      descripcion:
          'Administra los aeropuertos que opera SkyOps, sus terminales, puertas de embarque '
          'y pistas de aterrizaje, con su estado operativo en tiempo real.',
      icono: Icons.location_city,
      gradiente: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF122040), Color(0xFF3B6EFF)],
      ),
    ),
    ModuloPublico(
      id: 'flota',
      etiqueta: 'Flota',
      titular: 'Tu flota, siempre\nlista para volar',
      titulo: 'Flota y mantenimiento',
      resumen: 'Aeronaves, tipos de aeronave, mantenimientos y certificaciones.',
      descripcion:
          'Lleva el control de cada aeronave de la flota, su tipo/modelo, el historial de '
          'mantenimientos programados y las certificaciones vigentes de la tripulación.',
      icono: Icons.airplanemode_active,
      gradiente: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF181430), Color(0xFF5B4FE0)],
      ),
    ),
    ModuloPublico(
      id: 'personas',
      etiqueta: 'Personas',
      titular: 'Pasajeros y tripulación\nen un solo lugar',
      titulo: 'Pasajeros y personal',
      resumen: 'Pasajeros, reservas, tripulantes, equipaje y tarjetas de embarque.',
      descripcion:
          'Gestiona pasajeros y sus reservas, el equipaje asociado, las tarjetas de embarque '
          'y la información del personal de tripulación asignado a cada vuelo.',
      icono: Icons.people,
      gradiente: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF0F2A3D), Color(0xFF2E9CFF)],
      ),
    ),
    ModuloPublico(
      id: 'administracion',
      etiqueta: 'Administración',
      titular: 'Gestión y seguridad\npara tu operación',
      titulo: 'Administración del sistema',
      resumen: 'Aerolíneas, notificaciones, usuarios, sesiones y auditoría.',
      descripcion:
          'Módulo restringido a administradores: gestión de aerolíneas asociadas, notificaciones '
          'a pasajeros, perfiles de usuario, sesiones activas y el registro de auditoría del sistema.',
      icono: Icons.admin_panel_settings,
      gradiente: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF241627), Color(0xFF8A4FE0)],
      ),
    ),
  ];

  static ModuloPublico? porId(String id) {
    try {
      return lista.firstWhere((m) => m.id == id);
    } catch (_) {
      return null;
    }
  }
}
