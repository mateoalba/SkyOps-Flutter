import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'data/local/secure_storage.dart';
import 'data/remote/api/dio_client.dart';
import 'data/repository/auth_repository_impl.dart';
import 'data/repository/aerolinea_repository_impl.dart';
import 'data/repository/aeropuerto_repository_impl.dart';
import 'data/repository/aeronave_repository_impl.dart';
import 'data/repository/puerta_repository_impl.dart';
import 'data/repository/vuelo_repository_impl.dart';
import 'data/repository/pasajero_repository_impl.dart';
import 'data/repository/reserva_repository_impl.dart';
import 'data/repository/tripulante_repository_impl.dart';
import 'data/repository/asignacion_repository_impl.dart';
import 'data/repository/incidente_repository_impl.dart';
import 'data/repository/terminal_repository_impl.dart';
import 'data/repository/pista_repository_impl.dart';
import 'data/repository/asignacion_pista_repository_impl.dart';
import 'data/repository/horario_repository_impl.dart';
import 'data/repository/escala_repository_impl.dart';
import 'data/repository/tipo_aeronave_repository_impl.dart';
import 'data/repository/equipaje_repository_impl.dart';
import 'data/repository/tarjeta_embarque_repository_impl.dart';
import 'data/repository/categoria_pasajero_repository_impl.dart';
import 'data/repository/notificacion_repository_impl.dart';
import 'data/repository/perfil_usuario_repository_impl.dart';
import 'data/repository/sesion_usuario_repository_impl.dart';
import 'data/repository/audit_log_repository_impl.dart';
import 'data/repository/mantenimiento_repository_impl.dart';
import 'data/repository/certificacion_repository_impl.dart';
import 'data/repository/banner_promocional_repository_impl.dart';
import 'domain/repository/auth_repository.dart';
import 'domain/repository/aerolinea_repository.dart';
import 'domain/repository/aeropuerto_repository.dart';
import 'domain/repository/aeronave_repository.dart';
import 'domain/repository/puerta_repository.dart';
import 'domain/repository/vuelo_repository.dart';
import 'domain/repository/pasajero_repository.dart';
import 'domain/repository/reserva_repository.dart';
import 'domain/repository/tripulante_repository.dart';
import 'domain/repository/asignacion_repository.dart';
import 'domain/repository/incidente_repository.dart';
import 'domain/repository/terminal_repository.dart';
import 'domain/repository/pista_repository.dart';
import 'domain/repository/asignacion_pista_repository.dart';
import 'domain/repository/horario_repository.dart';
import 'domain/repository/escala_repository.dart';
import 'domain/repository/tipo_aeronave_repository.dart';
import 'domain/repository/equipaje_repository.dart';
import 'domain/repository/tarjeta_embarque_repository.dart';
import 'domain/repository/categoria_pasajero_repository.dart';
import 'domain/repository/notificacion_repository.dart';
import 'domain/repository/perfil_usuario_repository.dart';
import 'domain/repository/sesion_usuario_repository.dart';
import 'domain/repository/audit_log_repository.dart';
import 'domain/repository/mantenimiento_repository.dart';
import 'domain/repository/certificacion_repository.dart';
import 'domain/repository/banner_promocional_repository.dart';
import 'presentation/navigation/app_router.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/aerolinea_provider.dart';
import 'presentation/providers/aeropuerto_provider.dart';
import 'presentation/providers/aeronave_provider.dart';
import 'presentation/providers/puerta_provider.dart';
import 'presentation/providers/vuelo_provider.dart';
import 'presentation/providers/pasajero_provider.dart';
import 'presentation/providers/reserva_provider.dart';
import 'presentation/providers/tripulante_provider.dart';
import 'presentation/providers/asignacion_provider.dart';
import 'presentation/providers/incidente_provider.dart';
import 'presentation/providers/terminal_provider.dart';
import 'presentation/providers/pista_provider.dart';
import 'presentation/providers/asignacion_pista_provider.dart';
import 'presentation/providers/horario_provider.dart';
import 'presentation/providers/escala_provider.dart';
import 'presentation/providers/tipo_aeronave_provider.dart';
import 'presentation/providers/equipaje_provider.dart';
import 'presentation/providers/tarjeta_embarque_provider.dart';
import 'presentation/providers/categoria_pasajero_provider.dart';
import 'presentation/providers/notificacion_provider.dart';
import 'presentation/providers/perfil_usuario_provider.dart';
import 'presentation/providers/sesion_usuario_provider.dart';
import 'presentation/providers/audit_log_provider.dart';
import 'presentation/providers/mantenimiento_provider.dart';
import 'presentation/providers/certificacion_provider.dart';
import 'presentation/providers/banner_promocional_provider.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const SkyOpsApp());
}

