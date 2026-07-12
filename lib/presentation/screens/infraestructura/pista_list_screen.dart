import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/pista_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/confirm_delete_dialog.dart';
import '../../widgets/loading_overlay.dart';
import '../../widgets/entity_list_card.dart';
import '../../widgets/search_field.dart';

class PistaListScreen extends StatefulWidget {
  const PistaListScreen({super.key});

  @override
  State<PistaListScreen> createState() => _PistaListScreenState();
}

class _PistaListScreenState extends State<PistaListScreen> {
  String _busqueda = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PistaProvider>().cargar();
    });
  }

  Future<void> _eliminar(BuildContext context, String id, String nombre) async {
    final confirmado = await confirmarEliminacion(context, nombre: nombre);
    if (!confirmado || !context.mounted) return;
    final provider = context.read<PistaProvider>();
    final ok = await provider.eliminar(id);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(ok ? 'Registro eliminado' : (provider.error ?? 'No se pudo eliminar'))),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PistaProvider>();
    final auth = context.watch<AuthProvider>();
    final esAdmin = auth.usuario?.esAdmin ?? false;
    final puedeEscribir = esAdmin;

    final items = provider.items.where((item) {
      if (_busqueda.trim().isEmpty) return true;
      final q = _busqueda.trim().toLowerCase();
      return item.identificador.toString().toLowerCase().contains(q) ||
          item.superficie.toString().toLowerCase().contains(q);
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Pistas de aterrizaje')),
      floatingActionButton: puedeEscribir
          ? FloatingActionButton(
              heroTag: 'pistas_nuevo_fab',
              onPressed: () => context.push('/pistas/nuevo'),
              child: const Icon(Icons.add),
            )
          : null,
      body: LoadingOverlay(
        visible: provider.cargando,
        child: RefreshIndicator(
          onRefresh: () => context.read<PistaProvider>().cargar(forzar: true),
          child: Column(
            children: [
              SearchField(
                hintText: 'Buscar pista...',
                onChanged: (v) => setState(() => _busqueda = v),
              ),
              Expanded(
                child: items.isEmpty
                    ? ListView(
                        children: [
                          const SizedBox(height: 80),
                          Center(
                            child: Text(
                              provider.estado == EstadoCargaPista.error
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
                            titulo: item.identificador.toString(),
                            subtitulo: item.superficie.toString(),
                            iniciales: item.identificador.toString(),
                            activo: null,
                            onEliminar: esAdmin && item.id != null ? () => _eliminar(context, item.id!, item.identificador) : null,
                            onTap: puedeEscribir ? () => context.push('/pistas/${item.id}/editar') : null,
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