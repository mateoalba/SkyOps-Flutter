import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/utils/validators.dart';
import '../../../data/remote/api/google_auth_service.dart';
import '../../../domain/model/auth_models.dart';
import '../../../theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/google_sign_in_button.dart';
import '../../widgets/loading_overlay.dart';

/// Países de residencia — lista corta curada (no requiere API externa).
const List<String> _paises = [
  'Ecuador',
  'Colombia',
  'Perú',
  'Chile',
  'México',
  'Argentina',
  'Estados Unidos',
  'España',
  'Otro',
];

/// Código de país + bandera para el campo de teléfono.
const List<Map<String, String>> _codigosPais = [
  {'codigo': '+593', 'bandera': '🇪🇨', 'pais': 'Ecuador'},
  {'codigo': '+57', 'bandera': '🇨🇴', 'pais': 'Colombia'},
  {'codigo': '+51', 'bandera': '🇵🇪', 'pais': 'Perú'},
  {'codigo': '+56', 'bandera': '🇨🇱', 'pais': 'Chile'},
  {'codigo': '+52', 'bandera': '🇲🇽', 'pais': 'México'},
  {'codigo': '+54', 'bandera': '🇦🇷', 'pais': 'Argentina'},
  {'codigo': '+1', 'bandera': '🇺🇸', 'pais': 'Estados Unidos'},
  {'codigo': '+34', 'bandera': '🇪🇸', 'pais': 'España'},
];

const Map<String, String> _tiposDocumento = {
  'cedula': 'Cédula de ciudadanía',
  'pasaporte': 'Pasaporte',
  'ruc': 'RUC',
  'dni': 'DNI',
};

