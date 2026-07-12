import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/utils/validators.dart';
import '../../../data/remote/api/google_auth_service.dart';
import '../../../theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/banner_promocional_provider.dart';
import '../../widgets/google_sign_in_button.dart';
import '../../widgets/loading_overlay.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _ocultarPassword = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BannerPromocionalProvider>().cargar();
    });
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _iniciarSesion() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final ok = await auth.login(_emailCtrl.text.trim(), _passwordCtrl.text);
    if (ok && mounted) {
      context.go('/home');
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.mensajeError ?? 'Error al iniciar sesión')),
      );
    }
  }

  Future<void> _continuarConGoogle() async {
    if (!GoogleAuthService.instancia.configurado) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login con Google no está configurado todavía (falta el Client ID).')),
      );
      return;
    }
    final idToken = await GoogleAuthService.instancia.obtenerIdToken();
    if (idToken == null || !mounted) return;
    final auth = context.read<AuthProvider>();
    final ok = await auth.loginConGoogle(idToken);
    if (ok && mounted) {
      context.go('/home');
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.mensajeError ?? 'No se pudo iniciar sesión con Google')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      backgroundColor: AppColors.background,
      body: LoadingOverlay(
        visible: auth.cargando,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _HeroHeader(),
              Transform.translate(
                offset: const Offset(0, -20),
                child: Container(
                  decoration: const BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(28),
                      topRight: Radius.circular(28),
                    ),
                  ),
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Bienvenido a SkyOps',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Ingresa tus credenciales.',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                        ),
                        const SizedBox(height: 28),
                        _campoLabel('CORREO ELECTRÓNICO'),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _emailCtrl,
                          keyboardType: TextInputType.emailAddress,
                          style: const TextStyle(color: AppColors.textPrimary),
                          decoration: const InputDecoration(
                            hintText: 'correo@skyops.com',
                            prefixIcon: Icon(Icons.mail_outline, color: AppColors.textSecondary),
                          ),
                          validator: Validators.email,
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _campoLabel('CONTRASEÑA'),
                            GestureDetector(
                              onTap: () {},
                              child: const Text(
                                '¿Olvidaste tu contraseña?',
                                style: TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _passwordCtrl,
                          obscureText: _ocultarPassword,
                          style: const TextStyle(color: AppColors.textPrimary),
                          decoration: InputDecoration(
                            hintText: '••••••••',
                            prefixIcon: const Icon(Icons.lock_outline, color: AppColors.textSecondary),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _ocultarPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                color: AppColors.textSecondary,
                              ),
                              onPressed: () => setState(() => _ocultarPassword = !_ocultarPassword),
                            ),
                          ),
                          validator: (v) => Validators.requerido(v, campo: 'La contraseña'),
                        ),
                        const SizedBox(height: 28),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: auth.cargando ? null : _iniciarSesion,
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Ingresar'),
                                SizedBox(width: 8),
                                Icon(Icons.arrow_forward, size: 18),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            const Expanded(child: Divider(color: AppColors.surfaceVariant)),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              child: Text('o', style: TextStyle(color: AppColors.textSecondary.withValues(alpha: 0.8))),
                            ),
                            const Expanded(child: Divider(color: AppColors.surfaceVariant)),
                          ],
                        ),
                        const SizedBox(height: 20),
                        GoogleSignInButton(
                          etiqueta: 'Continuar con Google',
                          habilitado: !auth.cargando,
                          onPressed: _continuarConGoogle,
                        ),
                        const SizedBox(height: 24),
                        Center(
                          child: RichText(
                            text: TextSpan(
                              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                              children: [
                                const TextSpan(text: '¿No tienes cuenta? '),
                                TextSpan(
                                  text: 'Regístrate',
                                  style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () => context.push('/register'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _campoLabel(String texto) {
    return Text(
      texto,
      style: const TextStyle(
        color: AppColors.textSecondary,
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.6,
      ),
    );
  }
}

/// Sección superior tipo "hero" con degradado nocturno y el logo de SkyOps.
/// La imagen de fondo y la frase debajo de "SkyOps" las configura un admin
/// desde "Contenido público" (clave 'login_hero'); si no hay nada
/// configurado se usan el degradado y el texto por defecto.
class _HeroHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final banners = context.watch<BannerPromocionalProvider>();
    final imagenUrl = banners.urlPara('login_hero');
    final tieneImagen = imagenUrl != null && imagenUrl.trim().isNotEmpty;
    final frase = banners.textoPara('login_hero') ?? 'Gestión de operaciones de vuelo en tiempo real.';

    return Container(
      height: 300,
      width: double.infinity,
      clipBehavior: Clip.hardEdge,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0F1E4D), Color(0xFF060613)],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (tieneImagen)
            Image.network(
              imagenUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
            ),
          if (tieneImagen)
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0x662E5CFF), Color(0xFF060613)],
                  stops: [0.0, 0.9],
                ),
              ),
            ),
          SafeArea(
            bottom: false,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(Icons.flight, color: Colors.white, size: 32),
                ),
                const SizedBox(height: 14),
                const Text(
                  'SkyOps',
                  style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 48),
                  child: Text(
                    frase,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 13),
                  ),
                ),
                const SizedBox(height: 22),
                Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
