import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../screens/auth/splash_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/auth/profile_screen.dart';
import '../screens/auth/profile_edit_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/home/main_shell_screen.dart';
import '../screens/verificacion/verificacion_screen.dart';
import '../screens/public/public_home_screen.dart';
import '../screens/public/public_module_detail_screen.dart';
import '../screens/public/public_contact_screen.dart';
import '../../domain/model/aerolinea.dart';
import '../screens/administracion/aerolinea_list_screen.dart';
import '../screens/administracion/aerolinea_form_screen.dart';
import '../../domain/model/aeropuerto.dart';
import '../screens/infraestructura/aeropuerto_list_screen.dart';
import '../screens/infraestructura/aeropuerto_form_screen.dart';
import '../../domain/model/aeronave.dart';
import '../screens/flota/aeronave_list_screen.dart';
import '../screens/flota/aeronave_form_screen.dart';
import '../../domain/model/puerta.dart';
import '../screens/infraestructura/puerta_list_screen.dart';
import '../screens/infraestructura/puerta_form_screen.dart';
import '../../domain/model/vuelo.dart';
import '../screens/operaciones/vuelo_list_screen.dart';
import '../screens/operaciones/vuelo_form_screen.dart';
import '../screens/operaciones/vuelo_detail_screen.dart';
import '../screens/operaciones/buscar_vuelo_screen.dart';
import '../../domain/model/pasajero.dart';
import '../screens/personas/pasajero_list_screen.dart';
import '../screens/personas/pasajero_form_screen.dart';
import '../../domain/model/reserva.dart';
import '../screens/personas/reserva_list_screen.dart';
import '../screens/personas/reserva_form_screen.dart';
import '../../domain/model/tripulante.dart';
import '../screens/personas/tripulante_list_screen.dart';
import '../screens/personas/tripulante_form_screen.dart';
import '../../domain/model/asignacion.dart';
import '../screens/operaciones/asignacion_list_screen.dart';
import '../screens/operaciones/asignacion_form_screen.dart';
import '../../domain/model/incidente.dart';
import '../screens/operaciones/incidente_list_screen.dart';
import '../screens/operaciones/incidente_form_screen.dart';
import '../../domain/model/terminal.dart';
import '../screens/infraestructura/terminal_list_screen.dart';
import '../screens/infraestructura/terminal_form_screen.dart';
import '../../domain/model/pista.dart';
import '../screens/infraestructura/pista_list_screen.dart';
import '../screens/infraestructura/pista_form_screen.dart';
import '../../domain/model/asignacion_pista.dart';
import '../screens/operaciones/asignacion_pista_list_screen.dart';
import '../screens/operaciones/asignacion_pista_form_screen.dart';
import '../../domain/model/horario.dart';
import '../screens/operaciones/horario_list_screen.dart';
import '../screens/operaciones/horario_form_screen.dart';
import '../../domain/model/escala.dart';
import '../screens/operaciones/escala_list_screen.dart';
import '../screens/operaciones/escala_form_screen.dart';
import '../../domain/model/tipo_aeronave.dart';
import '../screens/flota/tipo_aeronave_list_screen.dart';
import '../screens/flota/tipo_aeronave_form_screen.dart';
import '../../domain/model/equipaje.dart';
import '../screens/personas/equipaje_list_screen.dart';
import '../screens/personas/equipaje_form_screen.dart';
import '../../domain/model/tarjeta_embarque.dart';
import '../screens/personas/tarjeta_embarque_list_screen.dart';
import '../screens/personas/tarjeta_embarque_form_screen.dart';
import '../../domain/model/categoria_pasajero.dart';
import '../screens/personas/categoria_pasajero_list_screen.dart';
import '../screens/personas/categoria_pasajero_form_screen.dart';
import '../../domain/model/notificacion.dart';
import '../screens/administracion/notificacion_list_screen.dart';
import '../screens/administracion/notificacion_form_screen.dart';
import '../../domain/model/perfil_usuario.dart';
import '../screens/administracion/perfil_usuario_list_screen.dart';
import '../screens/administracion/perfil_usuario_form_screen.dart';
import '../../domain/model/sesion_usuario.dart';
import '../screens/administracion/sesion_usuario_list_screen.dart';
import '../screens/administracion/sesion_usuario_form_screen.dart';
import '../../domain/model/audit_log.dart';
import '../screens/administracion/audit_log_list_screen.dart';
import '../screens/administracion/audit_log_form_screen.dart';
import '../../domain/model/mantenimiento.dart';
import '../screens/flota/mantenimiento_list_screen.dart';
import '../screens/flota/mantenimiento_form_screen.dart';
import '../../domain/model/certificacion.dart';
import '../screens/flota/certificacion_list_screen.dart';
import '../screens/flota/certificacion_form_screen.dart';
import '../screens/administracion/contenido_publico_screen.dart';

