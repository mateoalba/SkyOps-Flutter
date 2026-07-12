import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/escala_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/aeropuerto_provider.dart';
import '../../providers/vuelo_provider.dart';
import '../../widgets/confirm_delete_dialog.dart';
import '../../widgets/loading_overlay.dart';
import '../../widgets/entity_list_card.dart';
import '../../widgets/search_field.dart';

class EscalaListScreen extends StatefulWidget {
  const EscalaListScreen({super.key});

  @override
  State<EscalaListScreen> createState() => _EscalaListScreenState();
}

class _EscalaListScreenState extends State<EscalaListScreen> {
  String _busqueda = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EscalaProvider>().cargar();
      context.read<AeropuertoProvider>().cargar();
      context.read<VueloProvider>().cargar();
    });
  }

  String _fmtHora(DateTime d) {
    final hh = d.hour.toString().padLeft(2, '0');
    final mm = d.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }

  Future<void> _eliminar(BuildContext context, String id, String nombre) async {
    final confirmado = await confirmarEliminacion(context, nombre: nombre);
    if (!confirmado || !context.mounted) return;
    final provider = context.read<EscalaProvider>();
    final ok = await provider.eliminar(id);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(ok ? 'Registro eliminado' : (provider.error ?? 'No se pudo eliminar'))),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EscalaProvider>();
    final auth = context.watch<AuthProvider>();
    final opcAeropuerto = context.watch<AeropuertoProvider>().items;
    final opcVuelo = context.watch<VueloProvider>().items;
    final esAdmin = auth.usuario?.esAdmin ?? false;
    final puedeEscribir = esAdmin;

    String aeropuertoDisplay(String? id) {
      if (id == null) return '?';
      try {
        final a = opcAeropuerto.firstWhere((x) => x.id == id);
        return '${a.codigoIata} - ${a.nombre}';
      } catch (_) {
        return '?';
      }
    }

    String vueloDisplay(String? id) {
      if (id == null) return '?';
      try {
        return opcVuelo.firstWhere((x) => x.id == id).numeroVuelo;
      } catch (_) {
        return '?';
      }
    }

    final items = provider.items.where((item) {
      if (_busqueda.trim().isEmpty) return true;
      final q = _busqueda.trim().toLowerCase();
      final titulo = 'Escala #${item.numeroSecuencia} — ${aeropuertoDisplay(item.aeropuertoEscala)}';
      final subtitulo =
          'Vuelo ${vueloDisplay(item.vuelo)}  ·  Llega ${_fmtHora(item.horaLlegada)}  ·  Sale ${_fmtHora(item.horaSalida)}';
      return titulo.toLowerCase().contains(q) || subtitulo.toLowerCase().contains(q);
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Escalas de vuelo')),
      floatingActionButton: puedeEscribir
          ? FloatingActionButton(
              heroTag: 'escalas_nuevo_fab',
              onPressed: () => context.push('/escalas/nuevo'),
              child: const Icon(Icons.add),
            )
          : null,
      body: LoadingOverlay(
        visible: provider.cargando,
        child: RefreshIndicator(
          onRefresh: () => context.read<EscalaProvider>().cargar(forzar: true),
          child: Column(
            children: [
              SearchField(
                hintText: 'Buscar escala...',
                onChanged: (v) => setState(() => _busqueda = v),
              ),
              Expanded(
                child: items.isEmpty
                    ? ListView(
                        children: [
                          const SizedBox(height: 80),
                          Center(
                            child: Text(
                              provider.estado == EstadoCargaEscala.error
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
                            titulo: 'Escala #${item.numeroSecuencia} — ${aeropuertoDisplay(item.aeropuertoEscala)}',
                            subtitulo:
                                'Vuelo ${vueloDisplay(item.vuelo)}  ·  Llega ${_fmtHora(item.horaLlegada)}  ·  Sale ${_fmtHora(item.horaSalida)}',
                            iniciales: aeropuertoDisplay(item.aeropuertoEscala),
                            activo: null,
                            onEliminar: esAdmin && item.id != null ? () => _eliminar(context, item.id!, 'Escala #${item.numeroSecuencia}') : null,
                            onTap: puedeEscribir ? () => context.push('/escalas/${item.id}/editar') : null,
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