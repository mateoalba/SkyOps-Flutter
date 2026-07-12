import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/asignacion_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/vuelo_provider.dart';
import '../../providers/tripulante_provider.dart';
import '../../widgets/confirm_delete_dialog.dart';
import '../../widgets/loading_overlay.dart';
import '../../widgets/entity_list_card.dart';
import '../../widgets/search_field.dart';

class AsignacionListScreen extends StatefulWidget {
  const AsignacionListScreen({super.key});

  @override
  State<AsignacionListScreen> createState() => _AsignacionListScreenState();
}

class _AsignacionListScreenState extends State<AsignacionListScreen> {
  String _busqueda = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AsignacionProvider>().cargar();
      context.read<VueloProvider>().cargar();
      context.read<TripulanteProvider>().cargar();
    });
  }

  Future<void> _eliminar(BuildContext context, String id, String nombre) async {
    final confirmado = await confirmarEliminacion(context, nombre: nombre);
    if (!confirmado || !context.mounted) return;
    final provider = context.read<AsignacionProvider>();
    final ok = await provider.eliminar(id);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(ok ? 'Registro eliminado' : (provider.error ?? 'No se pudo eliminar'))),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AsignacionProvider>();
    final auth = context.watch<AuthProvider>();
    final opcVuelo = context.watch<VueloProvider>().items;
    final opcTripulante = context.watch<TripulanteProvider>().items;
    final esAdmin = auth.usuario?.esAdmin ?? false;
    final puedeEscribir = auth.usuario?.puedeOperar ?? false;

    String vueloDisplay(String? id) {
      if (id == null) return '?';
      try {
        return opcVuelo.firstWhere((x) => x.id == id).numeroVuelo;
      } catch (_) {
        return '?';
      }
    }

    String tripulanteDisplay(String? id) {
      if (id == null) return '?';
      try {
        final t = opcTripulante.firstWhere((x) => x.id == id);
        return '${t.nombre} ${t.apellido}';
      } catch (_) {
        return '?';
      }
    }

    final items = provider.items.where((item) {
      if (_busqueda.trim().isEmpty) return true;
      final q = _busqueda.trim().toLowerCase();
      final titulo = '${tripulanteDisplay(item.tripulante)} — ${item.rolAsignado}';
      final subtitulo = 'Vuelo ${vueloDisplay(item.vuelo)}';
      return titulo.toLowerCase().contains(q) || subtitulo.toLowerCase().contains(q);
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Asignaciones de tripulación')),
      floatingActionButton: puedeEscribir
          ? FloatingActionButton(
              heroTag: 'asignaciones_nuevo_fab',
              onPressed: () => context.push('/asignaciones/nuevo'),
              child: const Icon(Icons.add),
            )
          : null,
      body: LoadingOverlay(
        visible: provider.cargando,
        child: RefreshIndicator(
          onRefresh: () => context.read<AsignacionProvider>().cargar(forzar: true),
          child: Column(
            children: [
              SearchField(
                hintText: 'Buscar asignación...',
                onChanged: (v) => setState(() => _busqueda = v),
              ),
              Expanded(
                child: items.isEmpty
                    ? ListView(
                        children: [
                          const SizedBox(height: 80),
                          Center(
                            child: Text(
                              provider.estado == EstadoCargaAsignacion.error
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
                          return EntityListCard(
                            titulo: '${tripulanteDisplay(item.tripulante)} — ${item.rolAsignado}',
                            subtitulo: 'Vuelo ${vueloDisplay(item.vuelo)}',
                            iniciales: tripulanteDisplay(item.tripulante),
                            activo: null,
                            onEliminar: esAdmin && item.id != null ? () => _eliminar(context, item.id!, tripulanteDisplay(item.tripulante)) : null,
                            onTap: () => context.push(esAdmin ? '/asignaciones/${item.id}/editar' : '/asignaciones/${item.id}'),
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