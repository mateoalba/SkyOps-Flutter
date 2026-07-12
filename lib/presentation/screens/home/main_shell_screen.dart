import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../auth/profile_screen.dart';
import '../operaciones/vuelo_list_screen.dart';
import '../personas/reserva_list_screen.dart';
import 'dashboard_home_screen.dart';

/// Contenedor principal tras iniciar sesión: barra de navegación inferior
/// con 4 pestañas (Home / Flights / Bookings / Profile).
class MainShellScreen extends StatefulWidget {
  const MainShellScreen({super.key});

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  int _indice = 0;

  static const List<IconData> _iconos = [
    Icons.home_rounded,
    Icons.flight_takeoff,
    Icons.calendar_month_outlined,
    Icons.person_outline,
  ];

  static const List<String> _etiquetas = ['Inicio', 'Vuelos', 'Reservas', 'Perfil'];

  void _irA(int indice) => setState(() => _indice = indice);

  @override
  Widget build(BuildContext context) {
    final pantallas = [
      DashboardHomeScreen(onVerTodosVuelos: () => _irA(1), onVerReservas: () => _irA(2)),
      const VueloListScreen(),
      const ReservaListScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: _indice, children: pantallas),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.surfaceVariant)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        child: SafeArea(
          top: false,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_iconos.length, (i) {
              final activo = i == _indice;
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => _irA(i),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                      decoration: BoxDecoration(
                        color: activo ? AppColors.primary : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(
                        _iconos[i],
                        color: activo ? Colors.white : AppColors.textSecondary,
                        size: 22,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _etiquetas[i],
                      style: TextStyle(
                        color: activo ? AppColors.primary : AppColors.textSecondary,
                        fontSize: 11,
                        fontWeight: activo ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
