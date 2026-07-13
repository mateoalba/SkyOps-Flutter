import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/categoria_pasajero_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/confirm_delete_dialog.dart';
import '../../widgets/loading_overlay.dart';
import '../../widgets/entity_list_card.dart';
import '../../widgets/search_field.dart';
import '../../../theme/app_colors.dart';

class CategoriaPasajeroListScreen extends StatefulWidget {
  const CategoriaPasajeroListScreen({super.key});

  @override
  State<CategoriaPasajeroListScreen> createState() => _CategoriaPasajeroListScreenState();
}

class _CategoriaPasajeroListScreenState extends State<CategoriaPasajeroListScreen> {
  String _busqueda = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CategoriaPasajeroProvider>().cargar();
    });
  }

  static const Map<String, String> _tipoDisplay = {
    'diplomatico': 'Cuerpo diplomático',
    'frequent_flyer': 'Viajero frecuente',
    'embarazada': 'Gestante en vuelo',
    'menor_no_acompanado': 'Menor viajero solo',
    'discapacidad': 'Movilidad reducida',
    'deportista': 'Deportista o equipo',
    'vip': 'VIP corporativo',
  };

  static const Map<String, Color> _tipoColor = {
    'diplomatico': AppColors.secondary,
    'frequent_flyer': AppColors.gold,
    'embarazada': AppColors.success,
    'menor_no_acompanado': AppColors.warning,
    'discapacidad': AppColors.primary,
    'deportista': AppColors.error,
    'vip': AppColors.goldDark,
  };

  String _tipoTexto(String tipo) => _tipoDisplay[tipo] ?? (tipo.isEmpty ? 'Otro' : tipo);

  Color _tipoColorDe(String tipo) => _tipoColor[tipo] ?? AppColors.textSecondary;

  Future<void> _cambiarActiva(BuildContext context, dynamic item, bool valor) async {
    final provider = context.read<CategoriaPasajeroProvider>();
    final actualizado = item.copyWith(activa: valor);
    final ok = await provider.actualizar(item.id, actualizado);
    if (!context.mounted) return;
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.error ?? 'No se pudo actualizar')),
      );
    }
  }

  Future<void> _eliminar(BuildContext context, int id, String nombre) async {
    final confirmado = await confirmarEliminacion(context, nombre: nombre);
    if (!confirmado || !context.mounted) return;
    final provider = context.read<CategoriaPasajeroProvider>();
    final ok = await provider.eliminar(id);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(ok ? 'Registro eliminado' : (provider.error ?? 'No se pudo eliminar'))),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CategoriaPasajeroProvider>();
    final auth = context.watch<AuthProvider>();
    final esAdmin = auth.usuario?.esAdmin ?? false;
    final puedeEscribir = esAdmin;

    final items = provider.items.where((item) {
      if (_busqueda.trim().isEmpty) return true;
      final q = _busqueda.trim().toLowerCase();
      return item.nombre.toString().toLowerCase().contains(q) ||
          item.tipo.toString().toLowerCase().contains(q);
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Categorías de pasajero')),
      floatingActionButton: puedeEscribir
          ? FloatingActionButton(
              heroTag: 'categorias_pasajero_nuevo_fab',
              onPressed: () => context.push('/categorias-pasajero/nuevo'),
              child: const Icon(Icons.add),
            )
          : null,
      body: LoadingOverlay(
        visible: provider.cargando,
        child: RefreshIndicator(
          onRefresh: () => context.read<CategoriaPasajeroProvider>().cargar(forzar: true),
          child: Column(
            children: [
              SearchField(
                hintText: 'Buscar categoría...',
                onChanged: (v) => setState(() => _busqueda = v),
              ),
              Expanded(
                child: items.isEmpty
                    ? ListView(
                        children: [
                          const SizedBox(height: 80),
                          Center(
                            child: Text(
                              provider.estado == EstadoCargaCategoriaPasajero.error
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
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final item = items[index];
                          final descripcion = item.descripcion?.trim() ?? '';
                          return EntityListCard(
                            titulo: item.nombre.toString(),
                            subtitulo: descripcion.isNotEmpty ? descripcion : _tipoTexto(item.tipo),
                            iniciales: item.nombre.toString(),
                            colorAvatar: _tipoColorDe(item.tipo),
                            activo: item.activa,
                            onCambiarActivo: puedeEscribir ? (v) => _cambiarActiva(context, item, v) : null,
                            estadisticas: [
                              MapEntry('TIPO', _tipoTexto(item.tipo)),
                              MapEntry('ASISTENCIA', item.requiereAsistencia ? 'Requerida' : 'No requerida'),
                            ],
                            onEliminar: esAdmin && item.id != null ? () => _eliminar(context, item.id!, item.nombre) : null,
                            onTap: puedeEscribir ? () => context.push('/categorias-pasajero/${item.id}/editar') : null,
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