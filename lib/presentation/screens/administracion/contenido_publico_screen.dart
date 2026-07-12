import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../theme/app_colors.dart';
import '../../providers/banner_promocional_provider.dart';
import '../../widgets/editor_imagen_dialog.dart';
import '../public/public_home_screen.dart';

/// Pantalla solo para administradores (accesible desde el menú principal)
/// para editar el contenido que ven las pantallas públicas — antes de
/// iniciar sesión: las 5 tarjetas del carrusel de bienvenida y el
/// encabezado de la pantalla de login. Cada tarjeta guarda su título,
/// texto e imagen en BannerPromocional bajo una clave fija
/// ('carrusel_<id del módulo>' o 'login_hero').
class ContenidoPublicoScreen extends StatefulWidget {
  const ContenidoPublicoScreen({super.key});

  @override
  State<ContenidoPublicoScreen> createState() => _ContenidoPublicoScreenState();
}

class _ContenidoPublicoScreenState extends State<ContenidoPublicoScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BannerPromocionalProvider>().cargar();
    });
  }

  Future<void> _editarModulo(ModuloPublico modulo) async {
    final banners = context.read<BannerPromocionalProvider>();
    final clave = 'carrusel_${modulo.id}';
    final resultado = await mostrarEditorContenido(
      context,
      dialogoTitulo: modulo.etiqueta,
      actualTitulo: banners.tituloPara(clave) ?? modulo.titular,
      actualTexto: banners.textoPara(clave) ?? modulo.resumen,
      actualImagenUrl: banners.urlPara(clave) ?? '',
    );
    if (resultado == null || !mounted) return;
    final ok = await banners.guardarContenido(
      clave,
      titulo: resultado.titulo,
      texto: resultado.texto,
      imagenUrl: resultado.imagenUrl,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(ok ? 'Contenido actualizado' : (banners.error ?? 'No se pudo guardar'))),
    );
  }

  Future<void> _editarLoginHero() async {
    final banners = context.read<BannerPromocionalProvider>();
    const clave = 'login_hero';
    final resultado = await mostrarEditorContenido(
      context,
      dialogoTitulo: 'Encabezado del login',
      mostrarTitulo: false,
      actualTexto: banners.textoPara(clave) ?? 'Gestión de operaciones de vuelo en tiempo real.',
      actualImagenUrl: banners.urlPara(clave) ?? '',
    );
    if (resultado == null || !mounted) return;
    final ok = await banners.guardarContenido(
      clave,
      texto: resultado.texto,
      imagenUrl: resultado.imagenUrl,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(ok ? 'Contenido actualizado' : (banners.error ?? 'No se pudo guardar'))),
    );
  }

  @override
  Widget build(BuildContext context) {
    final banners = context.watch<BannerPromocionalProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text('Contenido público'),
      ),
      body: banners.cargando && banners.estado == EstadoCargaBanner.cargando
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text(
                  'Esto es lo que ve cualquier visitante antes de iniciar sesión: el carrusel '
                  'de bienvenida y la pantalla de login.',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                ),
                const SizedBox(height: 20),
                const _EncabezadoSeccion('CARRUSEL DE BIENVENIDA'),
                const SizedBox(height: 10),
                ...PublicModulos.lista.map(
                  (m) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _TarjetaContenido(
                      etiqueta: m.etiqueta,
                      titulo: banners.tituloPara('carrusel_${m.id}') ?? m.titular,
                      texto: banners.textoPara('carrusel_${m.id}') ?? m.resumen,
                      imagenUrl: banners.urlPara('carrusel_${m.id}'),
                      icono: m.icono,
                      onTap: () => _editarModulo(m),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const _EncabezadoSeccion('PANTALLA DE INICIO DE SESIÓN'),
                const SizedBox(height: 10),
                _TarjetaContenido(
                  etiqueta: 'Login',
                  titulo: 'Frase debajo de "SkyOps"',
                  texto: banners.textoPara('login_hero') ?? 'Gestión de operaciones de vuelo en tiempo real.',
                  imagenUrl: banners.urlPara('login_hero'),
                  icono: Icons.login,
                  onTap: _editarLoginHero,
                ),
              ],
            ),
    );
  }
}

class _EncabezadoSeccion extends StatelessWidget {
  final String texto;
  const _EncabezadoSeccion(this.texto);

  @override
  Widget build(BuildContext context) {
    return Text(
      texto,
      style: const TextStyle(color: AppColors.textSecondary, fontSize: 11, letterSpacing: 1.2, fontWeight: FontWeight.w600),
    );
  }
}

class _TarjetaContenido extends StatelessWidget {
  final String etiqueta;
  final String titulo;
  final String texto;
  final String? imagenUrl;
  final IconData icono;
  final VoidCallback onTap;

  const _TarjetaContenido({
    required this.etiqueta,
    required this.titulo,
    required this.texto,
    required this.imagenUrl,
    required this.icono,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tieneImagen = imagenUrl != null && imagenUrl!.trim().isNotEmpty;

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 56,
                  height: 56,
                  child: tieneImagen
                      ? Image.network(
                          imagenUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: AppColors.surfaceVariant,
                            child: Icon(icono, color: AppColors.textSecondary),
                          ),
                        )
                      : Container(
                          color: AppColors.surfaceVariant,
                          child: Icon(icono, color: AppColors.textSecondary),
                        ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      etiqueta.toUpperCase(),
                      style: const TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.5),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      titulo,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      texto,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}
