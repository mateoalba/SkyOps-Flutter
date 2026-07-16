import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../domain/model/auth_models.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/loading_overlay.dart';
import '../../../theme/app_colors.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _emailCtrl = TextEditingController();
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _telefonoCtrl = TextEditingController();
  final _paisCtrl = TextEditingController();
  final _numeroDocumentoCtrl = TextEditingController();
  String? _tipoDocumento;
  String? _genero;
  DateTime? _fechaNacimiento;
  bool _inicializado = false;
  bool _subiendoFoto = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _telefonoCtrl.dispose();
    _paisCtrl.dispose();
    _numeroDocumentoCtrl.dispose();
    super.dispose();
  }

  Future<void> _elegirFoto() async {
    final picker = ImagePicker();
    XFile? archivo;
    try {
      archivo = await picker.pickImage(source: ImageSource.gallery, maxWidth: 1000, imageQuality: 85);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo abrir la galería')),
      );
      return;
    }
    if (archivo == null) return;
    final bytes = await archivo.readAsBytes();
    if (!mounted) return;
    await _guardar(fotoBytes: bytes, fotoNombre: archivo.name);
  }

  Future<void> _guardar({Uint8List? fotoBytes, String? fotoNombre}) async {
    if (fotoBytes != null) {
      setState(() => _subiendoFoto = true);
    }
    final cambios = <String, dynamic>{
      'email': _emailCtrl.text.trim(),
      'first_name': _firstNameCtrl.text.trim(),
      'last_name': _lastNameCtrl.text.trim(),
      'telefono': _telefonoCtrl.text.trim(),
      'pais': _paisCtrl.text.trim(),
      'numero_documento': _numeroDocumentoCtrl.text.trim(),
      if (_tipoDocumento != null) 'tipo_documento': _tipoDocumento,
      if (_genero != null) 'genero': _genero,
      if (_fechaNacimiento != null)
        'fecha_nacimiento':
            '${_fechaNacimiento!.year.toString().padLeft(4, '0')}-${_fechaNacimiento!.month.toString().padLeft(2, '0')}-${_fechaNacimiento!.day.toString().padLeft(2, '0')}',
    };
    final ok = await context.read<AuthProvider>().actualizarPerfil(cambios, fotoBytes: fotoBytes, fotoNombre: fotoNombre);
    if (!mounted) return;
    if (fotoBytes != null) setState(() => _subiendoFoto = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(ok ? 'Perfil actualizado' : 'No se pudo actualizar')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final usuario = auth.usuario;

    if (!_inicializado && usuario != null) {
      _emailCtrl.text = usuario.email;
      _firstNameCtrl.text = usuario.firstName ?? '';
      _lastNameCtrl.text = usuario.lastName ?? '';
      _telefonoCtrl.text = usuario.telefono ?? '';
      _paisCtrl.text = usuario.pais ?? '';
      _numeroDocumentoCtrl.text = usuario.numeroDocumento ?? '';
      _tipoDocumento = (usuario.tipoDocumento?.isNotEmpty ?? false) ? usuario.tipoDocumento : null;
      _genero = (usuario.genero?.isNotEmpty ?? false) ? usuario.genero : null;
      _fechaNacimiento = usuario.fechaNacimiento;
      _inicializado = true;
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: LoadingOverlay(
        visible: auth.cargando && !_subiendoFoto,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text('Perfil', style: TextStyle(color: AppColors.textPrimary, fontSize: 30, fontWeight: FontWeight.bold)),
                    ),
                    IconButton(
                      icon: const Icon(Icons.logout, color: AppColors.textSecondary),
                      tooltip: 'Cerrar sesión',
                      onPressed: () async {
                        await context.read<AuthProvider>().logout();
                        if (context.mounted) context.go('/login');
                      },
                    ),
                  ],
                ),
                const Text(
                  'GESTIONA TU CUENTA',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 11, letterSpacing: 1.2, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 20),

                // --- Tarjeta de identidad ---
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.surfaceVariant),
                  ),
                  child: Column(
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          CircleAvatar(
                            radius: 48,
                            backgroundColor: AppColors.primary.withValues(alpha: 0.18),
                            backgroundImage: (usuario?.foto != null && usuario!.foto!.isNotEmpty)
                                ? NetworkImage(usuario.foto!)
                                : null,
                            child: (usuario?.foto == null || usuario!.foto!.isEmpty)
                                ? Text(
                                    (usuario?.username.isNotEmpty ?? false) ? usuario!.username[0].toUpperCase() : '?',
                                    style: const TextStyle(fontSize: 34, color: AppColors.primary, fontWeight: FontWeight.bold),
                                  )
                                : null,
                          ),
                          Positioned(
                            bottom: -2,
                            right: -2,
                            child: Material(
                              color: AppColors.buttonDark,
                              shape: const CircleBorder(side: BorderSide(color: AppColors.background, width: 2)),
                              child: InkWell(
                              customBorder: const CircleBorder(),
                              onTap: _subiendoFoto ? null : _elegirFoto,
                              child: SizedBox(
                                width: 32,
                                height: 32,
                                child: _subiendoFoto
                                    ? const Padding(
                                        padding: EdgeInsets.all(7),
                                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                      )
                                    : const Icon(Icons.edit, size: 15, color: Colors.white),
                              ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        usuario?.nombreCompleto ?? '',
                        style: const TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.success.withValues(alpha: 0.4)),
                        ),
                        child: Text(
                          usuario?.rolDisplay ?? '',
                          style: const TextStyle(color: AppColors.success, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
                const Text(
                  'CUENTA',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 11, letterSpacing: 1.2, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 10),
                _TarjetaOpciones(children: [
                  _FilaOpcion(
                    icono: Icons.person_outline,
                    titulo: 'Editar perfil',
                    onTap: () => context.push('/perfil/editar'),
                  ),
                ]),

                const SizedBox(height: 24),
                const Text(
                  'SEGURIDAD',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 11, letterSpacing: 1.2, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 10),
                _TarjetaOpciones(children: [
                  _FilaOpcion(
                    icono: Icons.lock_outline,
                    titulo: 'Cambiar contraseña',
                    onTap: () => _mostrarDialogoCambiarPassword(context),
                  ),
                  _FilaOpcion(
                    icono: Icons.notifications_outlined,
                    titulo: 'Notificaciones',
                    onTap: () => context.push('/notificaciones'),
                  ),
                ]),

                const SizedBox(height: 24),
                const Text(
                  'SISTEMA',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 11, letterSpacing: 1.2, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 10),
                _TarjetaOpciones(children: [
                  _FilaOpcion(
                    icono: Icons.logout,
                    titulo: 'Cerrar sesión',
                    colorTexto: AppColors.error,
                    esUltima: true,
                    onTap: () async {
                      await context.read<AuthProvider>().logout();
                      if (context.mounted) context.go('/login');
                    },
                  ),
                ]),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _mostrarDialogoCambiarPassword(BuildContext context) {
    final actualCtrl = TextEditingController();
    final nuevaCtrl = TextEditingController();
    final nueva2Ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cambiar contraseña'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: actualCtrl,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Contraseña actual'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: nuevaCtrl,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Contraseña nueva'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: nueva2Ctrl,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Confirmar contraseña nueva'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancelar')),
          FilledButton(
            onPressed: () async {
              if (nuevaCtrl.text != nueva2Ctrl.text) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Las contraseñas nuevas no coinciden')),
                );
                return;
              }
              final ok = await context.read<AuthProvider>().cambiarPassword(
                    CambiarPasswordRequest(
                      passwordActual: actualCtrl.text,
                      passwordNueva: nuevaCtrl.text,
                      passwordNuevaConfirmacion: nueva2Ctrl.text,
                    ),
                  );
              if (dialogContext.mounted) Navigator.pop(dialogContext);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(ok ? 'Contraseña actualizada' : 'No se pudo cambiar la contraseña')),
                );
              }
            },
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }
}

/// Tarjeta redondeada que agrupa varias [_FilaOpcion], igual al estilo
/// "ACCOUNT SETTINGS" del mockup.
class _TarjetaOpciones extends StatelessWidget {
  final List<Widget> children;
  const _TarjetaOpciones({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.surfaceVariant),
      ),
      child: Column(children: children),
    );
  }
}

class _FilaOpcion extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final VoidCallback onTap;
  final Color? colorTexto;
  final bool esUltima;

  const _FilaOpcion({
    required this.icono,
    required this.titulo,
    required this.onTap,
    this.colorTexto,
    this.esUltima = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: esUltima ? null : const Border(bottom: BorderSide(color: AppColors.surfaceVariant)),
        ),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(color: AppColors.surfaceVariant, shape: BoxShape.circle),
              child: Icon(icono, size: 17, color: colorTexto ?? AppColors.textPrimary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                titulo,
                style: TextStyle(color: colorTexto ?? AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 14),
              ),
            ),
            Icon(Icons.chevron_right, color: colorTexto ?? AppColors.textSecondary, size: 20),
          ],
        ),
      ),
    );
  }
}
