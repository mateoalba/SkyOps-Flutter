import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/aerolinea_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/confirm_delete_dialog.dart';
import '../../widgets/loading_overlay.dart';
import '../../widgets/entity_list_card.dart';
import '../../widgets/search_field.dart';

class AerolineaListScreen extends StatefulWidget {
  const AerolineaListScreen({super.key});

  @override
  State<AerolineaListScreen> createState() => _AerolineaListScreenState();
}

class _AerolineaListScreenState extends State<AerolineaListScreen> {
  String _busqueda = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AerolineaProvider>().cargar();
    });
  }

  Future<void> _eliminar(BuildContext context, String id, String nombre) async {
    final confirmado = await confirmarEliminacion(context, nombre: nombre);
    if (!confirmado || !context.mounted) return;
    final provider = context.read<AerolineaProvider>();
    final ok = await provider.eliminar(id);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(ok ? 'Registro eliminado' : (provider.error ?? 'No se pudo eliminar'))),
    );
  }

  Future<void> _cambiarActiva(BuildContext context, dynamic item, bool valor) async {
    final provider = context.read<AerolineaProvider>();
    final actualizado = item.copyWith(activa: valor);
    final ok = await provider.actualizar(item.id, actualizado);
    if (!context.mounted) return;
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.error ?? 'No se pudo actualizar')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AerolineaProvider>();
    final auth = context.watch<AuthProvider>();
    final esAdmin = auth.usuario?.esAdmin ?? false;
    final puedeEscribir = auth.usuario?.puedeOperar ?? false;

    final items = provider.items.where((item) {
      if (_busqueda.trim().isEmpty) return true;
      final q = _busqueda.trim().toLowerCase();
      return item.nombre.toLowerCase().contains(q) || item.codigoIata.toLowerCase().contains(q);
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Aerolíneas')),
      floatingActionButton: puedeEscribir
          ? FloatingActionButton(
              heroTag: 'aerolineas_nuevo_fab',
              onPressed: () => context.push('/aerolineas/nuevo'),
              child: const Icon(Icons.add),
            )
          : null,
      body: LoadingOverlay(
        visible: provider.cargando,
        child: RefreshIndicator(
          onRefresh: () => context.read<AerolineaProvider>().cargar(forzar: true),
          child: Column(
            children: [
              SearchField(
                hintText: 'Buscar aerolínea...',
                onChanged: (v) => setState(() => _busqueda = v),
              ),
              Expanded(
                child: items.isEmpty
                    ? ListView(
                        children: [
                          const SizedBox(height: 80),
                          Center(
                            child: Text(
                              provider.estado == EstadoCargaAerolinea.error
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
                            titulo: item.nombre,
                            subtitulo: item.codigoIata,
                            iniciales: item.nombre,
                            activo: item.activa,
                            onCambiarActivo: puedeEscribir ? (v) => _cambiarActiva(context, item, v) : null,
                            onEliminar: esAdmin && item.id != null ? () => _eliminar(context, item.id!, item.nombre) : null,
                            onTap: () => context.push('/aerolineas/${item.id}/editar'),
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