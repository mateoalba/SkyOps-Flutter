import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/sesion_usuario_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/confirm_delete_dialog.dart';
import '../../widgets/loading_overlay.dart';
import '../../widgets/entity_list_card.dart';
import '../../widgets/search_field.dart';
import '../../../theme/app_colors.dart';

class SesionUsuarioListScreen extends StatefulWidget {
  const SesionUsuarioListScreen({super.key});

  @override
  State<SesionUsuarioListScreen> createState() => _SesionUsuarioListScreenState();
}

class _SesionUsuarioListScreenState extends State<SesionUsuarioListScreen> {
  String _busqueda = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SesionUsuarioProvider>().cargar();
    });
  }

  Color _colorResultado(String resultado) {
    switch (resultado) {
      case 'exitoso':
        return AppColors.success;
      case 'fallido':
        return AppColors.error;
      case 'expirado':
        return AppColors.warning;
      case 'cerrado':
      default:
        return AppColors.textSecondary;
    }
  }

  String _fmtFecha(DateTime? d) {
    if (d == null) return '—';
    final l = d.toLocal();
    String dos(int n) => n.toString().padLeft(2, '0');
    return '${dos(l.day)}/${dos(l.month)}/${l.year} ${dos(l.hour)}:${dos(l.minute)}';
  }

  Future<void> _eliminar(BuildContext context, String id, String nombre) async {
    final confirmado = await confirmarEliminacion(context, nombre: nombre);
    if (!confirmado || !context.mounted) return;
    final provider = context.read<SesionUsuarioProvider>();
    final ok = await provider.eliminar(id);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(ok ? 'Registro eliminado' : (provider.error ?? 'No se pudo eliminar'))),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SesionUsuarioProvider>();
    final auth = context.watch<AuthProvider>();
    final esAdmin = auth.usuario?.esAdmin ?? false;
    final puedeEscribir = esAdmin;

    final items = provider.items.where((item) {
      if (_busqueda.trim().isEmpty) return true;
      final q = _busqueda.trim().toLowerCase();
      return item.resultado.toString().toLowerCase().contains(q) ||
          item.ipAddress.toString().toLowerCase().contains(q) ||
          (item.username ?? '').toLowerCase().contains(q);
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Sesiones de usuario')),
      floatingActionButton: puedeEscribir
          ? FloatingActionButton(
              heroTag: 'sesiones_usuario_nuevo_fab',
              onPressed: () => context.push('/sesiones-usuario/nuevo'),
              child: const Icon(Icons.add),
            )
          : null,
      body: LoadingOverlay(
        visible: provider.cargando,
        child: RefreshIndicator(
          onRefresh: () => context.read<SesionUsuarioProvider>().cargar(forzar: true),
          child: Column(
            children: [
              SearchField(
                hintText: 'Buscar sesión...',
                onChanged: (v) => setState(() => _busqueda = v),
              ),
              Expanded(
                child: items.isEmpty
                    ? ListView(
                        children: [
                          const SizedBox(height: 80),
                          Center(
                            child: Text(
                              provider.estado == EstadoCargaSesionUsuario.error
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
                          final nombreMostrado = (item.username?.trim().isNotEmpty ?? false)
                              ? item.username!.trim()
                              : 'Usuario #${item.usuario ?? '—'}';
                          final duracion = item.duracionMinutos;
                          return EntityListCard(
                            titulo: nombreMostrado,
                            subtitulo: '${item.ipAddress} · ${_fmtFecha(item.fechaHora)}',
                            iniciales: nombreMostrado,
                            colorAvatar: _colorResultado(item.resultado),
                            activo: null,
                            estadisticas: [
                              MapEntry('RESULTADO', item.resultadoDisplay ?? item.resultado),
                              MapEntry(
                                'DURACIÓN',
                                duracion != null ? '$duracion min' : (item.fechaCierre == null ? 'Activa' : '—'),
                              ),
                            ],
                            onEliminar: esAdmin && item.id != null ? () => _eliminar(context, item.id!, nombreMostrado) : null,
                            onTap: puedeEscribir ? () => context.push('/sesiones-usuario/${item.id}/editar') : null,
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