const Map<String, String> _generos = {
  'femenino': 'Femenino',
  'masculino': 'Masculino',
  'prefiero_no_decirlo': 'Prefiero no decirlo',
};

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  // Datos personales
  String _pais = _paises.first;
  String _tipoDocumento = 'cedula';
  final _numeroDocumentoCtrl = TextEditingController();
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  DateTime? _fechaNacimiento;
  String _genero = 'prefiero_no_decirlo';

  // Teléfono
  String _codigoPais = _codigosPais.first['codigo']!;
  final _telefonoCtrl = TextEditingController();

  // Datos de ingreso
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _password2Ctrl = TextEditingController();
  bool _ocultarPassword = true;
  bool _ocultarPassword2 = true;

  bool _aceptaTerminos = false;
  bool _aceptaDatos = false;

  @override
  void initState() {
    super.initState();
    _passwordCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _numeroDocumentoCtrl.dispose();
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _telefonoCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _password2Ctrl.dispose();
    super.dispose();
  }

  bool get _tiene8Caracteres => _passwordCtrl.text.length >= 8;
  bool get _tieneMayuscula => RegExp(r'[A-Z]').hasMatch(_passwordCtrl.text);
  bool get _tieneMinuscula => RegExp(r'[a-z]').hasMatch(_passwordCtrl.text);
  bool get _tieneNumero => RegExp(r'[0-9]').hasMatch(_passwordCtrl.text);
  bool get _passwordValida => _tiene8Caracteres && _tieneMayuscula && _tieneMinuscula && _tieneNumero;

  Future<void> _seleccionarFechaNacimiento() async {
    final ahora = DateTime.now();
    final fecha = await showDatePicker(
      context: context,
      initialDate: DateTime(ahora.year - 18, ahora.month, ahora.day),
      firstDate: DateTime(1920),
      lastDate: ahora,
      helpText: 'Fecha de nacimiento',
    );
    if (fecha != null) setState(() => _fechaNacimiento = fecha);
  }

  Future<void> _registrar() async {
    if (!_formKey.currentState!.validate()) return;
    if (_fechaNacimiento == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona tu fecha de nacimiento')),
      );
      return;
    }
    if (!_passwordValida) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('La contraseña no cumple los requisitos mínimos')),
      );
      return;
    }
    if (!_aceptaTerminos || !_aceptaDatos) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debes aceptar los términos y el tratamiento de datos')),
      );
      return;
    }

    final auth = context.read<AuthProvider>();
    final ok = await auth.registro(RegistroRequest(
      email: _emailCtrl.text.trim(),
      password: _passwordCtrl.text,
      password2: _password2Ctrl.text,
      firstName: _firstNameCtrl.text.trim(),
      lastName: _lastNameCtrl.text.trim(),
      pais: _pais,
      tipoDocumento: _tipoDocumento,
      numeroDocumento: _numeroDocumentoCtrl.text.trim().isEmpty ? null : _numeroDocumentoCtrl.text.trim(),
      fechaNacimiento: _fechaNacimiento,
      genero: _genero,
      telefono: _telefonoCtrl.text.trim().isEmpty ? null : '$_codigoPais ${_telefonoCtrl.text.trim()}',
    ));
    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cuenta creada. Ahora puedes iniciar sesión.')),
      );
      context.pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.mensajeError ?? 'Error al registrar la cuenta')),
      );
    }
  }

  Future<void> _registrarConGoogle() async {
    if (!GoogleAuthService.instancia.configurado) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registro con Google no está configurado todavía (falta el Client ID).')),
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
        SnackBar(content: Text(auth.mensajeError ?? 'No se pudo registrar con Google')),
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
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Icon(Icons.person_add_alt_1, color: AppColors.primary, size: 30),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Crea tu cuenta operativa',
                    style: TextStyle(color: AppColors.textPrimary, fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Ingresa tus datos tal como aparecen en tu documento de identidad.',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                  ),
                  const SizedBox(height: 22),
                  GoogleSignInButton(
                    etiqueta: 'Registrarme con Google',
                    habilitado: !auth.cargando,
                    onPressed: _registrarConGoogle,
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      const Expanded(child: Divider(color: AppColors.surfaceVariant)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text('o completa el formulario', style: TextStyle(color: AppColors.textSecondary.withValues(alpha: 0.8), fontSize: 12)),
                      ),
                      const Expanded(child: Divider(color: AppColors.surfaceVariant)),
                    ],
                  ),
                  const SizedBox(height: 22),

                  _seccion('Datos personales'),
                  const SizedBox(height: 14),
                  _campoLabel('PAÍS DE RESIDENCIA'),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _pais,
                    dropdownColor: AppColors.surface,
                    items: _paises.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
                    onChanged: (v) => setState(() => _pais = v ?? _pais),
                  ),
                  const SizedBox(height: 18),
                  _campoLabel('TIPO DE DOCUMENTO'),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _tipoDocumento,
                    dropdownColor: AppColors.surface,
                    items: _tiposDocumento.entries
                        .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
                        .toList(),
                    onChanged: (v) => setState(() => _tipoDocumento = v ?? _tipoDocumento),
                  ),
                  const SizedBox(height: 18),
                  _campoLabel('NÚMERO DE DOCUMENTO'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _numeroDocumentoCtrl,
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration: const InputDecoration(hintText: 'Ej. 1712345678'),
                    validator: (v) => Validators.requerido(v, campo: 'El documento'),
                  ),
                  const SizedBox(height: 18),
                  _campoLabel('NOMBRE(S)'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _firstNameCtrl,
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration: const InputDecoration(hintText: 'Tal como aparece en tu documento'),
                    validator: (v) => Validators.requerido(v, campo: 'El nombre'),
                  ),
                  const SizedBox(height: 18),
                  _campoLabel('APELLIDOS'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _lastNameCtrl,
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration: const InputDecoration(hintText: 'Tal como aparecen en tu documento'),
                    validator: (v) => Validators.requerido(v, campo: 'El apellido'),
                  ),
                  const SizedBox(height: 18),
                  _campoLabel('FECHA DE NACIMIENTO'),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: _seleccionarFechaNacimiento,
                    child: InputDecorator(
                      decoration: const InputDecoration(),
                      child: Text(
                        _fechaNacimiento == null
                            ? 'Seleccionar...'
                            : '${_fechaNacimiento!.day.toString().padLeft(2, '0')}/${_fechaNacimiento!.month.toString().padLeft(2, '0')}/${_fechaNacimiento!.year}',
                        style: const TextStyle(color: AppColors.textPrimary),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  _campoLabel('GÉNERO'),
                  const SizedBox(height: 4),
                  ..._generos.entries.map((e) => RadioListTile<String>(
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                        value: e.key,
                        groupValue: _genero,
                        activeColor: AppColors.primary,
                        title: Text(e.value, style: const TextStyle(color: AppColors.textPrimary, fontSize: 14)),
                        onChanged: (v) => setState(() => _genero = v ?? _genero),
                      )),
                  const SizedBox(height: 10),
                  _campoLabel('TELÉFONO'),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 108,
                        child: DropdownButtonFormField<String>(
                          value: _codigoPais,
                          dropdownColor: AppColors.surface,
                          isExpanded: true,
                          items: _codigosPais
                              .map((c) => DropdownMenuItem(
                                    value: c['codigo'],
                                    child: Text('${c['bandera']} ${c['codigo']}', overflow: TextOverflow.ellipsis),
                                  ))
                              .toList(),
                          onChanged: (v) => setState(() => _codigoPais = v ?? _codigoPais),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextFormField(
                          controller: _telefonoCtrl,
                          keyboardType: TextInputType.phone,
                          style: const TextStyle(color: AppColors.textPrimary),
                          decoration: const InputDecoration(hintText: 'Número de teléfono'),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 26),
                  _campoLabel('CORREO ELECTRÓNICO'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _emailCtrl,
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration: const InputDecoration(
                      hintText: 'correo@skyops.com',
                      prefixIcon: Icon(Icons.mail_outline, color: AppColors.textSecondary),
                    ),
                    validator: Validators.email,
                  ),
                  const SizedBox(height: 18),
                  _campoLabel('CONTRASEÑA'),
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
                    validator: (v) => (v == null || v.isEmpty) ? 'La contraseña es obligatoria' : null,
                  ),
                  const SizedBox(height: 10),
                  _requisitoPassword('8 caracteres', _tiene8Caracteres),
                  _requisitoPassword('1 mayúscula', _tieneMayuscula),
                  _requisitoPassword('1 minúscula', _tieneMinuscula),
                  _requisitoPassword('1 número', _tieneNumero),
                  const SizedBox(height: 18),
                  _campoLabel('CONFIRMAR CONTRASEÑA'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _password2Ctrl,
                    obscureText: _ocultarPassword2,
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration: InputDecoration(
                      hintText: '••••••••',
                      prefixIcon: const Icon(Icons.lock_outline, color: AppColors.textSecondary),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _ocultarPassword2 ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                          color: AppColors.textSecondary,
                        ),
                        onPressed: () => setState(() => _ocultarPassword2 = !_ocultarPassword2),
                      ),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Confirma tu contraseña';
                      if (v != _passwordCtrl.text) return 'Las contraseñas no coinciden';
                      return null;
                    },
                  ),
                  const SizedBox(height: 22),
                  CheckboxListTile(
                    value: _aceptaTerminos,
                    onChanged: (v) => setState(() => _aceptaTerminos = v ?? false),
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                    activeColor: AppColors.primary,
                    title: const Text(
                      'Acepto los términos y condiciones de SkyOps.',
                      style: TextStyle(color: AppColors.textPrimary, fontSize: 13),
                    ),
                  ),
                  CheckboxListTile(
                    value: _aceptaDatos,
                    onChanged: (v) => setState(() => _aceptaDatos = v ?? false),
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                    activeColor: AppColors.primary,
                    title: const Text(
                      'Autorizo el tratamiento de mis datos personales.',
                      style: TextStyle(color: AppColors.textPrimary, fontSize: 13),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: auth.cargando ? null : _registrar,
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Crear cuenta'),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward, size: 18),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _seccion(String texto) {
    return Text(
      texto,
      style: const TextStyle(color: AppColors.primary, fontSize: 16, fontWeight: FontWeight.bold),
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

  Widget _requisitoPassword(String texto, bool cumplido) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(
            cumplido ? Icons.check_circle : Icons.cancel,
            size: 16,
            color: cumplido ? AppColors.success : AppColors.textSecondary,
          ),
          const SizedBox(width: 8),
          Text(
            texto,
            style: TextStyle(
              fontSize: 12,
              color: cumplido ? AppColors.success : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