/// Router de la app con guard de autenticación basado en [AuthProvider].
class AppRouter {
  static GoRouter crear(AuthProvider authProvider) {
    return GoRouter(
      initialLocation: '/splash',
      refreshListenable: authProvider,
      redirect: (context, state) {
        final autenticado = authProvider.estaAutenticado;
        final rutaPublica = state.matchedLocation == '/splash' ||
            state.matchedLocation == '/login' ||
            state.matchedLocation == '/register' ||
            state.matchedLocation == '/verificacion' ||
            state.matchedLocation.startsWith('/publico');
        if (authProvider.estado == EstadoAuth.desconocido) return null;
        if (!autenticado && !rutaPublica) return '/login';
        if (autenticado && (state.matchedLocation == '/login' ||
            state.matchedLocation == '/register' ||
            state.matchedLocation == '/splash')) {
          return '/home';
        }
        return null;
      },
      routes: [
        GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),
        GoRoute(path: '/verificacion', builder: (context, state) => const VerificacionScreen()),
        GoRoute(path: '/publico', builder: (context, state) => const PublicHomeScreen()),
        GoRoute(
          path: '/publico/modulos/:id',
          builder: (context, state) => PublicModuleDetailScreen(moduloId: state.pathParameters['id']!),
        ),
        GoRoute(path: '/publico/contacto', builder: (context, state) => const PublicContactScreen()),
        GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
        GoRoute(path: '/register', builder: (context, state) => const RegisterScreen()),
        GoRoute(path: '/profile', builder: (context, state) => const ProfileScreen()),
        GoRoute(path: '/perfil/editar', builder: (context, state) => const ProfileEditScreen()),
        GoRoute(path: '/home', builder: (context, state) => const MainShellScreen()),
        GoRoute(path: '/menu', builder: (context, state) => const HomeScreen()),
        GoRoute(
          path: '/aerolineas',
          builder: (context, state) => const AerolineaListScreen(),
        ),
        GoRoute(
          path: '/aerolineas/nuevo',
          builder: (context, state) => const AerolineaFormScreen(),
        ),
        GoRoute(
          path: '/aerolineas/:id/editar',
          builder: (context, state) => AerolineaFormScreen(id: state.pathParameters['id']!),
        ),
        GoRoute(
          path: '/aeropuertos',
          builder: (context, state) => const AeropuertoListScreen(),
        ),
        GoRoute(
          path: '/aeropuertos/nuevo',
          builder: (context, state) => const AeropuertoFormScreen(),
        ),
        GoRoute(
          path: '/aeropuertos/:id/editar',
          builder: (context, state) => AeropuertoFormScreen(id: state.pathParameters['id']!),
        ),
        GoRoute(
          path: '/aeronaves',
          builder: (context, state) => const AeronaveListScreen(),
        ),
        GoRoute(
          path: '/aeronaves/nuevo',
          builder: (context, state) => const AeronaveFormScreen(),
        ),
        GoRoute(
          path: '/aeronaves/:id/editar',
          builder: (context, state) => AeronaveFormScreen(id: state.pathParameters['id']!),
        ),
        GoRoute(
          path: '/puertas',
          builder: (context, state) => const PuertaListScreen(),
        ),
        GoRoute(
          path: '/puertas/nuevo',
          builder: (context, state) => const PuertaFormScreen(),
        ),
        GoRoute(
          path: '/puertas/:id/editar',
          builder: (context, state) => PuertaFormScreen(id: state.pathParameters['id']!),
        ),
        GoRoute(
          path: '/vuelos/buscar',
          builder: (context, state) => const BuscarVueloScreen(),
        ),
        GoRoute(
          path: '/vuelos',
          builder: (context, state) => const VueloListScreen(),
        ),
        GoRoute(
          path: '/vuelos/nuevo',
          builder: (context, state) => const VueloFormScreen(),
        ),
        GoRoute(
          path: '/vuelos/:id/editar',
          builder: (context, state) => VueloFormScreen(id: state.pathParameters['id']!),
        ),
        GoRoute(
          path: '/vuelos/:id',
          builder: (context, state) => VueloDetailScreen(id: state.pathParameters['id']!),
        ),
        GoRoute(
          path: '/pasajeros',
          builder: (context, state) => const PasajeroListScreen(),
        ),
        GoRoute(
          path: '/pasajeros/nuevo',
          builder: (context, state) => const PasajeroFormScreen(),
        ),
        GoRoute(
          path: '/pasajeros/:id/editar',
          builder: (context, state) => PasajeroFormScreen(id: state.pathParameters['id']!),
        ),
        GoRoute(
          path: '/reservas',
          builder: (context, state) => const ReservaListScreen(),
        ),
        GoRoute(
          path: '/reservas/nuevo',
          builder: (context, state) => ReservaFormScreen(vueloPreseleccionado: state.extra as Vuelo?),
        ),
        GoRoute(
          path: '/reservas/:id/editar',
          builder: (context, state) => ReservaFormScreen(id: state.pathParameters['id']!),
        ),
        GoRoute(
          path: '/tripulantes',
          builder: (context, state) => const TripulanteListScreen(),
        ),
        GoRoute(
          path: '/tripulantes/nuevo',
          builder: (context, state) => const TripulanteFormScreen(),
        ),
        GoRoute(
          path: '/tripulantes/:id/editar',
          builder: (context, state) => TripulanteFormScreen(id: state.pathParameters['id']!),
        ),
        GoRoute(
          path: '/asignaciones',
          builder: (context, state) => const AsignacionListScreen(),
        ),
        GoRoute(
          path: '/asignaciones/nuevo',
          builder: (context, state) => const AsignacionFormScreen(),
        ),
        GoRoute(
          path: '/asignaciones/:id/editar',
          builder: (context, state) => AsignacionFormScreen(id: state.pathParameters['id']!),
        ),
        GoRoute(
          path: '/incidentes',
          builder: (context, state) => const IncidenteListScreen(),
        ),
        GoRoute(
          path: '/incidentes/nuevo',
          builder: (context, state) => const IncidenteFormScreen(),
        ),
        GoRoute(
          path: '/incidentes/:id/editar',
          builder: (context, state) => IncidenteFormScreen(id: state.pathParameters['id']!),
        ),
        GoRoute(
          path: '/terminales',
          builder: (context, state) => const TerminalListScreen(),
        ),
        GoRoute(
          path: '/terminales/nuevo',
          builder: (context, state) => const TerminalFormScreen(),
        ),
        GoRoute(
          path: '/terminales/:id/editar',
          builder: (context, state) => TerminalFormScreen(id: state.pathParameters['id']!),
        ),
        GoRoute(
          path: '/pistas',
          builder: (context, state) => const PistaListScreen(),
        ),
        GoRoute(
          path: '/pistas/nuevo',
          builder: (context, state) => const PistaFormScreen(),
        ),
        GoRoute(
          path: '/pistas/:id/editar',
          builder: (context, state) => PistaFormScreen(id: state.pathParameters['id']!),
        ),
        GoRoute(
          path: '/asignaciones-pista',
          builder: (context, state) => const AsignacionPistaListScreen(),
        ),
        GoRoute(
          path: '/asignaciones-pista/nuevo',
          builder: (context, state) => const AsignacionPistaFormScreen(),
        ),
        GoRoute(
          path: '/asignaciones-pista/:id/editar',
          builder: (context, state) => AsignacionPistaFormScreen(id: state.pathParameters['id']!),
        ),
        GoRoute(
          path: '/horarios',
          builder: (context, state) => const HorarioListScreen(),
        ),
        GoRoute(
          path: '/horarios/nuevo',
          builder: (context, state) => const HorarioFormScreen(),
        ),
        GoRoute(
          path: '/horarios/:id/editar',
          builder: (context, state) => HorarioFormScreen(id: state.pathParameters['id']!),
        ),
        GoRoute(
          path: '/escalas',
          builder: (context, state) => const EscalaListScreen(),
        ),
        GoRoute(
          path: '/escalas/nuevo',
          builder: (context, state) => const EscalaFormScreen(),
        ),
        GoRoute(
          path: '/escalas/:id/editar',
          builder: (context, state) => EscalaFormScreen(id: state.pathParameters['id']!),
        ),
        GoRoute(
          path: '/tipos-aeronave',
          builder: (context, state) => const TipoAeronaveListScreen(),
        ),
        GoRoute(
          path: '/tipos-aeronave/nuevo',
          builder: (context, state) => const TipoAeronaveFormScreen(),
        ),
        GoRoute(
          path: '/tipos-aeronave/:id/editar',
          builder: (context, state) => TipoAeronaveFormScreen(id: int.parse(state.pathParameters['id']!)),
        ),
        GoRoute(
          path: '/equipajes',
          builder: (context, state) => const EquipajeListScreen(),
        ),
        GoRoute(
          path: '/equipajes/nuevo',
          builder: (context, state) => const EquipajeFormScreen(),
        ),
        GoRoute(
          path: '/equipajes/:id/editar',
          builder: (context, state) => EquipajeFormScreen(id: int.parse(state.pathParameters['id']!)),
        ),
        GoRoute(
          path: '/tarjetas-embarque',
          builder: (context, state) => const TarjetaEmbarqueListScreen(),
        ),
        GoRoute(
          path: '/tarjetas-embarque/nuevo',
          builder: (context, state) => const TarjetaEmbarqueFormScreen(),
        ),
        GoRoute(
          path: '/tarjetas-embarque/:id/editar',
          builder: (context, state) => TarjetaEmbarqueFormScreen(id: int.parse(state.pathParameters['id']!)),
        ),
        GoRoute(
          path: '/categorias-pasajero',
          builder: (context, state) => const CategoriaPasajeroListScreen(),
        ),
        GoRoute(
          path: '/categorias-pasajero/nuevo',
          builder: (context, state) => const CategoriaPasajeroFormScreen(),
        ),
        GoRoute(
          path: '/categorias-pasajero/:id/editar',
          builder: (context, state) => CategoriaPasajeroFormScreen(id: int.parse(state.pathParameters['id']!)),
        ),
        GoRoute(
          path: '/notificaciones',
          builder: (context, state) => const NotificacionListScreen(),
        ),
        GoRoute(
          path: '/notificaciones/nuevo',
          builder: (context, state) => const NotificacionFormScreen(),
        ),
        GoRoute(
          path: '/notificaciones/:id/editar',
          builder: (context, state) => NotificacionFormScreen(id: int.parse(state.pathParameters['id']!)),
        ),
        GoRoute(
          path: '/perfiles-usuario',
          builder: (context, state) => const PerfilUsuarioListScreen(),
        ),
        GoRoute(
          path: '/perfiles-usuario/nuevo',
          builder: (context, state) => const PerfilUsuarioFormScreen(),
        ),
        GoRoute(
          path: '/perfiles-usuario/:id/editar',
          builder: (context, state) => PerfilUsuarioFormScreen(id: state.pathParameters['id']!),
        ),
        GoRoute(
          path: '/sesiones-usuario',
          builder: (context, state) => const SesionUsuarioListScreen(),
        ),
        GoRoute(
          path: '/sesiones-usuario/nuevo',
          builder: (context, state) => const SesionUsuarioFormScreen(),
        ),
        GoRoute(
          path: '/sesiones-usuario/:id/editar',
          builder: (context, state) => SesionUsuarioFormScreen(id: state.pathParameters['id']!),
        ),
        GoRoute(
          path: '/audit-log',
          builder: (context, state) => const AuditLogListScreen(),
        ),
        GoRoute(
          path: '/audit-log/nuevo',
          builder: (context, state) => const AuditLogFormScreen(),
        ),
        GoRoute(
          path: '/audit-log/:id/editar',
          builder: (context, state) => AuditLogFormScreen(id: state.pathParameters['id']!),
        ),
        GoRoute(
          path: '/mantenimientos',
          builder: (context, state) => const MantenimientoListScreen(),
        ),
        GoRoute(
          path: '/mantenimientos/nuevo',
          builder: (context, state) => const MantenimientoFormScreen(),
        ),
        GoRoute(
          path: '/mantenimientos/:id/editar',
          builder: (context, state) => MantenimientoFormScreen(id: state.pathParameters['id']!),
        ),
        GoRoute(
          path: '/certificaciones',
          builder: (context, state) => const CertificacionListScreen(),
        ),
        GoRoute(
          path: '/certificaciones/nuevo',
          builder: (context, state) => const CertificacionFormScreen(),
        ),
        GoRoute(
          path: '/certificaciones/:id/editar',
          builder: (context, state) => CertificacionFormScreen(id: state.pathParameters['id']!),
        ),
        GoRoute(
          path: '/contenido-publico',
          builder: (context, state) => const ContenidoPublicoScreen(),
        ),
      ],
    );
  }
}