/// Punto de entrada de SkyOps: arma la inyección de dependencias
/// (Dio -> Repositorios -> Providers) y expone el árbol de la app.
class SkyOpsApp extends StatelessWidget {
  const SkyOpsApp({super.key});

  @override
  Widget build(BuildContext context) {
    final secureStorage = SecureStorage();
    final dio = DioClient.crear(secureStorage);

    final AuthRepository authRepository = AuthRepositoryImpl(dio, secureStorage);
    final AerolineaRepository aerolineaRepository = AerolineaRepositoryImpl(dio);
    final AeropuertoRepository aeropuertoRepository = AeropuertoRepositoryImpl(dio);
    final AeronaveRepository aeronaveRepository = AeronaveRepositoryImpl(dio);
    final PuertaRepository puertaRepository = PuertaRepositoryImpl(dio);
    final VueloRepository vueloRepository = VueloRepositoryImpl(dio);
    final PasajeroRepository pasajeroRepository = PasajeroRepositoryImpl(dio);
    final ReservaRepository reservaRepository = ReservaRepositoryImpl(dio);
    final TripulanteRepository tripulanteRepository = TripulanteRepositoryImpl(dio);
    final AsignacionRepository asignacionRepository = AsignacionRepositoryImpl(dio);
    final IncidenteRepository incidenteRepository = IncidenteRepositoryImpl(dio);
    final TerminalRepository terminalRepository = TerminalRepositoryImpl(dio);
    final PistaRepository pistaRepository = PistaRepositoryImpl(dio);
    final AsignacionPistaRepository asignacionPistaRepository = AsignacionPistaRepositoryImpl(dio);
    final HorarioRepository horarioRepository = HorarioRepositoryImpl(dio);
    final EscalaRepository escalaRepository = EscalaRepositoryImpl(dio);
    final TipoAeronaveRepository tipoAeronaveRepository = TipoAeronaveRepositoryImpl(dio);
    final EquipajeRepository equipajeRepository = EquipajeRepositoryImpl(dio);
    final TarjetaEmbarqueRepository tarjetaEmbarqueRepository = TarjetaEmbarqueRepositoryImpl(dio);
    final CategoriaPasajeroRepository categoriaPasajeroRepository = CategoriaPasajeroRepositoryImpl(dio);
    final NotificacionRepository notificacionRepository = NotificacionRepositoryImpl(dio);
    final PerfilUsuarioRepository perfilUsuarioRepository = PerfilUsuarioRepositoryImpl(dio);
    final SesionUsuarioRepository sesionUsuarioRepository = SesionUsuarioRepositoryImpl(dio);
    final AuditLogRepository auditLogRepository = AuditLogRepositoryImpl(dio);
    final MantenimientoRepository mantenimientoRepository = MantenimientoRepositoryImpl(dio);
    final CertificacionRepository certificacionRepository = CertificacionRepositoryImpl(dio);
    final BannerPromocionalRepository bannerPromocionalRepository = BannerPromocionalRepositoryImpl(dio);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider(authRepository)..verificarSesion()),
        ChangeNotifierProvider(create: (_) => AerolineaProvider(aerolineaRepository)),
        ChangeNotifierProvider(create: (_) => AeropuertoProvider(aeropuertoRepository)),
        ChangeNotifierProvider(create: (_) => AeronaveProvider(aeronaveRepository)),
        ChangeNotifierProvider(create: (_) => PuertaProvider(puertaRepository)),
        ChangeNotifierProvider(create: (_) => VueloProvider(vueloRepository)),
        ChangeNotifierProvider(create: (_) => PasajeroProvider(pasajeroRepository)),
        ChangeNotifierProvider(create: (_) => ReservaProvider(reservaRepository)),
        ChangeNotifierProvider(create: (_) => TripulanteProvider(tripulanteRepository)),
        ChangeNotifierProvider(create: (_) => AsignacionProvider(asignacionRepository)),
        ChangeNotifierProvider(create: (_) => IncidenteProvider(incidenteRepository)),
        ChangeNotifierProvider(create: (_) => TerminalProvider(terminalRepository)),
        ChangeNotifierProvider(create: (_) => PistaProvider(pistaRepository)),
        ChangeNotifierProvider(create: (_) => AsignacionPistaProvider(asignacionPistaRepository)),
        ChangeNotifierProvider(create: (_) => HorarioProvider(horarioRepository)),
        ChangeNotifierProvider(create: (_) => EscalaProvider(escalaRepository)),
        ChangeNotifierProvider(create: (_) => TipoAeronaveProvider(tipoAeronaveRepository)),
        ChangeNotifierProvider(create: (_) => EquipajeProvider(equipajeRepository)),
        ChangeNotifierProvider(create: (_) => TarjetaEmbarqueProvider(tarjetaEmbarqueRepository)),
        ChangeNotifierProvider(create: (_) => CategoriaPasajeroProvider(categoriaPasajeroRepository)),
        ChangeNotifierProvider(create: (_) => NotificacionProvider(notificacionRepository)),
        ChangeNotifierProvider(create: (_) => PerfilUsuarioProvider(perfilUsuarioRepository)),
        ChangeNotifierProvider(create: (_) => SesionUsuarioProvider(sesionUsuarioRepository)),
        ChangeNotifierProvider(create: (_) => AuditLogProvider(auditLogRepository)),
        ChangeNotifierProvider(create: (_) => MantenimientoProvider(mantenimientoRepository)),
        ChangeNotifierProvider(create: (_) => CertificacionProvider(certificacionRepository)),
        ChangeNotifierProvider(create: (_) => BannerPromocionalProvider(bannerPromocionalRepository)),
      ],
      child: const _AppRouterHost(),
    );
  }
}

/// Crea el GoRouter UNA sola vez (en initState) y lo reutiliza durante toda
/// la vida de la app. `AppRouter.crear` ya recibe `refreshListenable:
/// authProvider`, así que go_router vuelve a evaluar `redirect` solo con
/// eso, sin necesitar un GoRouter nuevo. Antes esto vivía en un `Builder`
/// que hacía `context.watch<AuthProvider>()` y reconstruía el GoRouter en
/// cada notifyListeners() (cada intento de login, falle o no) — como un
/// GoRouter nuevo siempre arranca en `initialLocation: '/splash'`, eso
/// mandaba al usuario a splash/público en cada error de login en vez de
/// dejarlo en /login con el mensaje de error.
class _AppRouterHost extends StatefulWidget {
  const _AppRouterHost();

  @override
  State<_AppRouterHost> createState() => _AppRouterHostState();
}

class _AppRouterHostState extends State<_AppRouterHost> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = AppRouter.crear(context.read<AuthProvider>());
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'SkyOps',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      darkTheme: AppTheme.dark,
      theme: AppTheme.dark,
      routerConfig: _router,
      locale: const Locale('es', 'ES'),
      supportedLocales: const [Locale('es', 'ES'), Locale('en', 'US')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}
